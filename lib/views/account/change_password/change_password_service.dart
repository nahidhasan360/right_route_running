import 'package:right_routes/core/constants/services/api_client.dart';
import '../../../core/constants/api_config/api_config.dart';

class ChangePasswordService {
  static Future<Map<String, dynamic>> changePassword(String newPassword) async {
    try {
      final url = Uri.parse(ApiConfig.fullChangePasswordUrl);

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📤 API REQUEST - CHANGE PASSWORD');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🌐 URL: $url');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      final response = await ApiClient.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: {'new_password': newPassword},
        // requireAuth is true by default, so ApiClient automatically attaches the token
      );

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📥 API RESPONSE - CHANGE PASSWORD');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📊 Status Code: ${response.statusCode}');
      print('📦 Response Data: ${response.data}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        return {
          'success': true,
          'message': data is Map ? (data['message'] ?? 'Password changed successfully') : 'Password changed successfully',
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': _extractError(response.data, 'Failed to change password'),
        };
      }
    } catch (e) {
      print('❌ EXCEPTION: $e');
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  static String _extractError(dynamic data, String fallback) {
    try {
      if (data is Map) {
        if (data['message'] != null) return data['message'].toString();
        if (data['detail'] != null) return data['detail'].toString();
        if (data['new_password'] != null && data['new_password'] is List) {
          return data['new_password'].first.toString();
        }
      }
      return data?.toString() ?? fallback;
    } catch (_) {
      return fallback;
    }
  }
}
