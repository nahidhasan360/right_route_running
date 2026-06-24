import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
import 'package:right_routes/core/constants/services/route_permit_service.dart';
import 'package:right_routes/utils/map_icon_util.dart';

class DriveController extends GetxController
    with GetSingleTickerProviderStateMixin {
  MapLibreMapController? mapController;

  final RxDouble vehicleLat = 23.8103.obs;
  final RxDouble vehicleLng = 90.4125.obs;
  final RxDouble vehicleBearing = 0.0.obs;
  double _targetBearing = 0.0;

  double? _previousLat;
  double? _previousLng;

  Symbol? _vehicleSymbol;
  Line? _routeLine;

  final RxBool isTracking = true.obs;

  bool _hasRealGPS = false;
  double _metersSinceLastRedraw = 0;
  static const double _redrawEveryMeters = 150;

  late AnimationController _rotationController;
  StreamSubscription<Position>? _positionSubscription;

  List<LatLng> waypointPositions = [];
  String routeId = '';

  Timer? _simulationTimer;
  List<LatLng> _simulatedPath = [];
  bool _isSimulating = false;

  final List<Symbol> _waypointSymbols = [];
  bool _waypointIconsLoaded = false;

  @override
  void onInit() {
    super.onInit();
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _initFromArguments();
    _requestPermission();
    startDriveApi();
  }

  bool _isApiHandled = false;

  @override
  void onClose() {
    _simulationTimer?.cancel();
    _positionSubscription?.cancel();
    _rotationController.dispose();
    if (!_isApiHandled) {
      stopDriveApi();
    }
    super.onClose();
  }

  void _initFromArguments() {
    final args = Get.arguments;
    debugPrint('📋 [DriveController] Received arguments: $args');

    if (args != null && args is Map) {
      if (args['routePoints'] != null) {
        try {
          final rawList = args['routePoints'] as List;
          waypointPositions = rawList.map((e) {
            if (e is LatLng) return e;
            if (e is Map) {
              final lat = (e['latitude'] ?? e['lat'] ?? 0.0) as num;
              final lng = (e['longitude'] ?? e['lng'] ?? 0.0) as num;
              return LatLng(lat.toDouble(), lng.toDouble());
            }
            if (e is List && e.length >= 2) {
              return LatLng((e[0] as num).toDouble(), (e[1] as num).toDouble());
            }
            throw Exception('Invalid point format in routePoints');
          }).toList();
          debugPrint(
              '✅ [DriveController] Loaded ${waypointPositions.length} waypoints');
        } catch (e) {
          debugPrint('❌ [DriveController] Error parsing routePoints: $e');
        }

        if (waypointPositions.isNotEmpty) {
          vehicleLat.value = waypointPositions.first.latitude;
          vehicleLng.value = waypointPositions.first.longitude;
          _previousLat = vehicleLat.value;
          _previousLng = vehicleLng.value;
        }
      }

      if (args['routeId'] != null) {
        routeId = args['routeId'].toString();
      }
    }
  }

  Future<void> startDriveApi() async {
    if (routeId.isEmpty) return;
    try {
      final success = await RoutePermitService.startDrive(routeId);
      if (success && !isClosed) {
        Get.snackbar(
          'Drive Started',
          'Server navigation state started',
          backgroundColor: Colors.green.withValues(alpha: 0.9),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      debugPrint('❌ [DriveController] Error in startDrive API: $e');
    }
  }

  Future<void> stopDriveApi() async {
    if (routeId.isEmpty || _isApiHandled) return;
    _isApiHandled = true;
    try {
      final success = await RoutePermitService.stopDrive(routeId);
      if (success && !isClosed) {
        Get.snackbar(
          'Drive Stopped',
          'Server navigation state stopped',
          backgroundColor: Colors.orange.withValues(alpha: 0.9),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      debugPrint('❌ [DriveController] Error in stopDrive API: $e');
    }
  }

  Future<void> downloadOfflineMap() async {
    if (waypointPositions.isEmpty) return;

    Get.snackbar(
      'Downloading Map',
      'Started downloading offline map for this route...',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue.withValues(alpha: 0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );

    try {
      double minLat = waypointPositions[0].latitude;
      double maxLat = waypointPositions[0].latitude;
      double minLng = waypointPositions[0].longitude;
      double maxLng = waypointPositions[0].longitude;

      for (var point in waypointPositions) {
        if (point.latitude < minLat) minLat = point.latitude;
        if (point.latitude > maxLat) maxLat = point.latitude;
        if (point.longitude < minLng) minLng = point.longitude;
        if (point.longitude > maxLng) maxLng = point.longitude;
      }

      final latPadding = (maxLat - minLat) * 0.1;
      final lngPadding = (maxLng - minLng) * 0.1;

      minLat = minLat - (latPadding == 0 ? 0.05 : latPadding);
      maxLat = maxLat + (latPadding == 0 ? 0.05 : latPadding);
      minLng = minLng - (lngPadding == 0 ? 0.05 : lngPadding);
      maxLng = maxLng + (lngPadding == 0 ? 0.05 : lngPadding);

      final definition = OfflineRegionDefinition(
        bounds: LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        mapStyleUrl:
            'https://api.maptiler.com/maps/streets-v2/style.json?key=dHNKoVs9jL46w6oUpFt3',
        minZoom: 10,
        maxZoom: 16,
      );

      await downloadOfflineRegion(
        definition,
        metadata: {
          'name': 'Drive Route Offline Map',
        },
      );

      Get.snackbar(
        'Download Complete',
        'Offline map has been successfully downloaded.',
        backgroundColor: Colors.green.withValues(alpha: 0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      debugPrint('❌ [DriveController] Error downloading offline map: $e');
      Get.snackbar(
        'Error',
        'Failed to download map',
        backgroundColor: Colors.red.withValues(alpha: 0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> cancelDriveApi() async {
    if (routeId.isEmpty || _isApiHandled) return;
    _isApiHandled = true;
    try {
      final success = await RoutePermitService.cancelDrive(routeId);
      if (success && !isClosed) {
        Get.snackbar(
          'Drive Cancelled',
          'Server navigation state cancelled',
          backgroundColor: Colors.red.withValues(alpha: 0.9),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      debugPrint('❌ [DriveController] Error in cancelDrive API: $e');
    }
  }

  double _calculateBearing(double lat1, double lon1, double lat2, double lon2) {
    final dLon = (lon2 - lon1) * math.pi / 180;
    final y = math.sin(dLon) * math.cos(lat2 * math.pi / 180);
    final x = math.cos(lat1 * math.pi / 180) * math.sin(lat2 * math.pi / 180) -
        math.sin(lat1 * math.pi / 180) *
            math.cos(lat2 * math.pi / 180) *
            math.cos(dLon);
    final bearing = math.atan2(y, x) * 180 / math.pi;
    return (bearing + 360) % 360;
  }

  void _updateBearing(double newBearing) {
    double diff = newBearing - vehicleBearing.value;
    if (diff > 180) {
      diff -= 360;
    } else if (diff < -180) {
      diff += 360;
    }
    _targetBearing = vehicleBearing.value + diff;
    try {
      if (_rotationController.status != AnimationStatus.forward) {
        _rotationController.forward(from: 0);
      }
    } catch (e) {
      debugPrint('Rotation animation error: $e');
    }
    vehicleBearing.value = _targetBearing;
  }

  Future<void> _requestPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      await _initializeFromWaypoints();
      _startTracking();
    } else {
      Get.snackbar(
        'Permission Required',
        'Please enable location permission',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      await _initializeFromWaypoints();
    }
  }

  Future<void> _initializeFromWaypoints() async {
    LatLng? startLatLng;
    bool hasRealLocation = false;

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 4),
        ),
      );
      startLatLng = LatLng(position.latitude, position.longitude);
      hasRealLocation = true;
    } catch (e) {
      debugPrint('⚠️ [DriveController] Could not fetch current location: $e');
    }

    if (startLatLng == null && waypointPositions.isNotEmpty) {
      startLatLng = waypointPositions.first;
    }

    if (startLatLng != null) {
      vehicleLat.value = startLatLng.latitude;
      vehicleLng.value = startLatLng.longitude;
      _previousLat = vehicleLat.value;
      _previousLng = vehicleLng.value;
      vehicleBearing.value = 0.0;
      _targetBearing = 0.0;
      _hasRealGPS = hasRealLocation;

      await drawRoute();
      recenter();
      _updateVehicleMarker();
    } else {
      Get.snackbar(
        'Error',
        'No route data or location available',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _startTracking() {
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 2,
      ),
    ).listen((position) {
      if (_isSimulating && _simulatedPath.isNotEmpty) {
        final startDist = Geolocator.distanceBetween(
          _simulatedPath.first.latitude,
          _simulatedPath.first.longitude,
          position.latitude,
          position.longitude,
        );
        if (startDist > 50) {
          _isSimulating = false;
          _simulationTimer?.cancel();
        } else {
          return;
        }
      }

      double newBearing = vehicleBearing.value;
      if (position.heading >= 0) {
        newBearing = position.heading;
      } else if (_previousLat != null && _previousLng != null) {
        double moveDist = Geolocator.distanceBetween(
          _previousLat!,
          _previousLng!,
          position.latitude,
          position.longitude,
        );
        if (moveDist > 3) {
          newBearing = _calculateBearing(
            _previousLat!,
            _previousLng!,
            position.latitude,
            position.longitude,
          );
        }
      }
      _updateBearing(newBearing);

      if (_previousLat != null && _previousLng != null) {
        _metersSinceLastRedraw += Geolocator.distanceBetween(
          _previousLat!,
          _previousLng!,
          position.latitude,
          position.longitude,
        );
      }

      vehicleLat.value = position.latitude;
      vehicleLng.value = position.longitude;
      _previousLat = position.latitude;
      _previousLng = position.longitude;
      _hasRealGPS = true;

      _updateVehicleMarker();

      if (isTracking.value && mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(vehicleLat.value, vehicleLng.value),
              zoom: 14.0,
              tilt: 45.0,
              bearing: vehicleBearing.value,
            ),
          ),
          duration: const Duration(milliseconds: 1000),
        );
      }

      if (_metersSinceLastRedraw >= _redrawEveryMeters) {
        _metersSinceLastRedraw = 0;
        drawRoute();
      }
    });
  }

  void _updateVehicleMarker() async {
    if (mapController == null) return;
    if (!_hasRealGPS) {
      if (_vehicleSymbol != null) {
        try {
          await mapController!.removeSymbol(_vehicleSymbol!);
        } catch (e) {
          debugPrint('Error: $e');
        }
        _vehicleSymbol = null;
      }
      return;
    }

    if (_vehicleSymbol != null) {
      try {
        await mapController!.updateSymbol(
          _vehicleSymbol!,
          SymbolOptions(
            geometry: LatLng(vehicleLat.value, vehicleLng.value),
            iconRotate: vehicleBearing.value,
          ),
        );
      } catch (e) {
        _vehicleSymbol = null;
        await ensureVehicleSymbol();
      }
    } else {
      await ensureVehicleSymbol();
    }
  }

  Future<void> loadWaypointIcon() async {
    if (mapController == null || _waypointIconsLoaded) return;
    try {
      final bytes = await rootBundle.load('assets/icons/Map-Pin-orange.png');
      await mapController!.addImage('wp-pin', bytes.buffer.asUint8List());

      await MapIconUtil.loadStartEndIcons(mapController!);

      _waypointIconsLoaded = true;
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> addWaypointMarkers() async {
    if (mapController == null) return;
    try {
      await mapController!.clearSymbols();
      await mapController!.clearCircles();
      _waypointSymbols.clear();
      _vehicleSymbol = null;
    } catch (e) {
      debugPrint('Error: $e');
    }

    for (int i = 0; i < waypointPositions.length; i++) {
      final isStart = i == 0;
      final isEnd =
          i == waypointPositions.length - 1 && waypointPositions.length > 1;

      if (isStart || isEnd) {
        try {
          final sym = await mapController!.addSymbol(SymbolOptions(
            geometry: waypointPositions[i],
            iconImage: isStart ? 'start-icon' : 'end-icon',
            iconSize: 1.0,
            iconAnchor: 'center',
            zIndex: 100,
            draggable: false,
          ));
          _waypointSymbols.add(sym);
        } catch (e) {
          debugPrint('Error: $e');
        }
      } else {
        if (_waypointIconsLoaded) {
          try {
            final sym = await mapController!.addSymbol(SymbolOptions(
              geometry: waypointPositions[i],
              iconImage: 'wp-pin',
              iconSize: 0.45,
              textField: '$i',
              textSize: 10.0,
              textOffset: const Offset(0, 1.2),
              textColor: '#FFFFFF',
              textHaloColor: '#000000',
              textHaloWidth: 1.5,
              textHaloBlur: 0.5,
              zIndex: 1,
              draggable: false,
            ));
            _waypointSymbols.add(sym);
          } catch (e) {
            debugPrint('Error: $e');
          }
        } else {
          try {
            await mapController!.addCircle(CircleOptions(
              geometry: waypointPositions[i],
              circleRadius: 8.0,
              circleColor: '#FF6B35',
              circleStrokeWidth: 2.0,
              circleStrokeColor: '#FFFFFF',
            ));
          } catch (e) {
            debugPrint('Error: $e');
          }
        }
      }
    }
  }

  Future<void> ensureVehicleSymbol() async {
    if (mapController == null || _vehicleSymbol != null || !_hasRealGPS) return;
    try {
      _vehicleSymbol = await mapController!.addSymbol(
        SymbolOptions(
          geometry: LatLng(vehicleLat.value, vehicleLng.value),
          iconImage: 'car-icon',
          iconSize: 0.8,
          iconRotate: vehicleBearing.value,
          iconAnchor: 'center',
        ),
      );
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void recenter() {
    isTracking.value = true;
    if (mapController != null) {
      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(vehicleLat.value, vehicleLng.value),
            zoom: 14.0,
            tilt: 45.0,
            bearing: vehicleBearing.value,
          ),
        ),
        duration: const Duration(milliseconds: 1000),
      );
    }
  }

  Future<void> drawRoute() async {
    if (mapController == null) return;

    final List<LatLng> allPoints = [
      if (_hasRealGPS) LatLng(vehicleLat.value, vehicleLng.value),
      ...waypointPositions,
    ];

    final List<LatLng> cleanPoints = [];
    for (final p in allPoints) {
      if (p.latitude == 0.0 && p.longitude == 0.0) continue;

      if (cleanPoints.isEmpty) {
        cleanPoints.add(p);
      } else {
        final last = cleanPoints.last;
        final double dist = Geolocator.distanceBetween(
          last.latitude,
          last.longitude,
          p.latitude,
          p.longitude,
        );
        if (dist >= 2.0) {
          cleanPoints.add(p);
        }
      }
    }

    if (cleanPoints.length < 2) return;

    if (_routeLine != null) {
      try {
        await mapController!.removeLine(_routeLine!);
      } catch (e) {
        debugPrint('Error: $e');
      }
      _routeLine = null;
    }

    try {
      final coords =
          cleanPoints.map((p) => '${p.longitude},${p.latitude}').join(';');

      final res = await http
          .get(
            Uri.parse(
                'https://router.project-osrm.org/route/v1/driving/$coords?overview=full&geometries=geojson'),
          )
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['routes']?.isNotEmpty == true) {
          final route = data['routes'][0];
          final coordsList = route['geometry']['coordinates'] as List;
          final line =
              coordsList.map<LatLng>((c) => LatLng(c[1], c[0])).toList();

          _routeLine = await mapController!.addLine(LineOptions(
            geometry: line,
            lineColor: '#F28546',
            lineWidth: 8.0,
            lineOpacity: 0.9,
            lineJoin: 'round',
          ));

          _simulatedPath = line;
          if (_simulationTimer == null && _isSimulating) {
            _startSimulation();
          }
          return;
        }
      }
    } catch (e) {
      debugPrint('Error: $e');
    }

    try {
      _routeLine = await mapController!.addLine(LineOptions(
        geometry: cleanPoints,
        lineColor: '#F28546',
        lineWidth: 8.0,
        lineOpacity: 0.9,
        lineJoin: 'round',
      ));

      _simulatedPath = cleanPoints;
      if (_simulationTimer == null && _isSimulating) {
        _startSimulation();
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void _startSimulation() {
    _simulationTimer?.cancel();
  }

  Future<Uint8List> loadCarImage() async {
    final ByteData data = await rootBundle.load('assets/images/truck_icon.png');
    final Uint8List bytes = data.buffer.asUint8List();

    final ui.Codec codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: 150,
    );

    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image resizedImage = frameInfo.image;

    final ByteData? resizedData = await resizedImage.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return resizedData!.buffer.asUint8List();
  }
}
