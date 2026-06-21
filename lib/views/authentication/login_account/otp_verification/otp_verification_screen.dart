import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../../utils/assets_manager.dart';
import '../../../../utils/colors.dart';
import 'package:right_routes/global_widgets/custom_buttons.dart';
import 'package:right_routes/controllers/auth/otp_verification_controller.dart';

/// ═══════════════════════════════════════════════════════════
/// OtpVerificationScreenlogin - Updated with API Integration
/// ═══════════════════════════════════════════════════════════
class OtpVerificationScreen extends StatelessWidget {
  const OtpVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OtpVerificationController>();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(ImageManager.mapBackground),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 40.h),

                /// LOGO
                Center(
                  child: Container(
                    width: 225.w,
                    height: 112.h,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(ImageManager.splashScreenLogo),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 21.h),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// TITLE
                    Text(
                      "Check your email inbox",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25.sp,
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w700,
                        height: 1.12.h,
                      ),
                    ),

                    SizedBox(height: 21.h),

                    /// SUBTITLE WITH EMAIL
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text:
                                "We'll need you to verify your email address. We've sent a 6-digit code to ",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.sp,
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(
                            text: controller.email,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.sp,
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.bold,
                              height: 1.44.h,
                            ),
                          ),
                          TextSpan(
                            text:
                                ' The code expires in 15 minutes. Please enter it below.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.sp,
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w500,
                              height: 1.44.h,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 28.h),

                    /// PIN CODE FIELD
                    PinCodeTextField(
                      length: 6,
                      appContext: context,
                      controller: controller.otpController,
                      animationType: AnimationType.fade,
                      keyboardType: TextInputType.number,
                      obscureText: false,
                      cursorColor: Colors.black,
                      textStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(5.r),
                        fieldHeight: 57.h,
                        fieldWidth: 57.w,
                        inactiveColor: Colors.transparent,
                        selectedColor: AppColors.orange,
                        activeColor: Colors.white,
                        inactiveFillColor: AppColors.medGray,
                        activeFillColor: Colors.white.withValues(alpha: 0.85),
                        selectedFillColor: Colors.white,
                      ),
                      enableActiveFill: true,
                      onChanged: controller.onOtpChanged,
                      onCompleted: (value) {
                        // Auto verify when 6 digits entered
                        controller.verifyOtp();
                      },
                    ),

                    SizedBox(height: 18.h),

                    /// CONTINUE BUTTON
                    Obx(
                      () => CustomButton(
                        text: controller.isVerifying.value
                            ? 'LOADING...'
                            : 'CONTINUE',
                        onPressed: controller.isVerifying.value
                            ? null
                            : () {
                                // ✅ Call verify OTP API
                                controller.verifyOtp();
                              },
                        isLoading: controller.isVerifying.value,
                        showSpinner: false,
                        height: 58.h,
                      ),
                    ),

                    SizedBox(height: 29.h),

                    /// CANCEL BUTTON
                    CustomButton(
                      text: 'CANCEL',
                      backgroundColor: AppColors.medGray,
                      onPressed: () {
                        Get.back();
                      },
                      height: 55.h,
                    ),

                    SizedBox(height: 53.h),

                    /// RESEND OTP
                    Obx(
                      () => RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  "Didn't receive the mail? Check your spam folder or ",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.sp,
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w500,
                                height: 1.38.h,
                              ),
                            ),
                            TextSpan(
                              text: controller.isResending.value
                                  ? "Sending..."
                                  : "Resend",
                              style: TextStyle(
                                color: controller.isResending.value
                                    ? AppColors.purple.withValues(alpha: 0.5)
                                    : AppColors.purple,
                                fontSize: 16.sp,
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w500,
                                height: 1.38.h,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = controller.isResending.value
                                    ? null
                                    : () {
                                        controller.resendOtp();
                                      },
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 40.h),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
