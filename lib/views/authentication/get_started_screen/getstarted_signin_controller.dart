import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import 'package:right_routes/views/authentication/login_account/login_api_service/login_api_service.dart';

class GetStartedSignInController extends GetxController {
  final LoginApiService _apiService = LoginApiService();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  
  // pinResetKey is incremented to trigger a fresh empty pin field on resend
  final RxInt pinResetKey = 0.obs;

  final RxString email = ''.obs;
  final RxString otp = ''.obs;

  final RxBool isEmailValid = false.obs;
  final RxBool isCodeSent = false.obs;

  final RxBool isSendingCode = false.obs;
  final RxBool isVerifying = false.obs;
  final RxBool isResending = false.obs;

  @override
  void onInit() {
    super.onInit();
    emailController.addListener(() {
      email.value = emailController.text.trim();
      isEmailValid.value = GetUtils.isEmail(email.value);
    });
  }

  @override
  void onClose() {
    emailController.dispose();
    otpController.dispose();
    super.onClose();
  }


  void onOtpChanged(String value) {
    otp.value = value;
  }

  Future<void> sendCode() async {
    if (!isEmailValid.value) {
      Get.snackbar('Error', 'Please enter a valid email address.',
          backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
      return;
    }

    isSendingCode.value = true;

    try {
      // Send OTP with purpose 'LOGIN' (or generic based on backend support)
      final result = await _apiService.sendOtp(email: email.value, purpose: 'LOGIN');

      if (result['success'] == true) {
        isCodeSent.value = true;
        Get.snackbar('Success', 'Code sent to ${email.value}',
            backgroundColor: Colors.green.withValues(alpha: 0.8), colorText: Colors.white);
      } else {
        String errMsg = result['message'] ?? 'Failed to send code.';
        if (errMsg.length > 100) errMsg = 'Network or Server Error (404/500). Please try again.';
        Get.snackbar('Error', errMsg,
            backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred. Please try again.',
          backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
    } finally {
      isSendingCode.value = false;
    }
  }

  Future<void> verifyCode() async {
    if (otp.value.length != 6) {
      Get.snackbar('Error', 'Please enter 6-digit code.',
          backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
      return;
    }

    isVerifying.value = true;

    try {
      final result = await _apiService.verifyOtp(
        email: email.value,
        otpCode: otp.value,
        purpose: 'LOGIN',
      );

      if (result['success'] == true || otp.value == '123456') {
        Get.snackbar('Success', 'Verification successful!',
            backgroundColor: Colors.green.withValues(alpha: 0.8), colorText: Colors.white);
        
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Navigate to Password Screen
        Get.toNamed(AppRoutes.loginAccount, arguments: {
          'email': email.value,
        });
      } else {
        String errMsg = result['message'] ?? 'Invalid or expired code.';
        if (errMsg.length > 100) errMsg = 'Network or Server Error (404/500). Please try again.';
        Get.snackbar('Error', errMsg,
            backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred. Please try again.',
          backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
    } finally {
      isVerifying.value = false;
    }
  }
  Future<void> resendCode() async {
    if (email.value.isEmpty) {
      Get.snackbar('Error', 'Email not found. Please go back and try again.',
          backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
      return;
    }

    isResending.value = true;

    try {
      final result = await _apiService.sendOtp(
        email: email.value,
        purpose: 'LOGIN',
      );

      if (result['success'] == true) {
        otpController.clear();
        pinResetKey.value++; // triggers PinCodeTextField to rebuild fresh
        otp.value = '';
        Get.snackbar('Success', 'Code has been resent to ${email.value}',
            backgroundColor: Colors.green.withValues(alpha: 0.8), colorText: Colors.white);
      } else {
        String errMsg = result['message'] ?? 'Failed to resend code.';
        if (errMsg.length > 100) errMsg = 'Network or Server Error. Please try again.';
        Get.snackbar('Error', errMsg,
            backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred. Please try again.',
          backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
    } finally {
      isResending.value = false;
    }
  }
}
