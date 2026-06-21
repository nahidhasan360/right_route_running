import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:right_routes/global_widgets/custom_navbar.dart';
import 'package:right_routes/utils/assets_manager.dart';
import 'package:right_routes/utils/colors.dart';
import 'package:right_routes/utils/responsive_ext.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import '../../global_widgets/button_reusable_short_width.dart';

class Help extends StatelessWidget {
  const Help({super.key});

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
                ? EdgeInsets.all(context.s(12))
                : EdgeInsets.only(
                    top: context.h(20),
                    left: context.w(20),
                    right: context.w(20),
                    bottom: context.w(20),
                  ),
            child: Flex(
              direction: isLandscape ? Axis.horizontal : Axis.vertical,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ==========================================
                // HEADER / LOGO SECTION
                // ==========================================
                SizedBox(
                  width: isLandscape
                      ? MediaQuery.of(context).size.width * 0.35
                      : double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: isLandscape ? context.s(10) : 0),
                      _buildLogo(context, isLandscape),
                    ],
                  ),
                ),

                if (isLandscape) SizedBox(width: context.w(15)),

                // ==========================================
                // CONTENT + BUTTON SECTION
                // ==========================================
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isLandscape) SizedBox(height: context.h(29)),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: _buildContent(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const CustomNavbar(),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // WIDGETS
  // ─────────────────────────────────────────────────────────────

  Widget _buildLogo(BuildContext context, bool isLandscape) {
    return Center(
      child: Container(
        width: isLandscape
            ? MediaQuery.of(context).size.width * 0.25
            : context.w(225),
        height: isLandscape
            ? MediaQuery.of(context).size.height * 0.25
            : context.h(112),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(ImageManager.splashScreenLogo),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Help',
          style: TextStyle(
            color: Colors.white,
            fontSize: context.sp(28),
            fontFamily: 'Lato',
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: context.h(8)),
        Divider(color: AppColors.dividerColor, thickness: 1),
        SizedBox(height: context.h(10)),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "TEAM PLAN USERS: ",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.sp(18),
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w800,
                ),
              ),
              TextSpan(
                text:
                    "If you cannot login using your email, it's likely the company app administrator has removed you from this app plan. If you think this is an error, please contact them for more information. If you were removed and still wish to use this app, you are welcome to subscribe to our single user plan",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.sp(18),
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextSpan(
                text: " here.",
                style: TextStyle(
                  color: AppColors.purple,
                  fontSize: context.sp(18),
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Get.toNamed(AppRoutes.chooseYourPlan);
                  },
              ),
            ],
          ),
        ),
        SizedBox(height: context.h(124)),
        Text(
          'More content Coming...',
          style: TextStyle(
            color: Colors.white,
            fontSize: context.sp(20),
            fontFamily: 'Lato',
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: context.h(89)),
        ButtonReusable(
          onPressed: () => Get.toNamed(AppRoutes.getStartedScreen),
          text: 'DONE',
          width: double.infinity,
        ),
        SizedBox(height: context.h(20)),
      ],
    );
  }
}