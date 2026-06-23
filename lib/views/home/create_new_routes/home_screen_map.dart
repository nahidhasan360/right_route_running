import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:get/get.dart';
import 'package:geocoding/geocoding.dart';
import 'package:right_routes/views/home/create_new_routes/home_controller.dart';

class HomeScreenMap extends StatefulWidget {
  const HomeScreenMap({super.key});

  @override
  State<HomeScreenMap> createState() => _HomeScreenMapState();
}

class _HomeScreenMapState extends State<HomeScreenMap> {
  MapLibreMapController? mapController;
  final HomeController _ctrl = Get.find<HomeController>();

  Symbol? _startSymbol;
  Symbol? _endSymbol;

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
        onMapCreated: (controller) {
          mapController = controller;
        },
        onMapClick: _onMapClick,
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
          Factory<OneSequenceGestureRecognizer>(
            () => EagerGestureRecognizer(),
          ),
        },
      ),
    );
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
          textColor: '#FFFFFF',
          textHaloColor: '#00FF00', // Green halo for S
          textHaloWidth: 2,
          textSize: 20,
          textOffset: const Offset(0, -1),
        ),
      );
      _ctrl.startLat.value = coordinates.latitude.toString();
      _ctrl.startLng.value = coordinates.longitude.toString();
      _ctrl.startLocation.value = locationName;
      Get.snackbar('Start Point Selected', locationName, backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    } else if (_endSymbol == null) {
      // Set End Location
      _endSymbol = await mapController!.addSymbol(
        SymbolOptions(
          geometry: coordinates,
          textField: 'E',
          textColor: '#FFFFFF',
          textHaloColor: '#FF0000', // Red halo for E
          textHaloWidth: 2,
          textSize: 20,
          textOffset: const Offset(0, -1),
        ),
      );
      _ctrl.endLat.value = coordinates.latitude.toString();
      _ctrl.endLng.value = coordinates.longitude.toString();
      _ctrl.endLocation.value = locationName;
      Get.snackbar('End Point Selected', locationName, backgroundColor: Colors.orange, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    } else {
      // Reset if both are set and clicked again
      await mapController!.removeSymbol(_startSymbol!);
      await mapController!.removeSymbol(_endSymbol!);
      _startSymbol = null;
      _endSymbol = null;
      _ctrl.startLat.value = '';
      _ctrl.startLng.value = '';
      _ctrl.startLocation.value = '';
      _ctrl.endLat.value = '';
      _ctrl.endLng.value = '';
      _ctrl.endLocation.value = '';
      Get.snackbar('Map Reset', 'Tap to select Start point again.', backgroundColor: Colors.blue, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    }
  }
}
