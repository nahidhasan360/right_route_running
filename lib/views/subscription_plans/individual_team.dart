import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import 'package:right_routes/utils/colors.dart';
import '../../../utils/assets_manager.dart';
import '../../global_widgets/button_reusable_short_width.dart';

class IndividualTeam extends StatelessWidget {
  const IndividualTeam({super.key});

  @override
  Widget build(BuildContext context) {
    // final planController = Get.put(PlanController());

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
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: Column(
              children: [
                SizedBox(height: 20.h),
                /// Logo
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
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 29.h),

                      /// Title
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Text(
                          'INDIVIDUAL OR TEAM?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32.sp,
                            fontFamily: 'League Gothic',
                            fontWeight: FontWeight.w400,
                            height: 0.88.h,
                            letterSpacing: 1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 20.h),

                      /// Subtitle
                      Text(
                        'Choose an option to start your 7-day free trial and begin automating your routes. Cancel anytime ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20.h),

                      /// Individual Button
                      ButtonReusable(
                        text: "INDIVIDUAL",
                        width: 250.w,
                        height: 55.h,
                        fontSize: 24.sp,
                        onPressed: () {
                          // planController.selectIndividual();
                          Get.toNamed(AppRoutes.chooseYourPlan);
                        },
                      ),
                      SizedBox(height: 23.h),

                      /// Team Button
                      ButtonReusable(
                        text: "TEAM",
                        width: 250.w,
                        height: 55.h,
                        fontSize: 24.sp,
                        onPressed: () {
                          // planController.selectIndividual();
                          Get.toNamed(AppRoutes.chooseATeamPlan);
                        },
                      ),
                      SizedBox(height: 206.h),

                      /// Restore Subscription
                      TextButton(
                        onPressed: () {
                          // planController.restoreSubscription();
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Already a subscriber?',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w500,
                                height: 1.75.h,
                              ),
                            ),
                            Text(
                              'RESTORE SUBSCRIPTION',
                              style: TextStyle(
                                color:AppColors.purple,
                                fontSize: 20.sp,
                                fontFamily: 'League Gothic',
                                fontWeight: FontWeight.w400,
                                height: 1.40.h,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 49.h),
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

class IndividualTeamController extends GetxController {
  var selectedPlan = ''.obs;

  void selectIndividual() => selectedPlan.value = 'individual';
  void selectTeam() => selectedPlan.value = 'team';

  void restoreSubscription() {
    // Implement restore logic here
  }
}
