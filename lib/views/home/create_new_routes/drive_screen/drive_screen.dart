import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:right_routes/global_widgets/custom_navbar.dart';
import 'package:right_routes/utils/responsive_ext.dart';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;

import 'package:right_routes/core/constants/services/route_permit_service.dart';

class DriveRouteMap extends StatefulWidget {
  const DriveRouteMap({super.key});

  @override
  State<DriveRouteMap> createState() => _DriveRouteMapState();
}

class _DriveRouteMapState extends State<DriveRouteMap>
    with SingleTickerProviderStateMixin {
  MapLibreMapController? _mapController;

  double _vehicleLat = 23.8103;
  double _vehicleLng = 90.4125;
  double _vehicleBearing = 0.0;
  double _targetBearing = 0.0;

  double? _previousLat;
  double? _previousLng;

  Symbol? _vehicleSymbol;
  Line? _routeLine;

  bool _isTracking = true;

  // GPS navigation state
  bool _hasRealGPS = false;
  double _metersSinceLastRedraw = 0;
  static const double _redrawEveryMeters = 150;

  late AnimationController _rotationController;
  StreamSubscription<Position>? _positionSubscription;

  // ✅ Waypoint data from previous screen
  List<LatLng> _waypointPositions = [];
  String _routeId = '';

  // Simulated navigation state for preview/testing
  Timer? _simulationTimer;
  List<LatLng> _simulatedPath = [];
  bool _isSimulating = false;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _initFromArguments();
    _requestPermission();
    _startDriveApi();
  }

  void _initFromArguments() {
    final args = Get.arguments;
    debugPrint('📋 [DriveScreen] Received arguments: $args');

    if (args != null && args is Map) {
      if (args['routePoints'] != null) {
        try {
          final rawList = args['routePoints'] as List;
          _waypointPositions = rawList.map((e) {
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
          debugPrint('✅ [DriveScreen] Loaded ${_waypointPositions.length} waypoints');
          debugPrint('📍 [DriveScreen] Waypoints: $_waypointPositions');
        } catch (e) {
          debugPrint('❌ [DriveScreen] Error parsing routePoints: $e');
        }

        if (_waypointPositions.isNotEmpty) {
          _vehicleLat = _waypointPositions.first.latitude;
          _vehicleLng = _waypointPositions.first.longitude;
          _previousLat = _vehicleLat;
          _previousLng = _vehicleLng;
          debugPrint(
              '🚗 [DriveScreen] Initial starting position from first waypoint: ($_vehicleLat, $_vehicleLng)');
        }
      } else {
        debugPrint('⚠️ [DriveScreen] No routePoints in arguments');
      }

      if (args['routeId'] != null) {
        _routeId = args['routeId'].toString();
        debugPrint('🆔 [DriveScreen] Route ID: $_routeId');
      }
    } else {
      debugPrint('❌ [DriveScreen] No arguments or invalid format');
    }
  }

  Future<void> _startDriveApi() async {
    if (_routeId.isEmpty) {
      debugPrint(
          '⚠️ [DriveRouteMap] routeId is empty, skipping drive-start API');
      return;
    }

    try {
      debugPrint(
          '🚀 [DriveRouteMap] Triggering drive-start API for route: $_routeId');
      final success = await RoutePermitService.startDrive(_routeId);
      if (success) {
        Get.snackbar(
          'Drive Started',
          'Server navigation state active',
          backgroundColor: Colors.green.withValues(alpha: 0.9),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      debugPrint('❌ [DriveRouteMap] Error in startDrive API: $e');
    }
  }

  Future<void> _stopDriveApi() async {
    if (_routeId.isEmpty) return;
    try {
      debugPrint(
          '🛑 [DriveRouteMap] Triggering drive-stop API for route: $_routeId');
      final success = await RoutePermitService.stopDrive(_routeId);
      if (success) {
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
      debugPrint('❌ [DriveRouteMap] Error in stopDrive API: $e');
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
    if (!mounted) return;
    double diff = newBearing - _vehicleBearing;
    if (diff > 180) {
      diff -= 360;
    } else if (diff < -180) {
      diff += 360;
    }
    _targetBearing = _vehicleBearing + diff;
    try {
      if (_rotationController.status != AnimationStatus.forward) {
        _rotationController.forward(from: 0);
      }
    } catch (e) {
      debugPrint('Rotation animation error: $e');
    }
    setState(() => _vehicleBearing = _targetBearing);
  }

  // ✅ Load Truck Image
  Future<Uint8List> _loadCarImage() async {
    final ByteData data = await rootBundle.load('assets/images/truck_icon.png');
    final Uint8List bytes = data.buffer.asUint8List();

    final ui.Codec codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: 150, // Slightly smaller for 3D view
    );

    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image resizedImage = frameInfo.image;

    final ByteData? resizedData = await resizedImage.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return resizedData!.buffer.asUint8List();
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
      debugPrint('🛰️ [DriveScreen] Fetching real-time current GPS location for start...');
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 4),
      );
      startLatLng = LatLng(position.latitude, position.longitude);
      hasRealLocation = true;
      debugPrint('🛰️ [DriveScreen] Real GPS location fetched: $startLatLng');
    } catch (e) {
      debugPrint('⚠️ [DriveScreen] Could not fetch current location: $e. Falling back to first waypoint.');
    }

    if (startLatLng == null && _waypointPositions.isNotEmpty) {
      startLatLng = _waypointPositions.first;
    }

    final localStart = startLatLng;
    if (localStart != null) {
      setState(() {
        _vehicleLat = localStart.latitude;
        _vehicleLng = localStart.longitude;
        _previousLat = _vehicleLat;
        _previousLng = _vehicleLng;
        _vehicleBearing = 0.0;
        _targetBearing = 0.0;
        _hasRealGPS = hasRealLocation;
      });

      await _drawRoute();
      _recenter(); // Recenter to focus on current location at startup
      _updateVehicleMarker();
    } else {
      debugPrint('⚠️ [DriveRouteMap] No starting location or waypoints available');
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
      if (!mounted) return;

      // If we are in simulated preview run mode, check if actual GPS moves significantly away
      if (_isSimulating && _simulatedPath.isNotEmpty) {
        final startDist = Geolocator.distanceBetween(
          _simulatedPath.first.latitude,
          _simulatedPath.first.longitude,
          position.latitude,
          position.longitude,
        );
        if (startDist > 50) {
          setState(() {
            _isSimulating = false;
          });
          _simulationTimer?.cancel();
          debugPrint(
              '📡 Real GPS movement detected (>50m from start). Switching to real-time navigation.');
        } else {
          // Stationary/jitter GPS — keep simulated path running!
          return;
        }
      }

      double newBearing = _vehicleBearing;
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

      setState(() {
        _vehicleLat = position.latitude;
        _vehicleLng = position.longitude;
        _previousLat = position.latitude;
        _previousLng = position.longitude;
        _hasRealGPS = true;
      });

      _updateVehicleMarker();

      // ── Smooth 3D camera follow ──────────────────────────────
      if (_isTracking && _mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(_vehicleLat, _vehicleLng),
              zoom: 14.0, // Changed from 17.5 to show more area
              tilt: 45.0, // Reduced tilt for better overview
              bearing: _vehicleBearing,
            ),
          ),
          duration: const Duration(milliseconds: 1000),
        );
      }

      if (_metersSinceLastRedraw >= _redrawEveryMeters) {
        _metersSinceLastRedraw = 0;
        _drawRoute();
      }
    });
  }

  void _updateVehicleMarker() async {
    if (_mapController == null) return;
    if (!_hasRealGPS) {
      if (_vehicleSymbol != null) {
        try {
          await _mapController!.removeSymbol(_vehicleSymbol!);
        } catch (e) {
          debugPrint('Error removing vehicle symbol: $e');
        }
        _vehicleSymbol = null;
      }
      return;
    }

    if (_vehicleSymbol != null) {
      try {
        await _mapController!.updateSymbol(
          _vehicleSymbol!,
          SymbolOptions(
            geometry: LatLng(_vehicleLat, _vehicleLng),
            iconRotate: _vehicleBearing,
          ),
        );
      } catch (e) {
        _vehicleSymbol = null;
        await _ensureVehicleSymbol();
      }
    } else {
      await _ensureVehicleSymbol();
    }
  }

  final List<Symbol> _waypointSymbols = [];
  bool _waypointIconsLoaded = false;

  Future<void> _loadWaypointIcon() async {
    if (_mapController == null || _waypointIconsLoaded) return;
    try {
      final bytes = await rootBundle.load('assets/icons/Map-Pin-orange.png');
      await _mapController!.addImage('wp-pin', bytes.buffer.asUint8List());
      _waypointIconsLoaded = true;
    } catch (e) {
      debugPrint('Waypoint icon load error: $e');
    }
  }

  Future<void> _addWaypointMarkers() async {
    if (_mapController == null) return;
    try {
      // Clear any existing symbols and circles completely to guarantee no duplicate stacked markers
      await _mapController!.clearSymbols();
      await _mapController!.clearCircles();
      _waypointSymbols.clear();
      _vehicleSymbol = null; // Reset vehicle symbol variable so it is recreated by _ensureVehicleSymbol()
    } catch (e) {
      debugPrint('Error clearing markers: $e');
    }

    if (!_waypointIconsLoaded) {
      debugPrint('⚠️ wp-pin icon not loaded, falling back to circle markers');
      for (int i = 0; i < _waypointPositions.length; i++) {
        try {
          await _mapController!.addCircle(CircleOptions(
            geometry: _waypointPositions[i],
            circleRadius: 8.0,
            circleColor: '#FF6B35',
            circleStrokeWidth: 2.0,
            circleStrokeColor: '#FFFFFF',
          ));
        } catch (e) {
          debugPrint('Circle fallback error: $e');
        }
      }
      return;
    }

    try {
      for (int i = 0; i < _waypointPositions.length; i++) {
        final sym = await _mapController!.addSymbol(SymbolOptions(
          geometry: _waypointPositions[i],
          iconImage: 'wp-pin',
          iconSize: 0.45,
          textField: '${i + 1}',
          textSize: 10.0,
          textOffset: const Offset(0, 1.2),
          textColor: '#FFFFFF',
          textHaloColor: '#000000',
          textHaloWidth: 1.5,
          textHaloBlur: 0.5,
          draggable: false,
        ));
        _waypointSymbols.add(sym);
      }
    } catch (e) {
      debugPrint('Waypoint symbols error: $e');
    }
  }

  Future<void> _ensureVehicleSymbol() async {
    if (_mapController == null || _vehicleSymbol != null || !_hasRealGPS) return;
    try {
      _vehicleSymbol = await _mapController!.addSymbol(
        SymbolOptions(
          geometry: LatLng(_vehicleLat, _vehicleLng),
          iconImage: 'car-icon',
          iconSize: 0.8,
          iconRotate: _vehicleBearing,
          iconAnchor: 'center',
        ),
      );
    } catch (e) {
      debugPrint('Vehicle symbol error: $e');
    }
  }

  void _recenter() {
    setState(() => _isTracking = true);
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(_vehicleLat, _vehicleLng),
            zoom: 14.0, // Changed from 17.5 to show more area
            tilt: 45.0, // Reduced tilt for better overview
            bearing: _vehicleBearing,
          ),
        ),
        duration: const Duration(milliseconds: 1000),
      );
    }
  }

  Future<void> _drawRoute() async {
    if (_mapController == null) return;

    final List<LatLng> allPoints = [
      if (_hasRealGPS) LatLng(_vehicleLat, _vehicleLng),
      ..._waypointPositions,
    ];

    // De-duplicate adjacent identical or extremely close coordinates (<2 meters)
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

    debugPrint(
        '🗺️ [DrawRoute] Total points for polyline: ${cleanPoints.length} (cleaned from ${allPoints.length})');
    debugPrint('🗺️ [DrawRoute] Points: $cleanPoints');

    if (cleanPoints.length < 2) {
      debugPrint('⚠️ [DrawRoute] Not enough points (need at least 2)');
      return;
    }

    if (_routeLine != null) {
      try {
        await _mapController!.removeLine(_routeLine!);
        debugPrint('🗑️ [DrawRoute] Removed old polyline');
      } catch (e) {}
      _routeLine = null;
    }

    try {
      final coords =
          cleanPoints.map((p) => '${p.longitude},${p.latitude}').join(';');
      debugPrint(
          '🌐 [DrawRoute] Calling OSRM API with ${cleanPoints.length} points');

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

          debugPrint(
              '✅ [DrawRoute] OSRM returned ${line.length} points for polyline');

          _routeLine = await _mapController!.addLine(LineOptions(
            geometry: line,
            lineColor: '#F28546', // Matching orange route color
            lineWidth: 8.0,
            lineOpacity: 0.9,
            lineJoin: 'round',
          ));

          debugPrint(
              '✅ [DrawRoute] Polyline drawn successfully with OSRM data');

          _simulatedPath = line;
          if (_simulationTimer == null && _isSimulating) {
            _startSimulation();
          }
          return;
        }
      }
      debugPrint('⚠️ [DrawRoute] OSRM API failed or returned no routes');
    } catch (e) {
      debugPrint('❌ [DrawRoute] OSRM error: $e');
    }

    // Fallback: draw straight-line polyline if OSRM fails
    try {
      debugPrint('🔄 [DrawRoute] Using fallback straight-line polyline');

      _routeLine = await _mapController!.addLine(LineOptions(
        geometry: cleanPoints,
        lineColor: '#F28546', // Matching orange route color
        lineWidth: 8.0,
        lineOpacity: 0.9,
        lineJoin: 'round',
      ));

      debugPrint(
          '✅ [DrawRoute] Fallback polyline drawn with ${cleanPoints.length} points');

      _simulatedPath = cleanPoints;
      if (_simulationTimer == null && _isSimulating) {
        _startSimulation();
      }
    } catch (e) {
      debugPrint('❌ [DrawRoute] Fallback route draw error: $e');
    }
  }

  void _startSimulation() {
    _simulationTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ═══════════════════════════════════════════════════════════
          // MAP
          // ═══════════════════════════════════════════════════════════
          // 🔴 MaplibreMap-কে Listener দিয়ে Wrap করা হলো টাচ ডিটেক্ট করার জন্য
          Listener(
            onPointerDown: (_) {
              // ইউজার ম্যাপে টাচ করলে ট্র্যাকিং অফ হয়ে যাবে
              if (_isTracking) setState(() => _isTracking = false);
            },
            child: MapLibreMap(
              styleString:
                  'https://api.maptiler.com/maps/streets-v2/style.json?key=dHNKoVs9jL46w6oUpFt3',
              initialCameraPosition: CameraPosition(
                target: LatLng(_vehicleLat, _vehicleLng),
                zoom: 14.0, // Changed from 17.5 to show more area
                tilt: 45.0, // Reduced tilt for better overview
              ),
              onMapCreated: (controller) async {
                _mapController = controller;
              },
              onStyleLoadedCallback: () async {
                final carImage = await _loadCarImage();
                await _mapController?.addImage('car-icon', carImage);

                await _loadWaypointIcon();
                await _addWaypointMarkers();
                await _drawRoute();
                await _ensureVehicleSymbol();
              },
              // ❌ onCameraMoveStarted রিমুভ করা হয়েছে কারণ Listener টাচ ডিটেক্ট করছে
              myLocationEnabled: false,
              compassEnabled: false,
              rotateGesturesEnabled: true,
              scrollGesturesEnabled: true,
              tiltGesturesEnabled: true,
              zoomGesturesEnabled: true,
            ),
          ),

          // ═══════════════════════════════════════════════════════════
          // ✅ BOTTOM BUTTONS - SAME DESIGN AS SCREENSHOT
          // ═══════════════════════════════════════════════════════════
          Positioned(
            bottom: context.h(25),
            left: context.w(12),
            right: context.w(12),
            child: SafeArea(
              top: false,
              child: Center(
                child: ConstrainedBox(
                  // Caps the bar width so buttons stay the same visual size
                  // in landscape instead of stretching across the wider screen.
                  constraints: BoxConstraints(maxWidth: context.w(360)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _btn(context, 'Back', () {
                        _stopDriveApi(); // Trigger in background to avoid blocking pop
                        Get.back();
                      }),
                      _btn(context, 'Offline Map',
                          () {}), // Empty button as seen in screenshot
                      _btn(context, 'Recenter', _recenter),
                      _btn(context, 'Cancel', () {
                        _stopDriveApi(); // Trigger in background to avoid blocking pop
                        Get.back();
                      }), // Cancel navigation
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomNavbar(),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ✅ BUTTON WIDGET - Orange styling matching screenshot
  // ═══════════════════════════════════════════════════════════
  Widget _btn(BuildContext context, String text, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: context.h(36), // Slim button
          margin: EdgeInsets.symmetric(horizontal: context.w(4)),
          decoration: BoxDecoration(
            color: const Color(0xFFF28546), // Exact orange from image
            borderRadius: BorderRadius.circular(context.r(6)),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: context.sp(14),
                fontFamily: 'Lato',
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    _positionSubscription?.cancel();
    _rotationController.dispose();
    _stopDriveApi();
    super.dispose();
  }
}