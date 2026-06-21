import 'dart:math' show Point;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:right_routes/core/constants/services/api_client.dart';
import 'package:right_routes/core/constants/services/route_permit_service.dart';
import 'package:right_routes/views/home/home_api_constant/home_api_constant.dart';
import 'package:dio/dio.dart' as dio;

/// Controller for the Confirm & Edit Your Route screen.
class ConfirmRouteController extends GetxController {
  // ─────────────────────────────────────────────────────────────
  // CONSTANTS
  // ─────────────────────────────────────────────────────────────
  static const String _maptilerKey = 'dHNKoVs9jL46w6oUpFt3';
  static const String _osrmBase =
      'https://router.project-osrm.org/route/v1/driving';
  static const Duration _osrmTimeout = Duration(seconds: 15);
  static const int _osrmMaxRetries = 2;
  static const double _pinTapThreshold = 0.003;

  // ─────────────────────────────────────────────────────────────
  // PUBLIC OBSERVABLES  (view binds here)
  // ─────────────────────────────────────────────────────────────
  final RxString distance = '0.0 miles'.obs;
  final RxBool isMapReady = false.obs;
  final RxBool isRouteLoading = false.obs;
  final RxBool isAddingPinMode = false.obs;
  final RxBool isWaypointsExpanded = true.obs;

  final RxList<TextEditingController> waypointControllers =
      <TextEditingController>[].obs;
  final RxList<String> waypoints = <String>[].obs;
  final RxInt selectedWaypointIndex = (-1).obs;
  final RxBool isDragging = false.obs;

  // ─────────────────────────────────────────────────────────────
  // PUBLIC NON-REACTIVE  (set once, read by view)
  // ─────────────────────────────────────────────────────────────
  final TextEditingController routeNameController = TextEditingController();

  LatLng currentLocation = const LatLng(43.5460, -96.7313);

  String? currentRouteId;
  String? currentPermitId;
  final RxList<int?> waypointIds = <int?>[].obs;

  void toggleWaypoints() {
    isWaypointsExpanded.value = !isWaypointsExpanded.value;
  }

  // ─────────────────────────────────────────────────────────────
  // PRIVATE MAP STATE
  // ─────────────────────────────────────────────────────────────
  MapLibreMapController? mapController;

  final List<Symbol> _waypointSymbols = [];
  final List<LatLng> _waypointPositions = [];
  final List<bool> _waypointSelectedStates = [];
  Line? _routeLine;

  LatLng _mapCenter = const LatLng(43.5460, -96.7313);
  double _mapZoom = 11.0;
  bool _iconsLoaded = false;
  int? _draggingPinIndex;

  int _routeGeneration = 0;

  // ─────────────────────────────────────────────────────────────
  // LIFECYCLE
  // ─────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    routeNameController.text = '';
    _initializeFromArguments();
    // Location permission removed - no automatic location fetching
  }

  @override
  void onClose() {
    routeNameController.dispose();
    _clearWaypointControllers();
    mapController = null;
    super.onClose();
  }

  // ─────────────────────────────────────────────────────────────
  // INITIALIZATION
  // ─────────────────────────────────────────────────────────────
  void _initializeFromArguments() {
    try {
      final args = Get.arguments;
      if (args is! Map) {
        _setDefaultWaypoints();
        return;
      }

      final startLocation = args['startLocation'] as String?;
      final endLocation = args['endLocation'] as String?;
      final routeSegments =
          (args['routeSegments'] as List?)?.cast<String>() ?? <String>[];
      final permitType = args['permitType'] as String?;
      final rawCoords = (args['routeWithCoordinates'] as List?) ?? [];
      final coordsList =
          rawCoords.map((e) => Map<String, dynamic>.from(e as Map)).toList();

      waypoints.clear();
      _clearWaypointControllers();
      _waypointPositions.clear();
      _waypointSelectedStates.clear();

      LatLng? coordFor(String label) {
        for (final c in coordsList) {
          if (c['location'].toString() == label) {
            return LatLng(
              (c['lat'] as num).toDouble(),
              (c['lng'] as num).toDouble(),
            );
          }
        }
        return null;
      }

      void appendWaypoint(String label, LatLng? coord) {
        waypoints.add(label);
        waypointControllers.add(TextEditingController(text: label));
        _waypointSelectedStates.add(false);
        _waypointPositions.add(coord ??
            LatLng(
              currentLocation.latitude + _waypointPositions.length * 0.01,
              currentLocation.longitude + _waypointPositions.length * 0.01,
            ));
      }

      final routeId = args['routeId']?.toString();
      final permitId = args['permitId']?.toString();

      if (routeId != null && permitId != null) {
        // Fetch data from API if we have the IDs
        fetchPermitDetails(routeId, permitId);
      } else {
        // Fallback to static arguments if no IDs provided
        final startLabel = (startLocation?.isNotEmpty == true)
            ? startLocation!
            : 'Your current location';
        appendWaypoint(startLabel, coordFor(startLabel));

        for (final seg in routeSegments) {
          if (seg.isNotEmpty) appendWaypoint(seg, coordFor(seg));
        }

        if (endLocation?.isNotEmpty == true) {
          appendWaypoint(endLocation!, coordFor(endLocation));
        }

        if (permitType?.isNotEmpty == true) {
          routeNameController.text = permitType!;
        }

        if (_waypointPositions.isNotEmpty) {
          currentLocation = _waypointPositions.first;
          _mapCenter = _waypointPositions.first;
        }
      }
    } catch (e) {
      debugPrint('ConfirmRouteController init error: $e');
      _setDefaultWaypoints();
    }
  }

  void _appendWaypoint(String label, LatLng? coord, [int? id]) {
    waypoints.add(label);
    waypointControllers.add(TextEditingController(text: label));
    _waypointSelectedStates.add(false);
    waypointIds.add(id);
    _waypointPositions.add(coord ??
        LatLng(
          currentLocation.latitude + _waypointPositions.length * 0.01,
          currentLocation.longitude + _waypointPositions.length * 0.01,
        ));
  }

  // ─────────────────────────────────────────────────────────────
  // API INTEGRATION
  // ─────────────────────────────────────────────────────────────

  /// Fetches all permits for the route, finds the one matching [permitId],
  /// then populates waypoints into the map.
  ///
  /// Endpoint: GET /navigation/route/{routeId}/permit/
  /// Response: { success, data: { route_name, permit: [ { id, start_location_name,
  ///            start_latitude, start_longitude, end_location_name, end_latitude,
  ///            end_longitude, waypoints: [...] } ] } }
  Future<void> fetchPermitDetails(String routeId, String permitId) async {
    try {
      currentRouteId = routeId;
      currentPermitId = permitId;
      isRouteLoading.value = true;

      debugPrint(
          '🌐 [FetchPermit] Fetching permits → routeId=$routeId, permitId=$permitId');

      // Use the dedicated service which calls GET /navigation/route/{routeId}/permit/
      final permitItem =
          await RoutePermitService.fetchSinglePermit(routeId, permitId);

      if (permitItem == null) {
        debugPrint(
            '❌ [FetchPermit] Permit #$permitId not found in response list.');
        Get.snackbar(
          'Error',
          'Permit #$permitId not found on server.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return;
      }

      debugPrint(
          '✅ [FetchPermit] Found permit: ${permitItem.displayTitle} — ${permitItem.waypoints.length} waypoints');

      // ── Update route name in the text field ─────────────────────────────
      routeNameController.text = permitItem.displayTitle;

      // ── Rebuild waypoints list ──────────────────────────────────────────
      waypoints.clear();
      _clearWaypointControllers();
      _waypointPositions.clear();
      _waypointSelectedStates.clear();
      waypointIds.clear();

      // Start location
      if (permitItem.startLocationName.isNotEmpty) {
        debugPrint(
            '📍 [FetchPermit] Adding START: ${permitItem.startLocationName}');
        _appendWaypoint(
          permitItem.startLocationName,
          LatLng(permitItem.startLatitude, permitItem.startLongitude),
          null, // start has no separate waypoint ID
        );
      }

      // Intermediate waypoints (sorted by order)
      final sortedWaypoints = List.of(permitItem.waypoints)
        ..sort((a, b) => a.order.compareTo(b.order));

      debugPrint(
          '📍 [FetchPermit] Total intermediate waypoints: ${sortedWaypoints.length}');

      for (final wp in sortedWaypoints) {
        debugPrint('  → Waypoint #${wp.order}: ${wp.name} (ID: ${wp.id})');
        _appendWaypoint(
          wp.name,
          LatLng(wp.latitude, wp.longitude),
          wp.id,
        );
      }

      // End location
      if (permitItem.endLocationName.isNotEmpty) {
        debugPrint(
            '📍 [FetchPermit] Adding END: ${permitItem.endLocationName}');
        _appendWaypoint(
          permitItem.endLocationName,
          LatLng(permitItem.endLatitude, permitItem.endLongitude),
          null, // end has no separate waypoint ID
        );
      }

      debugPrint('✅ [FetchPermit] Total waypoints loaded: ${waypoints.length}');
      debugPrint('   Waypoints: ${waypoints.join(" → ")}');

      // Set initial camera to first waypoint
      if (_waypointPositions.isNotEmpty) {
        currentLocation = _waypointPositions.first;
        _mapCenter = _waypointPositions.first;
      }

      waypoints.refresh();

      // If the map is already rendered, refresh markers + polyline
      if (isMapReady.value && mapController != null) {
        await _refreshMap();
      }
    } catch (e) {
      debugPrint('❌ [FetchPermit] Error: $e');
      Get.snackbar(
        'Error',
        'Failed to load permit data. Please try again.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isRouteLoading.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // MAP EVENTS
  // ─────────────────────────────────────────────────────────────
  void onMapCreated(MapLibreMapController controller) {
    mapController = controller;
    isMapReady.value = true;

    controller.onSymbolTapped.add((symbol) {
      final idx = _waypointSymbols.indexOf(symbol);
      if (idx != -1) _handlePinTap(idx);
    });

    controller.onFeatureDrag.add((
      Point<double> point,
      LatLng origin,
      LatLng current,
      LatLng delta,
      String id,
      Annotation? annotation,
      DragEventType eventType,
    ) async {
      if (annotation is! Symbol) return;
      final idx = _waypointSymbols.indexOf(annotation);
      if (idx == -1) return;

      if (eventType == DragEventType.start) {
        isDragging.value = true;
        _draggingPinIndex = idx;
      }

      if (idx < _waypointPositions.length) _waypointPositions[idx] = current;

      if (eventType == DragEventType.end) {
        isDragging.value = false;
        _draggingPinIndex = null;

        final address =
            await _reverseGeocode(current.latitude, current.longitude);
        if (idx < waypoints.length) {
          waypoints[idx] = address;
          waypoints.refresh(); // Fix: Ensure list reactivity
        }
        if (idx < waypointControllers.length) {
          waypointControllers[idx].text = address;
        }

        await _refreshMap();
      }
    });
  }

  void onCameraMove(CameraPosition position) {
    _mapCenter = position.target;
    _mapZoom = position.zoom;
  }

  Future<void> onStyleLoaded() async {
    if (mapController == null) return;
    try {
      _iconsLoaded = false;
      await _loadIcons();
      await _refreshMap();
    } catch (e) {
      debugPrint('onStyleLoaded error: $e');
    }
  }

  // NEW: Updated onMapClick to handle Add Pin Mode
  Future<void> onMapClick(LatLng point) async {
    if (isAddingPinMode.value) {
      // Add a pin at the tapped location and exit mode
      isAddingPinMode.value = false;
      await _addPinAtLocation(point);
      return;
    }

    final idx = _pinNear(point);
    if (idx != null) {
      _handlePinTap(idx);
    } else {
      _deselectAll();
    }
  }

  Future<void> onMapLongClick(LatLng point) async {
    final idx = _pinNear(point);
    if (idx != null) _handlePinTap(idx);
  }

  // ─────────────────────────────────────────────────────────────
  // MAP DRAWING
  // ─────────────────────────────────────────────────────────────
  Future<void> _refreshMap() async {
    await _addAllMarkers();
    await _drawRealRoadPolyline();
    _calculateDistance();
    _fitMapToWaypoints();
  }

  Future<void> _loadIcons() async {
    if (mapController == null || _iconsLoaded) return;
    try {
      final bytes = await rootBundle.load('assets/icons/Map-Pin-orange.png');
      await mapController!.addImage('pin-orange', bytes.buffer.asUint8List());
      _iconsLoaded = true;
    } catch (e) {
      debugPrint('Icon load error: $e');
    }
  }

  Future<void> _addAllMarkers() async {
    if (mapController == null || !_iconsLoaded) return;
    try {
      if (_waypointSymbols.isNotEmpty) {
        await mapController!.removeSymbols(_waypointSymbols);
        _waypointSymbols.clear();
      }

      debugPrint(
          '🗺️ [AddMarkers] Adding ${_waypointPositions.length} pins to map...');

      for (int i = 0; i < _waypointPositions.length; i++) {
        final isSelected =
            i < _waypointSelectedStates.length && _waypointSelectedStates[i];
        final sym = await mapController!.addSymbol(SymbolOptions(
          geometry: _waypointPositions[i],
          iconImage: 'pin-orange',
          iconSize: isSelected ? 0.55 : 0.45,
          textField: '${i + 1}',
          textSize: 12.0,
          textOffset: const Offset(0, 0.6),
          textColor: '#FFFFFF',
          textHaloColor: '#000000',
          textHaloWidth: 1.8,
          textHaloBlur: 0.8,
          textAnchor: 'center',
          draggable: true,
        ));
        _waypointSymbols.add(sym);
        debugPrint(
            '  ✓ Pin #${i + 1} added at ${_waypointPositions[i].latitude}, ${_waypointPositions[i].longitude}');
      }

      debugPrint(
          '✅ [AddMarkers] All ${_waypointSymbols.length} pins added successfully');
    } catch (e) {
      debugPrint('❌ [AddMarkers] Error: $e');
    }
  }

  // FIXED: No more stuck "Calculating route"
  Future<void> _drawRealRoadPolyline() async {
    if (mapController == null || _waypointPositions.length < 2) {
      if (_routeLine != null) {
        try {
          await mapController!.removeLine(_routeLine!);
        } catch (_) {}
        _routeLine = null;
      }
      isRouteLoading.value = false; // Turn off loading
      return;
    }

    final generation = ++_routeGeneration;
    isRouteLoading.value = true; // Turn ON loading

    try {
      if (_routeLine != null) {
        try {
          await mapController!.removeLine(_routeLine!);
        } catch (_) {}
        _routeLine = null;
      }

      if (generation != _routeGeneration) return;

      final routeGeometry =
          await _fetchOsrmRoute(List.from(_waypointPositions));

      if (generation != _routeGeneration) return;
      if (mapController == null) return;

      _routeLine = await mapController!.addLine(LineOptions(
        geometry: routeGeometry,
        lineColor: '#FF6B35',
        lineWidth: 5.0,
        lineOpacity: 0.9,
        lineJoin: 'round',
      ));
    } catch (e) {
      debugPrint('DrawRealRoadPolyline error: $e');
    } finally {
      // Turn OFF loading only for the latest request
      if (generation == _routeGeneration) {
        isRouteLoading.value = false;
      }
    }
  }

  Future<List<LatLng>> _fetchOsrmRoute(List<LatLng> points) async {
    final coordStr =
        points.map((p) => '${p.longitude},${p.latitude}').join(';');
    final uri =
        Uri.parse('$_osrmBase/$coordStr?overview=full&geometries=geojson');

    for (int attempt = 0; attempt <= _osrmMaxRetries; attempt++) {
      try {
        final response = await ApiClient.get(uri, headers: {'User-Agent': 'RightRoutes/1.0'}, requireAuth: false);

        if (response.statusCode == 200) {
          final data = response.data;
          final routes = data['routes'] as List?;
          if (routes != null && routes.isNotEmpty) {
            final geometry = (routes[0] as Map<String, dynamic>)['geometry']
                as Map<String, dynamic>;
            final coords = geometry['coordinates'] as List;
            return coords
                .map<LatLng>((c) => LatLng(
                      (c[1] as num).toDouble(),
                      (c[0] as num).toDouble(),
                    ))
                .toList();
          }
        }
      } catch (e) {
        debugPrint('OSRM attempt ${attempt + 1} failed: $e');
        if (attempt < _osrmMaxRetries) {
          await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
        }
      }
    }

    return List.from(points);
  }

  void _calculateDistance() {
    if (_waypointPositions.length < 2) {
      distance.value = '0.0 miles';
      return;
    }
    double totalMeters = 0.0;
    for (int i = 0; i < _waypointPositions.length - 1; i++) {
      totalMeters += Geolocator.distanceBetween(
        _waypointPositions[i].latitude,
        _waypointPositions[i].longitude,
        _waypointPositions[i + 1].latitude,
        _waypointPositions[i + 1].longitude,
      );
    }
    distance.value = '${(totalMeters / 1609.34).toStringAsFixed(1)} miles';
  }

  void _fitMapToWaypoints() {
    if (mapController == null || _waypointPositions.isEmpty) return;

    try {
      if (_waypointPositions.length == 1) {
        mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(_waypointPositions[0], 13.0));
        return;
      }

      final lats = _waypointPositions.map((p) => p.latitude);
      final lngs = _waypointPositions.map((p) => p.longitude);
      final minLat = lats.reduce((a, b) => a < b ? a : b);
      final maxLat = lats.reduce((a, b) => a > b ? a : b);
      final minLng = lngs.reduce((a, b) => a < b ? a : b);
      final maxLng = lngs.reduce((a, b) => a > b ? a : b);

      final latPad = ((maxLat - minLat) * 0.15).clamp(0.005, 5.0);
      final lngPad = ((maxLng - minLng) * 0.15).clamp(0.005, 5.0);

      mapController!.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat - latPad, minLng - lngPad),
          northeast: LatLng(maxLat + latPad, maxLng + lngPad),
        ),
        left: 40,
        top: 60,
        right: 40,
        bottom: 60,
      ));
    } catch (e) {
      debugPrint('FitMapToWaypoints error: $e');
    }
  }

  void _handlePinTap(int index) {
    final wasSelected = index < _waypointSelectedStates.length &&
        _waypointSelectedStates[index];
    _deselectAll();
    if (!wasSelected) {
      if (index < _waypointSelectedStates.length) {
        _waypointSelectedStates[index] = true;
      }
      selectedWaypointIndex.value = index;
    }
    _addAllMarkers();
  }

  void _deselectAll() {
    for (int i = 0; i < _waypointSelectedStates.length; i++) {
      _waypointSelectedStates[i] = false;
    }
    selectedWaypointIndex.value = -1;
  }

  int? _pinNear(LatLng tap) {
    int? bestIdx;
    double bestDist = double.infinity;
    for (int i = 0; i < _waypointPositions.length; i++) {
      final d = (tap.latitude - _waypointPositions[i].latitude).abs() +
          (tap.longitude - _waypointPositions[i].longitude).abs();
      if (d < _pinTapThreshold && d < bestDist) {
        bestDist = d;
        bestIdx = i;
      }
    }
    return bestIdx;
  }

  // ─────────────────────────────────────────────────────────────
  // PUBLIC UI ACTIONS
  // ─────────────────────────────────────────────────────────────
  Future<void> zoomIn() async {
    if (mapController == null) return;
    final z = (_mapZoom + 1).clamp(1.0, 20.0);
    await mapController!.animateCamera(
      CameraUpdate.zoomTo(z),
      duration: const Duration(milliseconds: 300),
    );
    _mapZoom = z;
  }

  Future<void> zoomOut() async {
    if (mapController == null) return;
    final z = (_mapZoom - 1).clamp(1.0, 20.0);
    await mapController!.animateCamera(
      CameraUpdate.zoomTo(z),
      duration: const Duration(milliseconds: 300),
    );
    _mapZoom = z;
  }

  // NEW: Toggle add pin mode
  void toggleAddPinMode() {
    isAddingPinMode.value = !isAddingPinMode.value;
  }

  // NEW: Add pin at specific coordinates with API Call
  Future<void> _addPinAtLocation(LatLng point) async {
    try {
      final address = await _reverseGeocode(point.latitude, point.longitude);
      int? newId;

      if (currentRouteId != null && currentPermitId != null) {
        final url = Uri.parse(
            '${HomeApiConstant.baseUrl}/navigation/route/$currentRouteId/permit/$currentPermitId/add-waypoint/');

        final formData = dio.FormData.fromMap({
          'latitude': point.latitude.toString(),
          'longitude': point.longitude.toString(),
          'name': address,
        });

        final response = await ApiClient.sendMultipartRequest(url, data: formData, method: 'POST');
        if (response.statusCode == 201 || response.statusCode == 200) {
          final data = response.data;
          if (data['data'] != null && data['data']['id'] != null) {
            newId = data['data']['id'];
          }
          Get.snackbar('Success', 'Waypoint added to server',
              backgroundColor: Colors.green, colorText: Colors.white);
        } else {
          Get.snackbar('Error', 'Failed to add waypoint to server',
              backgroundColor: Colors.redAccent, colorText: Colors.white);
        }
      }

      _appendWaypoint(address, point, newId);
      await _refreshMap();
    } catch (e) {
      debugPrint("❌ Add waypoint error: $e");
    }
  }

  // Kept for backward compatibility
  Future<void> addMapPin() async {
    toggleAddPinMode();
  }

  // FIXED: Delete pin with API call
  Future<void> deleteSelectedMapPin() async {
    final idx = selectedWaypointIndex.value;
    if (idx == -1) {
      Get.snackbar('No pin selected', 'Tap a pin on the map to select it',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }
    if (waypoints.length <= 2) {
      Get.snackbar('Cannot remove', 'A route needs at least 2 waypoints',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    // Call DELETE API if we have an ID
    final wId = waypointIds[idx];
    if (wId != null && currentRouteId != null && currentPermitId != null) {
      final url = Uri.parse(
          '${HomeApiConstant.baseUrl}/navigation/route/$currentRouteId/permit/$currentPermitId/remove-waypoint/$wId/');

      final response = await ApiClient.delete(url, headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode != 200 && response.statusCode != 204) {
        Get.snackbar('Error', 'Failed to delete waypoint on server',
            backgroundColor: Colors.redAccent, colorText: Colors.white);
        return;
      }
    }

    // Safely remove locally
    waypoints.removeAt(idx);
    final controllerToDispose = waypointControllers[idx];
    waypointControllers.removeAt(idx);
    controllerToDispose.dispose();

    _waypointPositions.removeAt(idx);
    _waypointSelectedStates.removeAt(idx);
    waypointIds.removeAt(idx);

    selectedWaypointIndex.value = -1;
    await _refreshMap();
  }

  void deleteSelectedWaypoint() => deleteSelectedMapPin();

  Future<void> updateRoute() async {
    // API UPDATE for selected waypoint
    final idx = selectedWaypointIndex.value;
    if (idx != -1 && currentRouteId != null && currentPermitId != null) {
      final wId = waypointIds[idx];
      if (wId != null) {
        final url = Uri.parse(
            '${HomeApiConstant.baseUrl}/navigation/route/$currentRouteId/permit/$currentPermitId/update-waypoint/$wId/');

        final point = _waypointPositions[idx];
        final name = waypointControllers[idx].text;

        final formData = dio.FormData.fromMap({
          'latitude': point.latitude.toString(),
          'longitude': point.longitude.toString(),
          'name': name,
        });

        final response = await ApiClient.sendMultipartRequest(url, data: formData, method: 'PATCH');
        if (response.statusCode == 200 || response.statusCode == 201) {
          Get.snackbar('Success', 'Waypoint updated on server',
              backgroundColor: Colors.green, colorText: Colors.white);
        } else {
          Get.snackbar('Error', 'Failed to update waypoint on server',
              backgroundColor: Colors.redAccent, colorText: Colors.white);
        }
      } else {
        Get.snackbar('Local Update',
            'Waypoint updated locally (not yet saved to server)',
            backgroundColor: Colors.orange, colorText: Colors.white);
      }
    }

    // Refresh UI texts
    for (int i = 0; i < waypointControllers.length; i++) {
      if (i < waypoints.length) waypoints[i] = waypointControllers[i].text;
    }
    waypoints.refresh();
    await _refreshMap();
  }

  void selectWaypoint(int index) {
    if (index < 0 || index >= waypoints.length) return;
    final wasSelected = index < _waypointSelectedStates.length &&
        _waypointSelectedStates[index];
    _deselectAll();
    if (!wasSelected) {
      if (index < _waypointSelectedStates.length) {
        _waypointSelectedStates[index] = true;
      }
      selectedWaypointIndex.value = index;
    }
    _addAllMarkers();
  }

  void updateWaypoint(int index, String val) {
    if (index >= 0 && index < waypoints.length) {
      waypoints[index] = val;
      waypoints.refresh();
    }
  }

  void updateRouteName(String val) => routeNameController.text = val;

  void addWaypointAt(int index) {
    if (index >= _waypointPositions.length) return;
    final p1 = _waypointPositions[index];
    final p2 = (index < _waypointPositions.length - 1)
        ? _waypointPositions[index + 1]
        : LatLng(p1.latitude + 0.01, p1.longitude + 0.01);
    final mid = LatLng(
      (p1.latitude + p2.latitude) / 2,
      (p1.longitude + p2.longitude) / 2,
    );
    waypoints.insert(index + 1, 'New Stop');
    waypointControllers.insert(
        index + 1, TextEditingController(text: 'New Stop'));
    _waypointPositions.insert(index + 1, mid);
    _waypointSelectedStates.insert(index + 1, false);
    _refreshMap();
  }

  // ─────────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────────
  void _setDefaultWaypoints() {
    waypoints.assignAll(['Your location', 'Stop 1', 'Stop 2']);
    _clearWaypointControllers();
    _waypointSelectedStates.clear();
    _waypointPositions.clear();
    for (int i = 0; i < waypoints.length; i++) {
      waypointControllers.add(TextEditingController(text: waypoints[i]));
      _waypointSelectedStates.add(false);
      _waypointPositions.add(LatLng(
        currentLocation.latitude + i * 0.01,
        currentLocation.longitude + i * 0.01,
      ));
    }
  }

  void _clearWaypointControllers() {
    for (final c in waypointControllers) {
      c.dispose();
    }
    waypointControllers.clear();
  }

  Future<String> _reverseGeocode(double lat, double lng) async {
    try {
      final places = await placemarkFromCoordinates(lat, lng)
          .timeout(const Duration(seconds: 8));
      if (places.isNotEmpty) {
        final p = places.first;
        final parts = <String>[
          if (p.street?.isNotEmpty == true) p.street!,
          if (p.locality?.isNotEmpty == true) p.locality!,
          if (p.administrativeArea?.isNotEmpty == true) p.administrativeArea!,
        ];
        if (parts.isNotEmpty) return parts.join(', ');
      }
    } catch (_) {}
    return '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
  }

  List<LatLng> get waypointPositions => List.unmodifiable(_waypointPositions);
}
