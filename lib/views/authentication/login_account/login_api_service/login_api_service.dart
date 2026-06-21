import 'package:right_routes/core/constants/services/api_client.dart';
import '../../../../core/constants/api_config/api_config.dart';

/// ───────────────────────────────────────────────────────────
/// LoginApiService - Login, Send OTP, Verify OTP
/// ───────────────────────────────────────────────────────────
class LoginApiService {
  // ─── LOGIN ────────────────────────────────────────────────
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.fullLoginUrl);
      debugLog('LOGIN', 'POST $url | email: $email');

      final response = await ApiClient.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: {'email': email, 'password': password},
        requireAuth: false,
      );

      debugLog('LOGIN', '${response.statusCode} | ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        return {
          'success': true,
          'data': data is Map ? data : {},
          'message': data is Map ? (data['detail']?.toString() ?? 'OTP sent successfully') : 'OTP sent successfully',
        };
      } else {
        return {
          'success': false,
          'message': _extractError(response.data, 'Login failed'),
        };
      }
    } catch (e) {
      debugLog('LOGIN', 'EXCEPTION: $e');
      return {
        'success': false,
        'message': 'Network error. Please check your connection.'
      };
    }
  }

  // ─── SEND OTP ─────────────────────────────────────────────
  Future<Map<String, dynamic>> sendOtp({required String email}) async {
    try {
      final url = Uri.parse(ApiConfig.fullRequestOtpUrl);
      debugLog('SEND-OTP', 'POST $url | email: $email');

      final response = await ApiClient.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: {'email': email},
        requireAuth: false,
      );

      debugLog('SEND-OTP', '${response.statusCode} | ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        return {
          'success': true,
          'message': (data is Map && data['message'] != null) ? data['message'] : 'OTP sent successfully'
        };
      } else {
        return {
          'success': false,
          'message': _extractError(response.data, 'Failed to send OTP')
        };
      }
    } catch (e) {
      debugLog('SEND-OTP', 'EXCEPTION: $e');
      return {
        'success': false,
        'message': 'Network error. Please check your connection.'
      };
    }
  }

  // ─── VERIFY OTP ───────────────────────────────────────────
  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otpCode,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.fullVerifyOtpUrl);
      debugLog('VERIFY-OTP', 'POST $url | email: $email, otp: $otpCode');

      final response = await ApiClient.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: {'email': email.trim(), 'otp_code': otpCode.trim()},
        requireAuth: false,
      );

      debugLog('VERIFY-OTP', '${response.statusCode} | ${response.data}');

      final data = response.data;

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          (data is Map && (data['success'] == null || data['success'] == true))) {
        return {
          'success': true,
          'data': data,
          'message': data['message'] ?? 'OTP verified'
        };
      } else {
        return {
          'success': false,
          'message': _extractError(response.data, 'Invalid OTP')
        };
      }
    } catch (e) {
      debugLog('VERIFY-OTP', 'EXCEPTION: $e');
      return {
        'success': false,
        'message': 'Network error. Please check your connection.'
      };
    }
  }

  // ─── HELPERS ──────────────────────────────────────────────
  String _extractError(dynamic data, String fallback) {
    try {
      if (data is Map) {
        // Handle nested detail: {"detail": {"otp": "OTP expired"}}
        if (data['detail'] != null) {
          if (data['detail'] is Map) {
            final detail = data['detail'] as Map;
            final firstValue = detail.values.first;
            if (firstValue is List && firstValue.isNotEmpty) {
              return firstValue.first.toString();
            }
            return firstValue.toString();
          }
          return data['detail'].toString();
        }
        return data['message']?.toString() ??
            data['error']?.toString() ??
            fallback;
      }
      return data.toString();
    } catch (_) {
      return fallback;
    }
  }

  void debugLog(String tag, String msg) {
    print('[$tag] $msg');
  }
}
