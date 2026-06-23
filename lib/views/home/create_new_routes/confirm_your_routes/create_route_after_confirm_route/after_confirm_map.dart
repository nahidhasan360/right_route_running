import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:get/get.dart';
import 'package:geocoding/geocoding.dart';
import 'package:right_routes/core/constants/services/api_client.dart';
import 'package:right_routes/views/home/create_new_routes/confirm_your_routes/create_route_after_confirm_route/after_confirm_controller.dart';

class AfterConfirmMap extends StatefulWidget {
  const AfterConfirmMap({super.key});

  @override
  State<AfterConfirmMap> createState() => _AfterConfirmMapState();
}

class _AfterConfirmMapState extends State<AfterConfirmMap> {
  MapLibreMapController? mapController;
  final AfterConfirmController _ctrl = Get.find<AfterConfirmController>();

  Symbol? _startSymbol;
  Symbol? _endSymbol;
  Line? _routeLine;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300.h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.r),
      ),
      clipBehavior: Clip.hardEdge,
      child: MapLibreMap(
        styleString:
            'https://api.maptiler.com/maps/openstreetmap/style.json?key=dHNKoVs9jL46w6oUpFt3',
        initialCameraPosition: const CameraPosition(
          target: LatLng(43.5460, -96.7313), // Default center
          zoom: 11.0,
        ),
        myLocationEnabled: true,
        compassEnabled: false,
        zoomGesturesEnabled: true,
        scrollGesturesEnabled: true,
        rotateGesturesEnabled: true,
        tiltGesturesEnabled: true,
        onMapCreated: (controller) {
          mapController = controller;
          mapController!.onFeatureDrag.add(_onFeatureDrag);
        },
        onStyleLoadedCallback: _onStyleLoaded,
        onMapClick: _onMapClick,
      ),
    );
  }

  Future<void> _onStyleLoaded() async {
    if (mapController == null) return;
    if (_ctrl.startLat.value.isNotEmpty && _ctrl.startLng.value.isNotEmpty) {
      double lat = double.tryParse(_ctrl.startLat.value) ?? 0.0;
      double lng = double.tryParse(_ctrl.startLng.value) ?? 0.0;
      if (lat != 0.0 && lng != 0.0) {
        final coordinates = LatLng(lat, lng);
        _startSymbol = await mapController!.addSymbol(
          SymbolOptions(
            geometry: coordinates,
            textField: 'S',
            textColor: '#00FF00',
            textSize: 28,
            textOffset: const Offset(0, -0.4),
            textHaloWidth: 1.0,
            textHaloColor: '#00FF00',
            draggable: true,
          ),
        );
        await mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: coordinates, zoom: 14.0),
          ),
        );
      }
    }
  }

  Future<void> _onMapClick(Point<double> point, LatLng coordinates) async {
    if (mapController == null) return;

    // Determine location name
    String locationName = 'Unknown Location';
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          coordinates.latitude, coordinates.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        locationName = place.locality ?? place.subAdministrativeArea ?? place.administrativeArea ?? place.country ?? 'Unknown Location';
      }
    } catch (e) {
      debugPrint('Geocoding error: $e');
    }

    if (_startSymbol == null) {
      // Set Start Location
      _startSymbol = await mapController!.addSymbol(
        SymbolOptions(
          geometry: coordinates,
          textField: 'S',
          textColor: '#00FF00', // Green text fill
          textSize: 28,
          textOffset: const Offset(0, -0.4),
          textHaloWidth: 1.0,
          textHaloColor: '#00FF00',
          draggable: true,
        ),
      );
      _ctrl.startLat.value = coordinates.latitude.toString();
      _ctrl.startLng.value = coordinates.longitude.toString();
      _ctrl.startLocation.value = locationName;
      _ctrl.startLng.value = coordinates.longitude.toString();
    } else if (_endSymbol == null) {
      // Set End Location
      _endSymbol = await mapController!.addSymbol(
        SymbolOptions(
          geometry: coordinates,
          textField: 'E',
          textColor: '#FF0000', // Red text fill
          textSize: 28,
          textOffset: const Offset(0, -0.4),
          textHaloWidth: 1.0,
          textHaloColor: '#FF0000',
          draggable: true,
        ),
      );
      
      // Draw Polyline
      final routeGeometry = await _fetchOsrmRoute([
        _startSymbol!.options.geometry!,
        coordinates,
      ]);

      _routeLine = await mapController!.addLine(
        LineOptions(
          geometry: routeGeometry,
          lineColor: '#F58842', // AppColors.orange
          lineWidth: 5.0,
          lineOpacity: 0.9,
          lineJoin: 'round',
        ),
      );

      _ctrl.endLat.value = coordinates.latitude.toString();
      _ctrl.endLng.value = coordinates.longitude.toString();
      _ctrl.endLocation.value = locationName;
      _ctrl.endLng.value = coordinates.longitude.toString();

      // Smooth zoom to fit both points
      await _fitBounds([_startSymbol!.options.geometry!, coordinates]);

    } else {
      // Reset if both are set and clicked again
      await mapController!.removeSymbol(_startSymbol!);
      await mapController!.removeSymbol(_endSymbol!);
      if (_routeLine != null) {
        await mapController!.removeLine(_routeLine!);
      }
      _startSymbol = null;
      _endSymbol = null;
      _routeLine = null;
      _ctrl.startLat.value = '';
      _ctrl.startLng.value = '';
      _ctrl.startLocation.value = '';
      _ctrl.endLat.value = '';
      _ctrl.endLng.value = '';
      _ctrl.endLocation.value = '';
    }
  }

  void _onFeatureDrag(
      Point<double> point,
      LatLng origin,
      LatLng current,
      LatLng delta,
      String id,
      dynamic annotation,
      DragEventType eventType,
  ) async {
    if (eventType != DragEventType.end) return;

    final LatLng newCoords = current;
    String locationName = 'Unknown Location';
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          newCoords.latitude, newCoords.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        locationName = place.locality ?? place.subAdministrativeArea ?? place.administrativeArea ?? place.country ?? 'Unknown Location';
      }
    } catch (e) {
      debugPrint('Geocoding error: $e');
    }

    if (_startSymbol != null && id == _startSymbol!.id) {
      _ctrl.startLat.value = newCoords.latitude.toString();
      _ctrl.startLng.value = newCoords.longitude.toString();
      _ctrl.startLocation.value = locationName;
      await mapController!.updateSymbol(_startSymbol!, SymbolOptions(geometry: newCoords));
    } else if (_endSymbol != null && id == _endSymbol!.id) {
      _ctrl.endLat.value = newCoords.latitude.toString();
      _ctrl.endLng.value = newCoords.longitude.toString();
      _ctrl.endLocation.value = locationName;
      await mapController!.updateSymbol(_endSymbol!, SymbolOptions(geometry: newCoords));
    }

    // Redraw polyline if both exist
    if (_startSymbol != null && _endSymbol != null) {
      if (_routeLine != null) {
        await mapController!.removeLine(_routeLine!);
      }
      
      LatLng startCoords = await mapController!.getSymbolLatLng(_startSymbol!) ?? _startSymbol!.options.geometry!;
      LatLng endCoords = await mapController!.getSymbolLatLng(_endSymbol!) ?? _endSymbol!.options.geometry!;

      final routeGeometry = await _fetchOsrmRoute([
        startCoords,
        endCoords,
      ]);
      _routeLine = await mapController!.addLine(
        LineOptions(
          geometry: routeGeometry,
          lineColor: '#F58842',
          lineWidth: 5.0,
          lineOpacity: 0.9,
          lineJoin: 'round',
        ),
      );
    }
  }

  Future<void> _fitBounds(List<LatLng> points) async {
    if (mapController == null || points.isEmpty) return;
    
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (var point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    await mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        left: 50,
        right: 50,
        top: 50,
        bottom: 50,
      ),
      duration: const Duration(milliseconds: 1000), // Smooth animation
    );
  }

  static const String _osrmBase = 'https://router.project-osrm.org/route/v1/driving';

  Future<List<LatLng>> _fetchOsrmRoute(List<LatLng> points) async {
    final coordStr = points.map((p) => '${p.longitude},${p.latitude}').join(';');
    final uri = Uri.parse('$_osrmBase/$coordStr?overview=full&geometries=geojson');

    for (int attempt = 0; attempt <= 2; attempt++) {
      try {
        final response = await ApiClient.get(uri, headers: {'User-Agent': 'RightRoutes/1.0'}, requireAuth: false);

        if (response.statusCode == 200) {
          final data = response.data;
          final routes = data['routes'] as List?;
          if (routes != null && routes.isNotEmpty) {
            final geometry = (routes[0] as Map<String, dynamic>)['geometry'] as Map<String, dynamic>;
            final coords = geometry['coordinates'] as List;
            return coords.map<LatLng>((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble())).toList();
          }
        }
      } catch (e) {
        debugPrint('OSRM attempt ${attempt + 1} failed: $e');
        if (attempt < 2) {
          await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
        }
      }
    }

    return List.from(points);
  }
}
