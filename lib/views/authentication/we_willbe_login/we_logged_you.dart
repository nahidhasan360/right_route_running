import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import 'package:right_routes/global_widgets/custom_buttons.dart';
import 'package:right_routes/utils/responsive_ext.dart';
import '../../../utils/assets_manager.dart';
import '../../../utils/colors.dart';
import 'package:right_routes/controllers/auth/login_controller.dart';

class WeLoggedYou extends StatelessWidget {
  WeLoggedYou({super.key});

  final loginController = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    final bool isLandscape = context.landscape;

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
          child: Padding(
            padding: isLandscape
                ? EdgeInsets.all(12.sp)
                : EdgeInsets.only(
                    top: 20.h,
                    left: 20.w,
                    right: 20.w,
                    bottom: 20.h,
                  ),
            child: Flex(
              direction: isLandscape ? Axis.horizontal : Axis.vertical,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==========================================
                // HEADER SECTION (Logo)
                // ==========================================
                SizedBox(
                  width: isLandscape
                      ? MediaQuery.of(context).size.width * 0.40
                      : double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isLandscape) SizedBox(height: 20.h),
                      // Logo
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
                      if (!isLandscape) SizedBox(height: 21.h),
                    ],
                  ),
                ),

                if (isLandscape) SizedBox(width: 16.w),

                // ==========================================
                // CONTENT SECTION
                // ==========================================
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isLandscape) SizedBox(height: 20.h),
                        Text(
                          'We’ve logged you in',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25.sp,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w700,
                            height: 1.12,
                          ),
                        ),
                        SizedBox(height: 21.h),
                        Text(
                          'You can now continue to Right Route. If you ve forgotten your password, you can choose a new one now or update it from your account Settings another time.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 29.h),

                        // ======================== BUTTONS ======================
                        /// CONTINUE BUTTON
                        Obx(() => CustomButton(
                          text: loginController.isLoading.value ? 'Loading ...' : 'CONTINUE',
                          width: 392.w,
                          backgroundColor: AppColors.orange,
                          isLoading: loginController.isLoading.value,
                          showSpinner: false,
                          onPressed: loginController.isLoading.value
                              ? null
                              : () async {
                                  await loginController.fetchUserInfoAndRoute();
                                },
                          fontSize: 24,
                        )),

                        SizedBox(height: 25.h),

                        /// CHANGE PASSWORD BUTTON
                        CustomButton(
                          text: 'CHANGE PASSWORD',
                          width: 392.w,
                          backgroundColor: AppColors.medGray,
                          onPressed: () {
                            Get.toNamed(AppRoutes.changePassword);
                          },
                          fontSize: 24,
                        ),

                        SizedBox(height: 50.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
