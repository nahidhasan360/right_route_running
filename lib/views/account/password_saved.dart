import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import 'package:right_routes/global_widgets/custom_navbar.dart';
import 'package:right_routes/utils/assets_manager.dart';
import 'package:right_routes/utils/colors.dart';
import 'package:right_routes/utils/responsive_ext.dart';
import '../../global_widgets/button_reusable_short_width.dart';

class PasswordSaved extends StatelessWidget {
  const PasswordSaved({super.key});

  final String savedEmail = 'tanvirhasancr890890@gmail.com';

  // one return to back press
  void onReturnPressed(BuildContext context) {
    debugPrint('RETURN button pessed!');
  }

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
                      SizedBox(height: isLandscape ? context.s(10) : context.h(40)),
                      _buildLogo(context, isLandscape),
                      SizedBox(height: isLandscape ? context.s(15) : context.h(25)),
                      _buildBlueIcon(context, isLandscape),
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
                      if (!isLandscape) SizedBox(height: context.h(21)),
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

  Widget _buildBlueIcon(BuildContext context, bool isLandscape) {
    return Center(
      child: SizedBox(
        width: isLandscape ? context.s(50) : context.w(62),
        height: isLandscape ? context.s(50) : context.h(62),
        child: SvgPicture.asset(
          SvgManager.blueIcon,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your new Right Route password is saved',
          style: TextStyle(
            color: Colors.white,
            fontSize: context.sp(28),
            fontFamily: 'Lato',
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: context.h(3)),
        Divider(color: AppColors.dividerColor, thickness: 1),
        SizedBox(height: context.h(34)),
        ButtonReusable(
          onPressed: () => Get.toNamed(AppRoutes.accountScreen),
          text: 'RETURN',
          width: double.infinity,
        ),
        SizedBox(height: context.h(20)),
      ],
    );
  }
}