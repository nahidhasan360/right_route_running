import 'package:right_routes/core/constants/services/api_client.dart';
import '../../../core/constants/services/auth_service.dart';
import '../../../core/constants/api_config/api_config.dart';

class ChangeEmailService {
  // 🔥 Change Email API Call
  static Future<Map<String, dynamic>> changeEmail(String newEmail) async {
    try {
      // 🔑 AuthService থেকে Access Token নিচ্ছি
      String? token = await AuthService.getAccessToken();

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📤 API REQUEST');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🌐 URL: ${ApiConfig.fullChangeEmailUrl}');
      print('📧 New Email: $newEmail');
      print('🔑 Token: ${token ?? "❌ No token found"}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      final response = await ApiClient.post(
        Uri.parse(ApiConfig.fullChangeEmailUrl),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: {
          'email': newEmail,
        },
      );

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📥 API RESPONSE');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📊 Status Code: ${response.statusCode}');
      print('📦 Response Data: ${response.data}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // ✅ Success Response
        final data = response.data;

        print('✅ SUCCESS: Email changed successfully!\n');

        // 💾 AuthService এ email update করছি
        await AuthService.updateUserEmail(newEmail);

        return {
          'success': true,
          'message': data is Map ? (data['message'] ?? 'Email changed successfully') : 'Email changed successfully',
          'data': data,
        };
      } else {
        // ❌ Error Response from Server
        final error = response.data;

        print('❌ ERROR: $error\n');

        return {
          'success': false,
          'message': (error is Map) 
              ? (error['message'] ?? error['email']?.first ?? 'Failed to change email') 
              : 'Failed to change email',
        };
      }
    } catch (e) {
      // ❌ Network Error or Exception
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('❌ EXCEPTION OCCURRED');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('Error: $e');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }
}
