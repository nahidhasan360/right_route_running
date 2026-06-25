import 'package:flutter/material.dart';
import 'package:right_routes/utils/responsive_ext.dart';
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
            padding: EdgeInsets.symmetric(horizontal: context.w(15)),
            child: Column(
              children: [
                SizedBox(height: context.h(20)),
              /// 🔥 FIXED LOGO (STICKY – does not scroll)
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

              SizedBox(height: context.h(29)),

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
                          fontSize: context.sp(32),
                          fontFamily: 'League Gothic',
                          fontWeight: FontWeight.w400,
                          height: context.h(0.88),
                          letterSpacing: 1,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: context.h(22)),

                      /// Subtitle
                      Text(
                        'Plans include dashboard, seat\nmanagement, support, and on-\nboarding. Cancel anytime.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.sp(18),
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w500,
                          height: 1.44,
                        ),
                      ),

                      SizedBox(height: context.h(19)),

                      /// 🔹 Plan Tiles (Set 1)
                      Obx(() => _planTile(context: context, 
                        title: "UP TO 5 DRIVERS",
                        price: "\$69/MO",
                        badge: null,
                        selected: controller.selected.value == "plan5",
                        onTap: () => controller.selected.value = "plan5",
                      )),
                      SizedBox(height: context.h(12)),

                      Obx(() => _planTile(context: context, 
                        title: "UP TO 10 DRIVERS",
                        price: "\$119/MO",
                        badge: null,
                        selected: controller.selected.value == "plan10",
                        onTap: () => controller.selected.value = "plan10",
                      )),
                      SizedBox(height: context.h(12)),

                      Obx(() => _planTile(context: context, 
                        title: "UP TO 25 DRIVERS",
                        price: "\$249/MO",
                        badge: null,
                        selected: controller.selected.value == "plan25",
                        onTap: () => controller.selected.value = "plan25",
                      )),
                      SizedBox(height: context.h(12)),
                      /// 🔹 Plan Tiles (Set 2) – optional duplicate, different keys
                      Obx(() => _planTile(context: context, 
                        title: "UP TO 50 DRIVERS",
                        price: "\$449/MO",
                        badge: null,
                        selected: controller.selected.value == "plan50",
                        onTap: () => controller.selected.value = "plan50",
                      )),
                      SizedBox(height: context.h(12)),

                      Obx(() => _planTile(context: context, 
                        title: "UP TO 100 DRIVERS",
                        price: "\$749/MO",
                        badge: null,
                        selected: controller.selected.value == "plan100",
                        onTap: () => controller.selected.value = "plan100",
                      )),
                      SizedBox(height: context.h(10)),

                      SizedBox(
                        width: context.w(392),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Have more than 100 drivers? Contact sales or fill out the Fleet Pricing Request form on our website:\n',
                                style: TextStyle(color: Colors.white, fontSize: context.sp(16), fontFamily: 'Lato', fontWeight: FontWeight.w400, height: 1.44),
                              ),
                              TextSpan(
                                text: 'sales@getrightroute.app\n',
                                style: TextStyle(color: Colors.white, fontSize: context.sp(16), fontFamily: 'Lato', fontWeight: FontWeight.w700, decoration: TextDecoration.underline, height: 1.44),
                              ),
                              TextSpan(
                                text: 'https://getrightroute.app',
                                style: TextStyle(color: Colors.white, fontSize: context.sp(16), fontFamily: 'Lato', fontWeight: FontWeight.w700, decoration: TextDecoration.underline, height: 1.44),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      SizedBox(height: context.h(25)),

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
                                fontSize: context.sp(16),
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w400,
                                height: 1.20,
                              ),
                            ),
                            SizedBox(height: context.h(8)),

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
                                        fontSize: context.sp(20),
                                        fontFamily: 'League Gothic',
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'and ',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: context.sp(16),
                                        fontFamily: 'Lato',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'TERMS OF SERVICE',
                                      style: TextStyle(
                                        color: AppColors.purple,
                                        fontSize: context.sp(20),
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

                            SizedBox(height: context.h(23)),

                            /// SUBSCRIBE BUTTON
                            ButtonReusable(
                              text: 'SUBSCRIBE',
                              onPressed: () {
                                Get.offAllNamed(AppRoutes.teamManager);
                              },
                              width: context.w(250),
                              height: context.h(55),
                            ),

                            SizedBox(height: context.h(6)),

                            // TextButton(
                            //   onPressed: () {},
                            //   child: Text(
                            //     'RIGHT ROUTE SUB SCRIBER AGREEMENT',
                            //     style: TextStyle(
                            //       color: AppColors.purple,
                            //       fontSize: context.sp(20),
                            //       fontFamily: 'League Gothic',
                            //       fontWeight: FontWeight.w400,
                            //       height: context.h(1.50),
                            //     ),
                            //   ),
                            // ),

                            SizedBox(height: context.h(47)),

                            /// RESTORE SUBSCRIPTION
                            TextButton(
                              onPressed: () {},
                              child: Column(
                                children: [
                                  Text(
                                    'Already a subscriber?',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: context.sp(16),
                                      fontFamily: 'Lato',
                                      fontWeight: FontWeight.w500,
                                      height: 1.75,
                                    ),
                                  ),
                                  Text(
                                    'RESTORE SUBSCRIPTION',
                                    style: TextStyle(
                                      color: AppColors.purple,
                                      fontSize: context.sp(20),
                                      fontFamily: 'League Gothic',
                                      fontWeight: FontWeight.w400,
                                      height: 1.40,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: context.h(70)),
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
      height: context.h(53),
      padding: EdgeInsets.symmetric(horizontal: context.w(8)),
      decoration: BoxDecoration(
        color: selected ? AppColors.orange : AppColors.darkGray,
        border: Border.all(width: context.w(1), color: AppColors.medGray),
      ),
      child: Row(
        children: [
          /// CHECK CIRCLE
          Container(
            width: context.w(24),
            height: context.h(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: selected
                  ? Border.all(color: Colors.white, width: context.w(2))
                  : null,
              color: selected
                  ? AppColors.checkBoxColor
                  : Colors.grey.shade500,
            ),
            child: selected
                ? const Icon(Icons.check, size: 18, color: Colors.white)
                : null,
          ),

          SizedBox(width: context.w(7)),

          /// TITLE
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: context.sp(24),
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
                  fontSize: context.sp(24),
                  fontFamily: 'League Gothic',
                  fontWeight: FontWeight.w400,
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
                      color: AppColors.medGray,
                      fontSize: context.sp(16),
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
