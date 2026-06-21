// file: views/common/reusable_enter_email_screen.dart  (নতুন ফোল্ডারে রাখতে পারো যাতে বোঝা যায় এটা reusable)

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:right_routes/utils/assets_manager.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import 'package:right_routes/global_widgets/custom_buttons.dart';
import 'package:right_routes/utils/colors.dart';

class ReusableEnterEmailScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onContinue;
  final Function(String)? onEmailSubmitted;

  const ReusableEnterEmailScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onContinue,
    this.onEmailSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EnterEmailController());

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
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 40.h),
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
                        Text(
                          title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25.sp,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 21.h),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 28.h),
                    Container(
                      width: double.infinity,
                      height: 57.h,
                      decoration: BoxDecoration(
                        color: AppColors.medGray,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: TextFormField(
                        controller: controller.emailController,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w400,
                          height: 1.4.h,
                          letterSpacing: 0.2,
                        ),
                        cursorColor: Colors.white,
                        cursorHeight: 22.h,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: "Email",
                          hintStyle: TextStyle(
                            color: Color(0xFFBFBFBF),
                            fontSize: 16.sp,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w400,
                          ),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 14.h, horizontal: 15.w),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 25.h),
                    CustomButton(
                      text: buttonText,
                      width: double.infinity,
                      height: 57.h,
                      onPressed: () {
                        String email = controller.emailController.text.trim();

                        if (email.isEmpty) {
                          Get.snackbar("Error", "Please enter your email",
                              backgroundColor:
                                  Colors.red.withValues(alpha: 0.8),
                              colorText: Colors.white);
                          return;
                        }

                        onEmailSubmitted?.call(email);
                        onContinue();
                        controller.emailController.clear();
                      },
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

class EnterEmailController extends GetxController {
  final emailController = TextEditingController();

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
