import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  }) async {
    try {
      final url = Uri.parse(
        '${HomeApiConstant.baseUrl}${HomeApiConstant.createRoute}',
      );

      debugPrint('🚀 [CreateRoute] Requesting: $url');
      debugPrint('📦 [CreateRoute] Body: ${jsonEncode({
            'name': name,
            'description': ''
          })}');

      final response = await ApiClient.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: {'name': name, 'description': ''},
      );

      debugPrint('✅ [CreateRoute] Response Status: ${response.statusCode}');
      debugPrint('📄 [CreateRoute] Response Data: ${response.data}');

      final body = response.data;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'id': body['id'],
          'name': body['name'] ?? name,
        };
      } else {
        return {
          'success': false,
          'message':
              body['message'] ?? body['detail'] ?? 'Failed to create route',
        };
      }
    } catch (e) {
      debugPrint('❌ [CreateRoute] Error: $e');
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }
}

// ─── Controller ──────────────────────────────────────────────────────────────
class HomeController extends GetxController {
  final RxInt currentPermitIndex = 1.obs;
  final RxBool isCreating = false.obs;
  final RxString errorMsg = ''.obs;

  final RxList<DraftRouteModel> draftRoutes = <DraftRouteModel>[
    const DraftRouteModel(
        name: 'Downtown Loop', date: 'Apr 28, 2026', stops: 12),
    const DraftRouteModel(
        name: 'Warehouse District', date: 'Apr 25, 2026', stops: 8),
    const DraftRouteModel(
        name: 'North Side Delivery', date: 'Apr 22, 2026', stops: 15),
  ].obs;

  void resetError() {
    errorMsg.value = '';
    isCreating.value = false;
  }

  // ✅ name directly receive করে — controller এ TextEditingController নেই
  Future<void> submitCreateRoute(String name) async {
    if (name.trim().isEmpty) {
      errorMsg.value = 'Route name is required';
      return;
    }

    isCreating.value = true;
    errorMsg.value = '';

    debugPrint('🔘 [HomeController] Submitting Create Route: $name');
    final result = await CreateRouteService.createRoute(name: name.trim());

    isCreating.value = false;

    if (result['success'] == true) {
      debugPrint(
          "🔄 [Navigation] Navigating from Homescreen -> AddPermitScreen");
      debugPrint(
          "📦 [Navigation Arguments] routeName: ${result['name']}, routeId: ${result['id']}");

      Get.back(); // close dialog
      Get.toNamed(
        AppRoutes.addPermitScreen,
        arguments: {
          'routeName': result['name'],
          'routeId': result['id'],
        },
      );
    } else {
      errorMsg.value = result['message'] ?? 'Failed to create route';
    }
  }
}
