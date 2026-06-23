import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:dio/dio.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import 'package:right_routes/views/home/home_api_constant/home_api_constant.dart';
import 'package:right_routes/core/constants/services/api_client.dart';

// ─── Model ───────────────────────────────────────────────────────────────────
class DraftRouteModel {
  final String name;
  final String date;
  final int stops;
  const DraftRouteModel({
    required this.name,
    required this.date,
    required this.stops,
  });
}

// ─── Service ─────────────────────────────────────────────────────────────────
class CreateRouteService {
  static Future<Map<String, dynamic>> createRoute({
    required String name,
    required String startLocation,
    required String startLatitude,
    required String startLongitude,
    required String endLocation,
    required String endLatitude,
    required String endLongitude,
    required String permitText,
    File? permitFile,
  }) async {
    try {
      final url = Uri.parse(
        '${HomeApiConstant.baseUrl}${HomeApiConstant.routePost}',
      );

      debugPrint('🚀 [CreateRoute] Requesting: $url');
      
      Map<String, dynamic> dataMap = {
        'name': name,
        'start_location': startLocation,
        'start_latitude': startLatitude,
        'start_longitude': startLongitude,
        'end_location': endLocation,
        'end_latitude': endLatitude,
        'end_longitude': endLongitude,
        'permit_text': permitText,
      };

      if (permitFile != null) {
        dataMap['permit_file'] = await MultipartFile.fromFile(
          permitFile.path,
          filename: permitFile.path.split('/').last,
        );
      }

      FormData formData = FormData.fromMap(dataMap);

      final response = await ApiClient.sendMultipartRequest(
        url,
        data: formData,
        method: 'POST',
      );

      debugPrint('✅ [CreateRoute] Response Status: ${response.statusCode}');
      debugPrint('📄 [CreateRoute] Response Data: ${response.data}');

      final body = response.data is String ? jsonDecode(response.data) : response.data;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'id': body['route']?['id'],
          'name': body['route']?['name'] ?? name,
          'message': body['message'],
        };
      } else {
        return {
          'success': false,
          'statusCode': response.statusCode,
          'message': body['message'] ?? body['detail'] ?? 'Failed to create route',
        };
      }
    } catch (e) {
      debugPrint('❌ [CreateRoute] Error: $e');
      if (e is DioException) {
        final errBody = e.response?.data;
        final errMsg = (errBody is Map) ? (errBody['message'] ?? errBody['detail'] ?? 'Server error') : 'Server error';
        return {
          'success': false,
          'statusCode': e.response?.statusCode,
          'message': errMsg,
        };
      }
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }

  static Future<Map<String, dynamic>> updateRouteName({
    required int routeId,
    required String newName,
  }) async {
    try {
      final url = Uri.parse(
        '${HomeApiConstant.baseUrl}${HomeApiConstant.updateRouteName}$routeId/update-name/',
      );

      debugPrint('🚀 [UpdateRouteName] Requesting: $url');
      
      FormData formData = FormData.fromMap({
        'name': newName,
      });

      final response = await ApiClient.sendMultipartRequest(
        url,
        data: formData,
        method: 'PATCH',
      );

      debugPrint('✅ [UpdateRouteName] Response Status: ${response.statusCode}');
      debugPrint('📄 [UpdateRouteName] Response Data: ${response.data}');

      final body = response.data is String ? jsonDecode(response.data) : response.data;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': body['message'] ?? 'Route name updated successfully.',
        };
      } else {
        return {
          'success': false,
          'statusCode': response.statusCode,
          'message': body['message'] ?? body['detail'] ?? 'Failed to update route name',
        };
      }
    } catch (e) {
      debugPrint('❌ [UpdateRouteName] Error: $e');
      if (e is DioException) {
        final errBody = e.response?.data;
        final errMsg = (errBody is Map) ? (errBody['message'] ?? errBody['detail'] ?? 'Server error') : 'Server error';
        return {
          'success': false,
          'statusCode': e.response?.statusCode,
          'message': errMsg,
        };
      }
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }
}

// ─── Controller ──────────────────────────────────────────────────────────────
class HomeController extends GetxController {
  final RxInt currentPermitIndex = 1.obs;
  final RxBool isCreating = false.obs;
  final RxString errorMsg = ''.obs;

  // New State Variables
  final routeNameController = TextEditingController();
  final RxString startLocation = ''.obs;
  final RxString startLat = ''.obs;
  final RxString startLng = ''.obs;
  
  final RxString endLocation = ''.obs;
  final RxString endLat = ''.obs;
  final RxString endLng = ''.obs;
  
  final RxString permitText = ''.obs;
  final Rx<File?> permitFile = Rx<File?>(null);

  final RxList<DraftRouteModel> draftRoutes = <DraftRouteModel>[
    const DraftRouteModel(
        name: 'Downtown Loop', date: 'Apr 28, 2026', stops: 12),
    const DraftRouteModel(
        name: 'Warehouse District', date: 'Apr 25, 2026', stops: 8),
    const DraftRouteModel(
        name: 'North Side Delivery', date: 'Apr 22, 2026', stops: 15),
  ].obs;

  @override
  void onClose() {
    routeNameController.dispose();
    super.onClose();
  }

  void resetError() {
    errorMsg.value = '';
    isCreating.value = false;
  }

  Future<void> submitCreateRoute() async {
    final name = routeNameController.text.trim();
    if (name.isEmpty) {
      errorMsg.value = 'Route name is required';
      Get.snackbar('Validation Error', errorMsg.value, backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (startLat.value.isEmpty || startLng.value.isEmpty) {
      errorMsg.value = 'Start location is required (Tap on the map)';
      Get.snackbar('Validation Error', errorMsg.value, backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (endLat.value.isEmpty || endLng.value.isEmpty) {
      errorMsg.value = 'End location is required (Tap on the map again)';
      Get.snackbar('Validation Error', errorMsg.value, backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isCreating.value = true;
    errorMsg.value = '';

    debugPrint('🔘 [HomeController] Submitting Create Route: $name');
    final result = await CreateRouteService.createRoute(
      name: name,
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
      Get.snackbar('Success', result['message'] ?? 'Route created successfully', backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      Get.toNamed(
        AppRoutes.confirmYourRoutes, // Adjust as needed if the route changes
        arguments: {
          'routeName': result['name'],
          'routeId': result['id'],
        },
      );
    } else {
      String msg = result['message'] ?? 'Failed to create route';
      if (result['statusCode'] != null) {
        msg = 'Error ${result['statusCode']}: $msg';
      }
      errorMsg.value = msg;
      Get.snackbar('Error', msg, backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 4));
    }
  }

  // Method to update route name
  Future<void> updateRouteName(int routeId, String newName) async {
    if (newName.trim().isEmpty) return;

    final result = await CreateRouteService.updateRouteName(routeId: routeId, newName: newName.trim());

    if (result['success'] == true) {
      Get.snackbar('Success', result['message'] ?? 'Route name updated', backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    } else {
      String msg = result['message'] ?? 'Failed to update route name';
      if (result['statusCode'] != null) {
        msg = 'Error ${result['statusCode']}: $msg';
      }
      Get.snackbar('Error', msg, backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 4));
    }
  }
}
