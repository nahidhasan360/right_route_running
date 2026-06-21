import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import 'package:right_routes/utils/colors.dart';
import 'package:right_routes/views/authentication/enter_email_screen/enter_email_screen.dart';
import '../../../global_widgets/custom_buttons.dart';
import '../../../global_widgets/custom_troggle_button.dart';
import '../../../utils/assets_manager.dart';
import 'package:get/get.dart';
import 'package:right_routes/controllers/auth/login_controller.dart';
import 'package:right_routes/controllers/auth/enter_email_controller.dart';

/// ═══════════════════════════════════════════════════════════
/// LoginAccount - Screen with Updated Controller Integration
/// ═══════════════════════════════════════════════════════════
class LoginAccount extends StatelessWidget {
  LoginAccount({super.key});

  final loginTroggleController = Get.put(ToggleController());
  final controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
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
        child: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 450),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 40.h),

                    // Logo
                    Container(
                      width: 225.w,
                      height: 112.h,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(ImageManager.splashScreenLogo),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    SizedBox(height: 21.h),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// TITLE
                        Text(
                          'Good News you already have a Right Route account',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25.sp,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w700,
                            height: 1.12.h,
                          ),
                        ),

                        SizedBox(height: 17.h),

                        /// EMAIL TEXT
                        Text(
                          'Since you\'ve already used your email to sign up for this service, you can now log in using',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w500,
                            height: 1.44.h,
                          ),
                        ),

                        /// EMAIL DISPLAY + EDIT BUTTON
                        Obx(() {
                          final String email =
                              controller.userEmail.value.trim();
                          final String displayEmail =
                              email.isEmpty ? 'Your email...' : email;

                          return Row(
                            children: [
                              Flexible(
                                child: Text(
                                  displayEmail,
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 18.sp,
                                    fontFamily: 'Lato',
                                    fontWeight: FontWeight.bold,
                                    height: 1.44.h,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              GestureDetector(
                                onTap: () {
                                  // Go back to the previous EnterEmailScreen if it's in the stack
                                  // This prevents GetX from incorrectly disposing the controller during transition
                                  if (Get.previousRoute ==
                                          AppRoutes.enterEmailScreen ||
                                      Get.previousRoute ==
                                          '/EnterEmailScreen') {
                                    Get.back();
                                  } else {
                                    Get.to(() => EnterEmailScreen());
                                  }
                                },
                                child: Text(
                                  'edit',
                                  style: TextStyle(
                                    color: AppColors.purple,
                                    fontSize: 18.sp,
                                    fontFamily: 'Lato',
                                    fontWeight: FontWeight.bold,
                                    height: 1.44.h,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),

                        SizedBox(height: 14.h),

                        Text(
                          'Enter your current password to log in.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w500,
                            height: 1.56.h,
                          ),
                        ),

                        SizedBox(height: 9.h),

                        /// PASSWORD FIELD
                        Container(
                          height: 57.h,
                          padding: EdgeInsets.symmetric(horizontal: 14.w),
                          decoration: BoxDecoration(
                            color: AppColors.medGray,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Obx(
                                  () => TextField(
                                    controller: controller.passwordController,
                                    obscureText: controller.hidePassword.value,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.sp,
                                      fontFamily: 'Lato',
                                      fontWeight: FontWeight.w400,
                                      height: 1.4.h,
                                      letterSpacing: 0.2,
                                    ),
                                    onSubmitted: (_) {
                                      // ✅ Submit on Enter key
                                      if (!controller.isLoading.value) {
                                        controller.login();
                                      }
                                    },
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'password',
                                      hintStyle: TextStyle(
                                        color: const Color(0xFFBFBFBF),
                                        fontSize: 16.sp,
                                        fontFamily: 'Lato',
                                        fontWeight: FontWeight.w400,
                                      ),
                                      isDense: true,
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 14.h),
                                    ),
                                  ),
                                ),
                              ),
                              Obx(
                                () => IconButton(
                                  icon: Icon(
                                    controller.hidePassword.value
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.white54,
                                  ),
                                  onPressed: () => controller.togglePassword(),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 24.h),

                        /// LOGIN BUTTON + FINGERPRINT
                        Row(
                          children: [
                            Expanded(
                              child: Obx(
                                () => CustomButton(
                                  text: controller.isLoading.value ? 'LOADING...' : 'LOG IN',
                                  onPressed: controller.isLoading.value
                                      ? null
                                      : () {
                                          controller.login();
                                        },
                                  isLoading: controller.isLoading.value,
                                  showSpinner: false,
                                  height: 58.h,
                                ),
                              ),
                            ),
                            SizedBox(width: 10.w),

                            /// FINGERPRINT BUTTON
                            Obx(
                              () => GestureDetector(
                                onTap: controller.isLoading.value ||
                                        controller.availableBiometrics.isEmpty
                                    ? null
                                    : () async {
                                        print(
                                            '\n👆 Fingerprint button pressed!');
                                        await controller
                                            .authenticateWithBiometrics();
                                      },
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 150),
                                  height: 53.h,
                                  width: 55.w,
                                  decoration: BoxDecoration(
                                    color: controller.isLoading.value ||
                                            controller
                                                .availableBiometrics.isEmpty
                                        ? AppColors.orange.withValues(alpha: 0.5)
                                        : AppColors.orange,
                                    borderRadius: BorderRadius.circular(50.r),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.fingerprint,
                                      color: AppColors.white,
                                      size: 45.r,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 15.h),

                        /// TOUCH ID SWITCH
                        Row(
                          children: [
                            Obx(
                              () => CustomToggleSwitchAdvanced(
                                height: 24.h,
                                width: 51.w,
                                value: controller.isTouchIDEnabled.value
                                    ? loginTroggleController.isEnabled
                                    : RxBool(false),
                                onChanged: (val) {
                                  controller.toggleTouchID(val);
                                },
                                activeSvgPath: 'assets/icons/Check-orange.svg',
                                svgColor: AppColors.orange,
                                activeColor: AppColors.orange,
                                inactiveColor: Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                            SizedBox(width: 7.w),
                            Text(
                              'Use touch ID',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 45.h),

                        /// TROUBLE LOGGING IN - OTP SEND
                        Obx(
                          () => GestureDetector(
                            onTap: controller.isSendingOtp.value ||
                                    controller.isLoading.value
                                ? null
                                : () async {
                                    await controller.sendOtpAndNavigate();
                                  },
                            child: controller.isSendingOtp.value
                                ? Row(
                                    children: [
                                      SizedBox(
                                        width: 16.w,
                                        height: 16.h,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Color(0xFF9DACF5),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10.w),
                                      Text(
                                        'Sending OTP...',
                                        style: TextStyle(
                                          color: const Color(0xFF9DACF5),
                                          fontSize: 16.sp,
                                          fontFamily: 'Lato',
                                          fontWeight: FontWeight.w500,
                                          height: 1.38.h,
                                        ),
                                      ),
                                    ],
                                  )
                                : Text(
                                    'Having trouble logging in? Send a one time code.',
                                    style: TextStyle(
                                      color: const Color(0xFF9DACF5),
                                      fontSize: 16.sp,
                                      fontFamily: 'Lato',
                                      fontWeight: FontWeight.w500,
                                      height: 1.38.h,
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                          ),
                        ),

                        SizedBox(height: 20.h),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
