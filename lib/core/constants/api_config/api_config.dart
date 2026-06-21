// lib/config/api_config.dart

/// API Configuration for Right Routes App
/// Manages different API endpoints for development and production
class ApiConfig {
  // ========== ENVIRONMENT TOGGLE ==========
  /// Set to true for development, false for production
  static const bool isDevelopment = true;

  // ========== DEVICE TYPE CONFIGURATION ==========
  /// Change this based on where you're testing
  static const DeviceType currentDevice = DeviceType.realDevice;

  // ========== BASE URLs ==========
  static String get baseUrl {
    if (isDevelopment) {
      // Development URLs
      switch (currentDevice) {
        case DeviceType.androidEmulator:
          return 'http://16.192.4.30:8003/api/v1'; // Android emulator
        case DeviceType.iosSimulator:
          return 'http://16.192.4.30:8003/api/v1'; // iOS simulator
        case DeviceType.realDevice:
          return 'http://16.192.4.30:8003/api/v1'; // Your actual backend IP
      }
    } else {
      // Production URL
      return 'https://api.rightroutes.com'; // Replace with your production domain
    }
  }

  // ========== API ENDPOINTS ==========

  static const String checkEmailEndpoint = '/auth/continue/';
  

  static const String processOcrEndpoint = '/auth/api/process-ocr/';
  static const String loginEndpoint = '/auth/login/';
  static const String createPasswordEndpoint = '/auth/create-password/';
  static const String registerEndpoint = '/auth/register/';
  static const String profileEndpoint = '/auth/profile/';
  static const String requestOtpEndpoint = '/auth/request-otp/';
  static const String verifyOtpEndpoint = '/auth/verify-otp/';
  static const String changeEmailEndpoint = '/auth/change-email/';
  static const String changePasswordEndpoint = '/auth/change-password/';
  static const String verifyTokenEndpoint = '/auth/verify-token/';
  static const String refreshTokenEndpoint = '/auth/refresh-token/';

  static const String logoutEndpoint = '/auth/logout/';

  // ========== FULL URLs ==========
  // static String get fullOcrUrl => '$baseUrl$processOcrEndpoint';

  static String get fullOcrUrl => '$baseUrl$processOcrEndpoint';
  static String get fullUrl => fullOcrUrl; // ✅ Alias for backward compatibility
  static String get fullLoginUrl => '$baseUrl$loginEndpoint';
  static String get fullCreatePasswordUrl => '$baseUrl$createPasswordEndpoint';
  static String get fullRegisterUrl => '$baseUrl$registerEndpoint';
  static String get fullProfileUrl => '$baseUrl$profileEndpoint';
  static String get fullCheckEmailUrl => '$baseUrl$checkEmailEndpoint';
  static String get fullRequestOtpUrl => '$baseUrl$requestOtpEndpoint';
  static String get fullVerifyOtpUrl => '$baseUrl$verifyOtpEndpoint';
  static String get fullChangeEmailUrl => '$baseUrl$changeEmailEndpoint';
  static String get fullChangePasswordUrl => '$baseUrl$changePasswordEndpoint';
  static String get fullVerifyTokenUrl => '$baseUrl$verifyTokenEndpoint';
  static String get fullRefreshTokenUrl => '$baseUrl$refreshTokenEndpoint';
  static String get fullLogoutUrl => '$baseUrl$logoutEndpoint';

  // ========== TIMEOUT CONFIGURATIONS ==========
  static const Duration connectionTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 60);

  // ========== FILE UPLOAD LIMITS ==========
  static const int maxFileSize = 10 * 1024 * 1024; // 10 MB
  static const List<String> allowedFileTypes = ['pdf', 'png', 'jpg', 'jpeg'];

  // ========== DEBUG INFO ==========
  static void printConfig() {
    print('🔧 API Configuration:');
    print('📍 Environment: ${isDevelopment ? "Development" : "Production"}');
    print('📱 Device Type: ${currentDevice.name}');
    print('🌐 Base URL: $baseUrl');
    print('🔗 OCR Endpoint: $fullOcrUrl');
  }
}

// ========== DEVICE TYPE ENUM ==========
enum DeviceType {
  androidEmulator,
  iosSimulator,
  realDevice,
}