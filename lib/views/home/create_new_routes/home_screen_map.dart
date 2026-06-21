import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class HomeScreenMap extends StatelessWidget {
  const HomeScreenMap({super.key});

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
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
          Factory<OneSequenceGestureRecognizer>(
            () => EagerGestureRecognizer(),
          ),
        },
      ),
    );
  }
}
