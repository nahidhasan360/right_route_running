import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import 'package:right_routes/global_widgets/custom_buttons.dart';
import 'package:right_routes/utils/colors.dart';
import 'package:right_routes/utils/responsive_ext.dart';
import 'package:right_routes/views/home/home_all_widgets/dialog/dialog_map.dart';
import 'package:right_routes/views/home/home_all_widgets/dialog/dialog_document.dart';
import 'package:right_routes/views/home/home_all_widgets/dialog/dialog_route_name.dart';
import '../../../../global_widgets/custom_navbar.dart';
import '../../../../utils/assets_manager.dart';
import 'package:right_routes/views/home/create_new_routes/home_controller.dart';
import 'home_screen_map.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class Homescreen extends StatelessWidget {
  Homescreen({super.key});

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
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
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
          Obx(() {
            if (_ctrl.isCreating.value) {
              return Container(
                color: Colors.black.withOpacity(0.7),
                child: const Center(
                  child: Text(
                    'Loading .....',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
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
            _buildRouteNameLabel(context),
            SizedBox(height: context.h(8)),
            _buildRouteNameField(context),
            SizedBox(height: context.h(10)),
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
  // Map height = full available height minus top/bottom safe-area
  // padding AND outer padding, so the map never touches the screen
  // edge or sits flush against the home-indicator / navbar inset.
  // Key: wrap the whole Row in a SizedBox with a fixed height so
  // that Expanded (right column) gets a bounded constraint and
  // fills the screen vertically — but bounded, not edge-to-edge.
  // ─────────────────────────────────────────────────────────────
  Widget _buildLandscapeLayout(BuildContext context) {
    final double padding = context.s(12);
    // bottom safe-area inset is NOT excluded by SafeArea here because
    // this widget is rendered inside `SafeArea(bottom: false, ...)`,
    // so we must account for it manually or the map gets pushed flush
    // against the bottom edge / system nav bar.
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
                    _buildRouteNameLabel(context),
                    SizedBox(height: context.s(8)),
                    _buildRouteNameField(context),
                    SizedBox(height: context.s(20)),
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

  Widget _buildRouteNameLabel(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            'Enter Route Name',
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
          onTap: () => showRouteNameDialog(context),
          child: SvgPicture.asset(
            'assets/icons/Question-Box-gray.svg',
            width: context.w(20),
            height: context.h(20),
          ),
        ),
      ],
    );
  }

  Widget _buildRouteNameField(BuildContext context) {
    return Container(
      height: context.h(33),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.r(4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _ctrl.routeNameController,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: context.w(12),
                  vertical: 0,
                ),
                isDense: true,
              ),
              style: TextStyle(
                fontSize: context.sp(16),
                fontFamily: 'Lato',
                color: Colors.black,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: context.w(6)),
            child: GestureDetector(
              onTap: () {
                // TODO: Implement mic action
              },
              child: Container(
                width: context.w(20),
                height: context.h(20),
                decoration: BoxDecoration(
                  color: AppColors.orange,
                  borderRadius: BorderRadius.circular(context.r(6)),
                ),
                child: Icon(
                  Icons.mic_none,
                  color: AppColors.white,
                  size: context.sp(18),
                ),
              ),
            ),
          ),
        ],
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
    return Obx(() => Row(
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
                _ctrl.currentPermitIndex.value > 1
                    ? 'Set your End Point'
                    : 'Set your Start & End Points',
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
                onTap: () => dialogMap(context),
                child: SvgPicture.asset(
                  'assets/icons/Question-Box-gray.svg',
                  width: context.w(20),
                  height: context.h(20),
                ),
              ),
            ),
          ],
        ));
  }

  Widget _buildStep2Label(BuildContext context) {
    return Obx(() => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            Padding(
              padding: EdgeInsets.only(top: context.h(2)),
              child: GestureDetector(
                onTap: () => showPermitDialog(context),
                child: SvgPicture.asset(
                  'assets/icons/Question-Box-gray.svg',
                  width: context.w(20),
                  height: context.h(20),
                ),
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
              _buildActionButton(context, SvgManager.importWhite, finalWidth, _pickFile),
              _buildActionButton(context, SvgManager.editPencilWhite, finalWidth, () => _showEditDialog(context)),
              _buildActionButton(context, SvgManager.micWhite, finalWidth, () => _showMicDialog(context)),
              _buildActionButton(context, SvgManager.cameraWhite, finalWidth, _takePhoto),
            ],
          ),
        ),
      );
    });
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null && result.files.single.path != null) {
      _ctrl.permitFile.value = File(result.files.single.path!);
      Get.snackbar('Success', 'File attached successfully', backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _takePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      _ctrl.permitFile.value = File(image.path);
      Get.snackbar('Success', 'Photo attached successfully', backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _showEditDialog(BuildContext context) {
    TextEditingController textController = TextEditingController(text: _ctrl.permitText.value);
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF0B1129),
        title: const Text('Edit Permit Text', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: textController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Type your permit text...',
            hintStyle: TextStyle(color: Colors.white54),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel', style: TextStyle(color: Colors.white))),
          TextButton(
            onPressed: () {
              _ctrl.permitText.value = textController.text;
              Get.back();
              Get.snackbar('Success', 'Text saved successfully', backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
            }, 
            child: Text('Done', style: TextStyle(color: AppColors.orange))
          ),
        ],
      )
    );
  }

  void _showMicDialog(BuildContext context) {
    stt.SpeechToText speech = stt.SpeechToText();
    RxBool isListening = false.obs;
    RxString spokenText = _ctrl.permitText.value.obs;

    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF0B1129),
        title: const Text('Voice to Text', style: TextStyle(color: Colors.white)),
        content: Obx(() => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(spokenText.value.isEmpty ? 'Tap mic and speak...' : spokenText.value, 
                 style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () async {
                if (!isListening.value) {
                  bool available = await speech.initialize();
                  if (available) {
                    isListening.value = true;
                    speech.listen(onResult: (val) {
                      spokenText.value = val.recognizedWords;
                    });
                  } else {
                    Get.snackbar('Error', 'Microphone permission denied', backgroundColor: Colors.red, colorText: Colors.white);
                  }
                } else {
                  isListening.value = false;
                  speech.stop();
                }
              },
              child: CircleAvatar(
                radius: 30,
                backgroundColor: isListening.value ? Colors.red : AppColors.orange,
                child: Icon(isListening.value ? Icons.mic : Icons.mic_none, color: Colors.white, size: 30),
              ),
            )
          ],
        )),
        actions: [
          TextButton(onPressed: () {
            speech.stop();
            Get.back();
          }, child: const Text('Cancel', style: TextStyle(color: Colors.white))),
          TextButton(
            onPressed: () {
              speech.stop();
              _ctrl.permitText.value = spokenText.value;
              Get.back();
              Get.snackbar('Success', 'Voice text saved', backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
            }, 
            child: Text('Done', style: TextStyle(color: AppColors.orange))
          ),
        ],
      )
    );
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
          _ctrl.submitCreateRoute();
        },
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, String svgPath, double width, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
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
