import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:right_routes/global_widgets/custom_info_dialog.dart';

void dialogMap(BuildContext context) {
  showCustomInfoDialog(
    context: context,
    icon: Icon(
      Icons.location_on,
      color: Colors.white,
      size: 24.sp,
    ),
    texts: [
      'The green "S" point is your current location.',
      'The red "E" point is your ending location for this permit.',
      'Use a finger to move the Start and End points as close as possible to the start and end locations from your permit. They don\'t have to be exact.',
      'Pinch the map with two fingers to zoom out. Spread two fingers to zoom in. Move the map with one finger.',
      'The "S" and "E" points form the boundary into which the waypoints from your permit will fit between.',
    ],
  );
}

void dialogMapForSubsequentPermit(BuildContext context) {
  showCustomInfoDialog(
    context: context,
    icon: Icon(
      Icons.location_on,
      color: Colors.white,
      size: 24.sp,
    ),
    texts: [
      'The green "S" point is location of the previous permit\'s end point. DO NOT MOVE THIS POINT.',
      'Move the red "E" point near the ending location for this permit.',
    ],
  );
}
