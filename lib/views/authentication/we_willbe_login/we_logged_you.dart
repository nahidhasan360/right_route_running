import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import '../../../utils/assets_manager.dart';
import '../../../utils/colors.dart';

class WeLoggedYou extends StatelessWidget {
  const WeLoggedYou({super.key});

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
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 21.h),
                Text(
                  'We’ve logged you in',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25.sp,
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w700,
                    height: 1.12.h,
                  ),
                ),
                SizedBox(height: 21.h),
                SizedBox(
                  child: Text(
                    'You can now continue to Right Route. If you ve forgotten your password, you can choose a new one now or update it from your account Settings another time.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: 29.h),

                // ======================== BUTTON ======================
                /// CONTINUE BUTTON
                GestureDetector(
                  onTap: () {
                    // controller.verifyOtp();
                    // Get.dialog(
                    //   TermsModal(),
                    //   barrierDismissible: true,
                    // );
                    Get.toNamed(AppRoutes.individualTeam);
                    print('Its clicked ');
                  },
                  child: Container(
                    width: 392.w,
                    height: 55.h,
                    decoration: BoxDecoration(
                      color: AppColors.orange,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'CONTINUE',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24.sp,
                        fontFamily: 'League Gothic',
                        fontWeight: FontWeight.w400,
                        height: 1.17.h,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 25.h),

                GestureDetector(
                  onTap: () {
                    Get.toNamed(AppRoutes.changePassword);
                  },
                  child: Container(
                    width: 392.w,
                    height: 55.h,
                    decoration: BoxDecoration(
                      color: AppColors.medGray,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'CHANGE PASSWORD',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24.sp,
                        fontFamily: 'League Gothic',
                        fontWeight: FontWeight.w400,
                        height: 1.17.h,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 50.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
