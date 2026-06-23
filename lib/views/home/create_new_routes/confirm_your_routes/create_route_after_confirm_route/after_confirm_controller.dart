import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:right_routes/views/home/create_new_routes/home_controller.dart';

class AfterConfirmController extends GetxController {
  final RxBool isCreating = false.obs;
  final RxBool isFetchingLocation = false.obs;
  final RxString errorMsg = ''.obs;

  final RxString startLocation = ''.obs;
  final RxString startLat = ''.obs;
  final RxString startLng = ''.obs;
  
  final RxString endLocation = ''.obs;
  final RxString endLat = ''.obs;
  final RxString endLng = ''.obs;
  
  final RxString permitText = ''.obs;
  final Rx<File?> permitFile = Rx<File?>(null);
  final RxString activeAction = ''.obs;

  void resetError() {
    errorMsg.value = '';
    isCreating.value = false;
  }

  Future<void> initSubsequentPermit(String routeId) async {
    endLocation.value = '';
    endLat.value = '';
    endLng.value = '';
    permitText.value = '';
    permitFile.value = null;
    activeAction.value = '';
    
    isFetchingLocation.value = true;
    final res = await CreateRouteService.fetchPermitStartingPoint(routeId);
    if (res['success']) {
      final data = res['data'];
      startLocation.value = data['start_location_name'] ?? '';
      startLat.value = data['start_latitude']?.toString() ?? '';
      startLng.value = data['start_longitude']?.toString() ?? '';
    }
    isFetchingLocation.value = false;
  }

  Future<bool> submitCreateSubsequentPermit(String routeId) async {
    if (endLat.value.isEmpty || endLng.value.isEmpty) {
      errorMsg.value = 'End location is required';
      Get.snackbar('Error', errorMsg.value, backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 1));
      return false;
    }
    if (permitText.value.isEmpty && permitFile.value == null) {
      errorMsg.value = 'Document is required';
      Get.snackbar('Error', errorMsg.value, backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 1));
      return false;
    }

    isCreating.value = true;
    errorMsg.value = '';

    final result = await CreateRouteService.createSubsequentPermit(
      routeId: routeId,
      startLocation: startLocation.value.isEmpty ? 'Unknown Start' : startLocation.value,
      startLatitude: startLat.value,
      startLongitude: startLng.value,
      endLocation: endLocation.value.isEmpty ? 'Unknown End' : endLocation.value,
      endLatitude: endLat.value,
      endLongitude: endLng.value,
      permitText: permitText.value,
      permitFile: permitFile.value,
    );

    isCreating.value = false;

    if (result['success'] == true) {
      Get.snackbar('Success', result['message'] ?? 'Permit created successfully', backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 1));
      return true;
    } else {
      String msg = result['message'] ?? 'Failed to create permit';
      errorMsg.value = msg;
      Get.snackbar('Error', msg, backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 2));
      return false;
    }
  }
}
