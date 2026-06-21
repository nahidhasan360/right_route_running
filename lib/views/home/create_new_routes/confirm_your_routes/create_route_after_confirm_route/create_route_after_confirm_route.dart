import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import 'package:right_routes/global_widgets/custom_buttons.dart';
import 'package:right_routes/utils/colors.dart';
import 'package:right_routes/utils/responsive_ext.dart';
import 'package:right_routes/views/home/create_new_routes/home_controller.dart';
import 'package:right_routes/views/home/home_all_widgets/dialog/dialog_map.dart';
import 'package:right_routes/views/home/home_all_widgets/dialog/dialog_document.dart';
import 'package:right_routes/views/home/create_new_routes/home_screen_map.dart';
import '../../../../../global_widgets/custom_navbar.dart';
import '../../../../../utils/assets_manager.dart';

// ============================================================
// RESPONSIVE RULES (context-based, see responsive_ext.dart)
// ============================================================
// context.w(n)   → horizontal dimension (width, horizontal padding/margin)
// context.h(n)   → vertical dimension (height, vertical padding/margin)
// context.sp(n)  → font size ONLY
// context.r(n)   → border radius ONLY
// context.s(n)   → icon / square / generic scale
// ❌ NEVER use context.h on lineHeight inside TextStyle — it's a multiplier
// ❌ NEVER use raw numbers for spacing — always context.w / context.h
// Sizing/spacing rhythm mirrors Homescreen (home_screen.dart) exactly —
// same portrait/landscape split pattern, same gap values, same title and
// button proportions — so this screen feels identical in scale.
// ============================================================

class CreateRouteAfterConfirmRoute extends StatelessWidget {
  CreateRouteAfterConfirmRoute({super.key});

  final HomeController _ctrl = Get.isRegistered<HomeController>()
      ? Get.find<HomeController>()
      : Get.put(HomeController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    final bool isLandscape = context.landscape;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1129),
      extendBody: true,
      extendBodyBehindAppBar: true,
      bottomNavigationBar: const CustomNavbar(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(ImageManager.mapBackground),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: isLandscape
              ? _buildLandscapeLayout(context)
              : _buildPortraitLayout(context),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // PORTRAIT LAYOUT
  // ─────────────────────────────────────────────────────────────
  Widget _buildPortraitLayout(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.only(
          top: context.h(20),
          left: context.w(20),
          right: context.w(20),
          bottom: context.h(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: context.s(15)),
            _buildTitle(context),
            SizedBox(height: context.h(5)),
            _buildPermitTitle(context),
            SizedBox(height: context.h(8)),
            _buildStep1Label(context),
            SizedBox(height: context.h(12)),
            const HomeScreenMap(),
            SizedBox(height: context.h(12)),
            _buildStep2Label(context),
            SizedBox(height: context.h(16)),
            _buildActionButtonsRow(context),
            SizedBox(height: context.h(20)),
            _buildContinueButton(context),
            SizedBox(height: context.h(50)),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // LANDSCAPE LAYOUT
  // Same approach as Homescreen: map fills the bounded right column,
  // left column scrolls independently, bottom inset accounted for
  // manually since SafeArea(bottom: false) doesn't exclude it.
  // ─────────────────────────────────────────────────────────────
  Widget _buildLandscapeLayout(BuildContext context) {
    final double padding = context.s(12);
    final double bottomInset = MediaQuery.of(context).padding.bottom;
    final double availableHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        bottomInset -
        (padding * 2);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        padding,
        padding,
        padding,
        padding + bottomInset,
      ),
      child: SizedBox(
        height: availableHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── LEFT COLUMN ──────────────────────────────────────
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.40,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: context.s(10)),
                    _buildTitle(context),
                    SizedBox(height: context.h(5)),
                    _buildPermitTitle(context),
                    SizedBox(height: context.s(8)),
                    _buildStep1Label(context),
                    SizedBox(height: context.s(12)),
                    Divider(color: AppColors.white, thickness: 1),
                    SizedBox(height: context.s(10)),
                    _buildStep2Label(context),
                    SizedBox(height: context.s(16)),
                    _buildActionButtonsRow(context),
                    SizedBox(height: context.s(16)),
                    _buildContinueButton(context),
                    SizedBox(height: context.s(80)),
                  ],
                ),
              ),
            ),

            SizedBox(width: context.w(10)),

            // ── RIGHT COLUMN — Map fills the bounded height ──────
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(context.r(12)),
                child: const SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: HomeScreenMap(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // SHARED WIDGETS
  // ─────────────────────────────────────────────────────────────

  Widget _buildTitle(BuildContext context) {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          'CREATE ROUTE',
          style: TextStyle(
            color: Colors.white,
            fontSize: context.sp(36),
            fontFamily: 'League Gothic',
            fontWeight: FontWeight.w400,
            letterSpacing: 2.0,
          ),
        ),
      ),
    );
  }

  Widget _buildPermitTitle(BuildContext context) {
    return Center(
      child: Obx(() => Text(
            'Permit ${_ctrl.currentPermitIndex.value}',
            style: TextStyle(
              color: Colors.white,
              fontSize: context.sp(20),
              fontFamily: 'Lato',
              fontWeight: FontWeight.w700,
            ),
          )),
    );
  }

  Widget _buildStep1Label(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step 1: ',
          style: TextStyle(
            color: AppColors.orange,
            fontSize: context.sp(19),
            fontFamily: 'Lato',
            fontWeight: FontWeight.w700,
          ),
        ),
        Flexible(
          child: Text(
            'Set your End Point',
            style: TextStyle(
              color: Colors.white,
              fontSize: context.sp(18),
              fontFamily: 'Lato',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(width: context.w(6)),
        Padding(
          padding: EdgeInsets.only(top: context.h(2)),
          child: GestureDetector(
            onTap: () {
              dialogMapForSubsequentPermit(context);
            },
            child: SvgPicture.asset(
              'assets/icons/Question-Box-gray.svg',
              width: context.w(20),
              height: context.h(20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2Label(BuildContext context) {
    return Obx(() => Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Step 2: ',
              style: TextStyle(
                color: AppColors.orange,
                fontSize: context.sp(19),
                fontFamily: 'Lato',
                fontWeight: FontWeight.w700,
              ),
            ),
            Flexible(
              child: Text(
                'Import Permit ${_ctrl.currentPermitIndex.value}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.sp(18),
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(width: context.w(6)),
            GestureDetector(
              onTap: () {
                showPermitDialog(context);
              },
              child: SvgPicture.asset(
                'assets/icons/Question-Box-gray.svg',
                width: context.w(20),
                height: context.h(20),
              ),
            ),
          ],
        ));
  }

  Widget _buildActionButtonsRow(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final rowWidth = constraints.maxWidth * 0.7;
      final buttonWidth = (rowWidth - (3 * context.w(10))) / 4;
      final finalWidth =
          buttonWidth > context.w(65) ? context.w(65) : buttonWidth;

      return Center(
        child: SizedBox(
          width: rowWidth,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildActionButton(context, SvgManager.importWhite, finalWidth),
              _buildActionButton(
                  context, SvgManager.editPencilWhite, finalWidth),
              _buildActionButton(context, SvgManager.micWhite, finalWidth),
              _buildActionButton(context, SvgManager.cameraWhite, finalWidth),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildContinueButton(BuildContext context) {
    return Center(
      child: CustomButton(
        text: 'CONTINUE',
        width: context.w(150),
        height: context.h(50),
        fontSize: context.sp(26),
        backgroundColor: AppColors.orange,
        borderRadius: 13,
        onPressed: () {
          Get.toNamed(AppRoutes.confirmYourRoutes);
        },
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, String svgPath, double width) {
    return GestureDetector(
      onTap: () {
        // TODO: Implement action
      },
      child: Container(
        width: width,
        height: context.h(46),
        decoration: BoxDecoration(
          color: AppColors.orange,
          borderRadius: BorderRadius.circular(context.r(9)),
        ),
        child: Center(
          child: SvgPicture.asset(
            svgPath,
            width: context.w(35),
            height: context.h(35),
            colorFilter: const ColorFilter.mode(
              Colors.white,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}
