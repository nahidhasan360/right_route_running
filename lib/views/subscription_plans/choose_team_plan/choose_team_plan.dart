import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import 'package:right_routes/utils/colors.dart';

import '../../../global_widgets/button_reusable_short_width.dart';
import '../../../utils/assets_manager.dart';

class ChooseTeamPlanController extends GetxController {
  RxString selected = "".obs;
}

class ChooseATeamPlan extends StatelessWidget {
  const ChooseATeamPlan({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChooseTeamPlanController());

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
              /// 🔥 FIXED LOGO (STICKY – does not scroll)
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

              SizedBox(height: 29.h),

              /// 🔥 SCROLLABLE CONTENT (everything below logo)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      /// TITLE
                      Text(
                        'CHOOSE A TEAM PLAN',
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

                      SizedBox(height: 22.h),

                      /// Subtitle
                      Text(
                        'Plans include dashboard, seat\nmanagement, support, and on-\nboarding. Cancel anytime.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w500,
                          height: 1.44,
                        ),
                      ),

                      SizedBox(height: 19.h),

                      /// 🔹 Plan Tiles (Set 1)
                      Obx(() => _planTile(
                        title: "UP TO 5 DRIVERS",
                        price: "\$69/MO",
                        badge: null,
                        selected: controller.selected.value == "plan5",
                        onTap: () => controller.selected.value = "plan5",
                      )),
                      SizedBox(height: 12.h),

                      Obx(() => _planTile(
                        title: "UP TO 10 DRIVERS",
                        price: "\$119/MO",
                        badge: null,
                        selected: controller.selected.value == "plan10",
                        onTap: () => controller.selected.value = "plan10",
                      )),
                      SizedBox(height: 12.h),

                      Obx(() => _planTile(
                        title: "UP TO 25 DRIVERS",
                        price: "\$249/MO",
                        badge: null,
                        selected: controller.selected.value == "plan25",
                        onTap: () => controller.selected.value = "plan25",
                      )),
                      SizedBox(height: 12.h),
                      /// 🔹 Plan Tiles (Set 2) – optional duplicate, different keys
                      Obx(() => _planTile(
                        title: "UP TO 50 DRIVERS",
                        price: "\$449/MO",
                        badge: null,
                        selected: controller.selected.value == "plan50",
                        onTap: () => controller.selected.value = "plan50",
                      )),
                      SizedBox(height: 12.h),

                      Obx(() => _planTile(
                        title: "UP TO 100 DRIVERS",
                        price: "\$749/MO",
                        badge: null,
                        selected: controller.selected.value == "plan100",
                        onTap: () => controller.selected.value = "plan100",
                      )),
                      SizedBox(height: 10.h),

                      SizedBox(
                        width: 392.w,
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Have more than 100 drivers? Contact sales or fill out the Fleet Pricing Request form on our website:\n',
                                style: TextStyle(color: Colors.white, fontSize: 16.sp, fontFamily: 'Lato', fontWeight: FontWeight.w400, height: 1.44),
                              ),
                              TextSpan(
                                text: 'sales@getrightroute.app\n',
                                style: TextStyle(color: Colors.white, fontSize: 16.sp, fontFamily: 'Lato', fontWeight: FontWeight.w700, decoration: TextDecoration.underline, height: 1.44),
                              ),
                              TextSpan(
                                text: 'https://getrightroute.app',
                                style: TextStyle(color: Colors.white, fontSize: 16.sp, fontFamily: 'Lato', fontWeight: FontWeight.w700, decoration: TextDecoration.underline, height: 1.44),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      SizedBox(height: 25.h),

                      /// AGREEMENT + BUTTONS
                      TextButton(
                        onPressed: () {},
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'By clicking "Subscribe", you agree to\nour',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w400,
                                height: 1.20,
                              ),
                            ),
                            SizedBox(height: 8.h),

                            GestureDetector(
                              onTap: () {
                                Get.toNamed(AppRoutes.subscriberAgreement);
                              },
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'DISCLAIMER ',
                                      style: TextStyle(
                                        color: AppColors.purple,
                                        fontSize: 20.sp,
                                        fontFamily: 'League Gothic',
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'and ',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.sp,
                                        fontFamily: 'Lato',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'TERMS OF SERVICE',
                                      style: TextStyle(
                                        color: AppColors.purple,
                                        fontSize: 20.sp,
                                        fontFamily: 'League Gothic',
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                            SizedBox(height: 23.h),

                            /// SUBSCRIBE BUTTON
                            ButtonReusable(
                              text: 'SUBSCRIBE',
                              onPressed: () {
                                Get.offAllNamed(AppRoutes.teamManager);
                              },
                              width: 250.w,
                              height: 55.h,
                            ),

                            SizedBox(height: 6.h),

                            // TextButton(
                            //   onPressed: () {},
                            //   child: Text(
                            //     'RIGHT ROUTE SUB SCRIBER AGREEMENT',
                            //     style: TextStyle(
                            //       color: AppColors.purple,
                            //       fontSize: 20.sp,
                            //       fontFamily: 'League Gothic',
                            //       fontWeight: FontWeight.w400,
                            //       height: 1.50.h,
                            //     ),
                            //   ),
                            // ),

                            SizedBox(height: 47.h),

                            /// RESTORE SUBSCRIPTION
                            TextButton(
                              onPressed: () {},
                              child: Column(
                                children: [
                                  Text(
                                    'Already a subscriber?',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.sp,
                                      fontFamily: 'Lato',
                                      fontWeight: FontWeight.w500,
                                      height: 1.75,
                                    ),
                                  ),
                                  Text(
                                    'RESTORE SUBSCRIPTION',
                                    style: TextStyle(
                                      color: AppColors.purple,
                                      fontSize: 20.sp,
                                      fontFamily: 'League Gothic',
                                      fontWeight: FontWeight.w400,
                                      height: 1.40,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 70.h),
                          ],
                        ),
                      ),
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

/// PLAN TILE WIDGET
Widget _planTile({
  required String title,
  required String price,
  required bool selected,
  required VoidCallback onTap,
  String? badge,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 392.w,
      height: 53.h,
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        color: selected ? AppColors.orange : AppColors.darkGray,
        border: Border.all(width: 1.w, color: AppColors.medGray),
      ),
      child: Row(
        children: [
          /// CHECK CIRCLE
          Container(
            width: 24.w,
            height: 24.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: selected
                  ? Border.all(color: Colors.white, width: 2.w)
                  : null,
              color: selected
                  ? AppColors.checkBoxColor
                  : Colors.grey.shade500,
            ),
            child: selected
                ? const Icon(Icons.check, size: 18, color: Colors.white)
                : null,
          ),

          SizedBox(width: 7.w),

          /// TITLE
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.sp,
              fontFamily: 'League Gothic',
              fontWeight: FontWeight.w400,
              letterSpacing: 1,
              height: 1.17,
            ),
          ),

          Spacer(),

          /// PRICE + BADGE
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.sp,
                  fontFamily: 'League Gothic',
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1,
                ),
              ),

              if (badge != null)
                Container(
                  margin: EdgeInsets.only(top: 6.h),
                  padding: EdgeInsets.symmetric(horizontal: 9.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      color: AppColors.medGray,
                      fontSize: 16.sp,
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    ),
  );
}
