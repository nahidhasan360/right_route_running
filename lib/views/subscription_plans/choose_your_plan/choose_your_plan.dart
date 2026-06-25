import 'package:flutter/material.dart';
import 'package:right_routes/utils/responsive_ext.dart';
import 'package:get/get.dart';
import 'package:right_routes/utils/colors.dart';

import 'package:right_routes/core/routes/all_routes.dart';
import '../../../global_widgets/button_reusable_short_width.dart';
import '../../../utils/assets_manager.dart';

class PlanController extends GetxController {
  RxString selected = "".obs;
}

class ChooseYourPlan extends StatelessWidget {
  const ChooseYourPlan({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PlanController());

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
          child: Column(
            children: [
              SizedBox(height: context.h(20)),
              
              /// Logo
              Center(
                child: Container(
                  width: context.w(225),
                  height: context.h(112),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(ImageManager.splashScreenLogo),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: context.w(15), right: context.w(15), top: context.w(20), bottom: context.w(20)),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            /// Title
                            Text(
                              'CHOOSE YOUR PLAN',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: context.sp(32),
                                fontFamily: 'League Gothic',
                                fontWeight: FontWeight.w400,
                                height: context.h(0.88),
                                letterSpacing: 1,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: context.h(21)),

                            /// Subtitle
                            Text(
                              'Start your 7-day free trial and begin automating your routes. Cancel anytime.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: context.sp(18),
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w500,
                                height: context.h(1.56),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: context.h(18)),

                            Text(
                              'Individual Plan Options',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: context.sp(20),
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w700,
                                height: context.h(1.10),
                              ),
                            ),

                            SizedBox(height: context.h(11)),

                            /// ============== ANNUAL PLAN TILE =================
                            Obx(
                              () => _planTile(context: context, 
                                title: "ANNUAL PLAN",
                                price: "\$119.99/YR",
                                badge: "Save 33%",
                                selected: controller.selected.value == "annual",
                                onTap: () =>
                                    controller.selected.value = "annual",
                              ),
                            ),

                            SizedBox(height: context.h(13)),

                            /// MONTHLY PLAN TILE
                            Obx(
                              () => _planTile(context: context, 
                                title: "MONTHLY PLAN",
                                price: "\$14.99/MO",
                                badge: null,
                                selected:
                                    controller.selected.value == "monthly",
                                onTap: () =>
                                    controller.selected.value = "monthly",
                              ),
                            ),

                            SizedBox(height: context.h(10)),

                            TextButton(
                              onPressed: () {
                                // planController.restoreSubscription();
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'By clicking "Subscribe", you agree to the',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: context.sp(18),
                                      fontFamily: 'Lato',
                                      fontWeight: FontWeight.w500,
                                      height: context.h(1.67),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Get.toNamed(
                                        AppRoutes.subscriberAgreement,
                                      );
                                    },
                                    child: Text(
                                      'RIGHT ROUTE SUBSCRIBER AGREEMENT',
                                      style: TextStyle(
                                        color: AppColors.purple,
                                        fontSize: context.sp(20),
                                        fontFamily: 'League Gothic',
                                        fontWeight: FontWeight.w400,
                                        height: context.h(1.50),
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: context.h(25)),
                            ButtonReusable(
                              text: 'SUBSCRIBE',
                              onPressed: () {
                                Get.offAllNamed(AppRoutes.homeScreen);
                              },
                              width: context.w(250),
                              height: context.h(55),
                            ),
                            SizedBox(height: context.h(6)),
                            TextButton(
                              onPressed: () {
                                // planController.restoreSubscription();
                                Get.toNamed(AppRoutes.enterEmailScreen);
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "SIGN IN WITH DIFFERENT EMAIL",
                                    style: TextStyle(
                                      color: AppColors.purple,
                                      fontSize: context.sp(20),
                                      fontFamily: 'League Gothic',
                                      fontWeight: FontWeight.w400,
                                      height: context.h(1.50),
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: context.h(85)),
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
                                      fontSize: context.sp(16),
                                      fontFamily: 'Lato',
                                      fontWeight: FontWeight.w500,
                                      height: context.h(1.75),
                                    ),
                                  ),
                                  Text(
                                    'RESTORE SUBSCRIPTION',
                                    style: TextStyle(
                                      color: AppColors.purple,
                                      fontSize: context.sp(20),
                                      fontFamily: 'League Gothic',
                                      fontWeight: FontWeight.w400,
                                      height: context.h(1.40),
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: context.h(49)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}

/// REUSABLE PLAN TILE (STATIC INSIDE THIS FILE)
Widget _planTile({required BuildContext context,
  required String title,
  required String price,
  required bool selected,
  required VoidCallback onTap,
  String? badge,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: context.w(392),
      height: context.h(76),
      padding: EdgeInsets.symmetric(horizontal: context.w(13)),
      decoration: BoxDecoration(
        color: selected ? AppColors.orange : AppColors.darkGray,
        // borderRadius: BorderRadius.circular(context.r(10)),
        border: Border.all(width: context.w(1), color: AppColors.medGray),
      ),
      child: Row(
        children: [
          /// LEFT SIDE CIRCLE (CHECK)
          Container(
            width: context.w(24),
            height: context.h(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border:
                  selected ? Border.all(color: Colors.white, width: context.w(2)) : null,
              color: selected ? AppColors.checkBoxColor : Colors.grey.shade500,
            ),
            child: selected
                ? const Icon(Icons.check, size: 18, color: Colors.white)
                : null,
          ),

          SizedBox(width: context.w(15)),

          /// TITLE
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: context.sp(24),
              fontFamily: 'League Gothic',
              fontWeight: FontWeight.w400,
              height: context.h(1.17),
              letterSpacing: 1,
            ),
          ),

          const Spacer(),

          /// PRICE + OPTIONAL BADGE
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.sp(30),
                  fontFamily: 'League Gothic',
                  fontWeight: FontWeight.w400,
                  height: context.h(0.88),
                  letterSpacing: 1,
                ),
              ),
              if (badge != null)
                Container(
                  margin: EdgeInsets.only(top: context.h(6)),
                  padding: EdgeInsets.symmetric(horizontal: context.w(9)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(context.r(5)),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      color: AppColors.darkGray,
                      fontSize: context.sp(16),
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w700,
                      height: context.h(1.75),
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
