import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import 'package:right_routes/global_widgets/custom_navbar.dart';
import 'package:right_routes/utils/assets_manager.dart';
import 'package:right_routes/utils/colors.dart';
import 'package:right_routes/utils/responsive_ext.dart';

import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'dart:io';

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
// ============================================================

// ============================================================
// COLOR CONSTANTS
// ============================================================
class TeamManagerColors {
  static const Color primaryOrange = Color(0xffF58842);
  static const Color primaryWhite = Color(0xFFFFFFFF);
  static const Color darkBackground = Color(0xFF1E1E1E);
  static const Color darkerBackground = Color(0xFF0F0F0F);
  static const Color borderColor = Color(0xFF3A3A3A);
}

// ============================================================
// CONTROLLER
// ============================================================
class TeamManagerController extends GetxController {
  final searchController = TextEditingController();
  final emailInputController = TextEditingController();
  final emailInputFocusNode = FocusNode();

  var userList = <UserModel>[].obs;
  var filteredUserList = <UserModel>[].obs;
  var isAllSelected = false.obs;
  var enrolledFilter = 'All'.obs;
  UserModel? editingUser;

  final userListScrollController = ScrollController();
  final emailInputScrollController = ScrollController();

  RxInt userLimit = 215.obs;
  RxInt currentUsers = 0.obs;
  RxInt remainingSlots = 215.obs;

  @override
  void onInit() {
    super.onInit();
    loadSampleUsers();

    searchController.addListener(() {
      filterUsers(searchController.text);
    });

    emailInputController.addListener(() {
      _updateUserCount();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (emailInputScrollController.hasClients) {
        final maxScroll = emailInputScrollController.position.maxScrollExtent;
        if (maxScroll > 0) {
          emailInputScrollController.jumpTo(maxScroll * 0.2);
        }
      }
    });
  }

  void loadSampleUsers() {
    userList.value = [
      UserModel(
          name: 'John Doe',
          email: 'john@truck.com...',
          status: UserStatus.active,
          isSelected: false,
          isEnrolled: true),
      UserModel(
          name: 'Mark Smith',
          email: 'marksmith@truc...',
          status: UserStatus.pending,
          isSelected: false,
          isEnrolled: false),
      UserModel(
          name: 'Sarah Johnson',
          email: 'sarah@truc...',
          status: UserStatus.resend,
          isSelected: false,
          isEnrolled: false),
      UserModel(
          name: 'Sam Cline',
          email: 'samcline@truc...',
          status: UserStatus.active,
          isSelected: false,
          isEnrolled: true),
      UserModel(
          name: 'Emily Davis',
          email: 'emily@truck.com...',
          status: UserStatus.pending,
          isSelected: false,
          isEnrolled: false),
      UserModel(
          name: 'Michael Brown',
          email: 'michael@truc...',
          status: UserStatus.active,
          isSelected: false,
          isEnrolled: true),
      UserModel(
          name: 'Jessica Wilson',
          email: 'jessica@truc...',
          status: UserStatus.resend,
          isSelected: false,
          isEnrolled: false),
      UserModel(
          name: 'David Lee',
          email: 'david@truck.com...',
          status: UserStatus.active,
          isSelected: false,
          isEnrolled: true),
    ];
    filterUsers(searchController.text);
    _updateUserCount();
  }

  void filterUsers(String query) {
    var tempList = userList.toList();

    // Text search filter
    if (query.isNotEmpty) {
      tempList = tempList
          .where((user) =>
              user.name.toLowerCase().contains(query.toLowerCase()) ||
              user.email.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    // Enrolled filter
    if (enrolledFilter.value != 'All') {
      bool isTargetEnrolled = enrolledFilter.value == 'Yes';
      tempList = tempList
          .where((user) => user.isEnrolled == isTargetEnrolled)
          .toList();
    }

    // A-Z sorting by First Name (Name)
    tempList
        .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    filteredUserList.value = tempList;
    _updateSelectAllState();
  }

  void toggleUserSelection(int index) {
    filteredUserList[index].isSelected = !filteredUserList[index].isSelected;
    filteredUserList.refresh();
    _updateSelectAllState();
  }

  void toggleAllSelection() {
    isAllSelected.value = !isAllSelected.value;
    for (var user in filteredUserList) {
      user.isSelected = isAllSelected.value;
    }
    filteredUserList.refresh();
  }

  void _updateSelectAllState() {
    if (filteredUserList.isEmpty) {
      isAllSelected.value = false;
      return;
    }
    isAllSelected.value = filteredUserList.every((user) => user.isSelected);
  }

  void editUser(UserModel user) {
    editingUser = user;
    emailInputController.text = '${user.name}, ${user.email}';
    Get.snackbar('Edit Mode', 'User loaded in ADD/EDIT USERS box.',
        backgroundColor: TeamManagerColors.primaryOrange,
        colorText: Colors.white);
  }

  UserModel? parseSingleEntry(String entry) {
    try {
      final parts = entry.split(',').map((e) => e.trim()).toList();
      if (parts.length != 2) return null;
      final name = parts[0];
      final email = parts[1];
      if (name.isEmpty || email.isEmpty || !email.contains('@')) return null;
      return UserModel(
          name: name,
          email: email,
          status: UserStatus.pending,
          isSelected: false);
    } catch (e) {
      return null;
    }
  }

  List<UserModel> parseMultipleEntries(String csvData) {
    final lines = csvData
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final users = <UserModel>[];
    for (final line in lines) {
      final user = parseSingleEntry(line);
      if (user != null) users.add(user);
    }
    return users;
  }

  void addUserEmail() {
    final input = emailInputController.text.trim();
    if (input.isEmpty) {
      Get.snackbar('Error', 'Please enter user information',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    // Handle Edit Mode
    if (editingUser != null) {
      final singleUser = parseSingleEntry(input);
      if (singleUser != null) {
        editingUser!.name = singleUser.name;
        editingUser!.email = singleUser.email;
        filterUsers(searchController.text);
        emailInputController.clear();
        editingUser = null;
        Get.snackbar('Success', 'User updated successfully',
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        Get.snackbar('Invalid Format',
            'Use format: "Firstname Lastname, email@email.com"',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
      return;
    }

    final lines = input.split('\n').where((e) => e.trim().isNotEmpty).toList();
    int pendingCount = lines.length;
    int totalAfterAdd = userList.length + pendingCount;

    if (totalAfterAdd > userLimit.value) {
      int exceededBy = totalAfterAdd - userLimit.value;
      int availableSlots = userLimit.value - userList.length;
      Get.snackbar('Limit Exceeded',
          'Trying to add $pendingCount users but only $availableSlots seats available. Over by $exceededBy.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 6));
      return;
    }

    final singleUser = parseSingleEntry(input);
    if (singleUser != null) {
      userList.add(singleUser);
      filterUsers(searchController.text);
      emailInputController.clear();
      Get.snackbar('Success', 'Invitation sent to ${singleUser.email}',
          backgroundColor: Colors.green, colorText: Colors.white);
      return;
    }

    final multipleUsers = parseMultipleEntries(input);
    if (multipleUsers.isNotEmpty) {
      userList.addAll(multipleUsers);
      filterUsers(searchController.text);
      emailInputController.clear();
      Get.snackbar(
          'Success', '${multipleUsers.length} user(s) added successfully',
          backgroundColor: Colors.green, colorText: Colors.white);
      return;
    }

    Get.snackbar(
        'Invalid Format', 'Use format: "Firstname Lastname, email@email.com"',
        backgroundColor: Colors.red, colorText: Colors.white);
  }

  void importUsers() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      String? filePath = result.files.single.path;
      if (filePath == null) {
        Get.snackbar('Error', 'Could not access file',
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      final file = File(filePath);
      String csvString;
      try {
        csvString = await file.readAsString();
      } catch (e) {
        Get.snackbar('Error', 'Could not read file.',
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      List<List<dynamic>> csvData;
      try {
        csvData = const CsvToListConverter()
            .convert(csvString, eol: '\n', shouldParseNumbers: false);
      } catch (e) {
        Get.snackbar('Error', 'Invalid CSV format',
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      if (csvData.isEmpty) {
        Get.snackbar('Error', 'CSV file is empty',
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      StringBuffer importedText = StringBuffer();
      int successCount = 0;
      int skipCount = 0;

      for (var row in csvData) {
        if (row.isEmpty) continue;
        String name = '';
        String email = '';

        if (row.length == 1) {
          email = row[0].toString().trim();
          name = email.split('@')[0];
        } else if (row.length >= 2) {
          if (row.length == 2) {
            name = row[0].toString().trim();
            email = row[1].toString().trim();
          } else {
            email = row.last.toString().trim();
            name = row.sublist(0, row.length - 1).join(' ').trim();
          }
        }

        if (email.isEmpty || !email.contains('@')) {
          skipCount++;
          continue;
        }

        importedText.writeln('$name, $email');
        successCount++;
      }

      if (successCount == 0) {
        Get.snackbar('Error', 'No valid users found in CSV',
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      emailInputController.text = importedText.toString().trim();
      String message = '$successCount user(s) imported';
      if (skipCount > 0) message += '\n$skipCount invalid entries skipped';
      Get.snackbar('Success', message,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3));
    } catch (e) {
      Get.snackbar('Error', 'Failed to import: ${e.toString()}',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void _updateUserCount() {
    currentUsers.value = userList.length;
    final input = emailInputController.text.trim();
    int pendingUsers = 0;
    if (input.isNotEmpty) {
      pendingUsers = input.split('\n').where((e) => e.trim().isNotEmpty).length;
    }
    remainingSlots.value = userLimit.value - currentUsers.value - pendingUsers;
    update(['add_button']);
  }

  String get limitText {
    int remaining = userLimit.value - currentUsers.value;
    final input = emailInputController.text.trim();
    if (input.isNotEmpty) {
      remaining -= input.split('\n').where((e) => e.trim().isNotEmpty).length;
    }
    return remaining >= 0 ? '+ $remaining' : '$remaining';
  }

  Color get limitColor {
    int remaining = userLimit.value - currentUsers.value;
    final input = emailInputController.text.trim();
    if (input.isNotEmpty) {
      remaining -= input.split('\n').where((e) => e.trim().isNotEmpty).length;
    }
    return remaining >= 0 ? const Color(0xFF12A900) : const Color(0xFFA20000);
  }

  bool canAddUsers() {
    final input = emailInputController.text.trim();
    if (input.isEmpty) return true;
    final lines = input.split('\n').where((e) => e.trim().isNotEmpty).toList();
    return userList.length + lines.length <= userLimit.value;
  }

  Color addButtonColor() =>
      canAddUsers() ? AppColors.orange : const Color(0xFF8F8F8F);

  void cancelInput() {
    emailInputController.clear();
    editingUser = null;
    _updateUserCount();
  }

  void downloadSelected() async {
    if (filteredUserList.isEmpty) {
      Get.snackbar('Warning', 'No users available to download',
          backgroundColor: TeamManagerColors.primaryOrange,
          colorText: Colors.white);
      return;
    }

    try {
      List<List<dynamic>> csvData = [
        ['Name', 'Email', 'Enrolled']
      ];

      for (var user in filteredUserList) {
        csvData.add([user.name, user.email, user.isEnrolled ? 'Yes' : 'No']);
      }

      String csvString = const ListToCsvConverter().convert(csvData);

      // Print the CSV to the console so you can verify it on the frontend!
      debugPrint('--- GENERATED CSV FOR EMAIL ---');
      debugPrint(csvString);
      debugPrint('-------------------------------');

      // Instead of saving to file, we simulate sending the email as per UI requirements
      CustomDialogs.showDownloadSuccess();
    } catch (e) {
      Get.snackbar('Error', 'Failed to generate CSV: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void cancelSelected() {
    searchController.clear();
    enrolledFilter.value = 'All';
    emailInputController.clear();
    editingUser = null;

    for (var user in userList) {
      user.isSelected = false;
    }
    isAllSelected.value = false;

    filterUsers('');
  }

  void resendSelected() {
    final selected = filteredUserList.where((u) => u.isSelected).toList();
    if (selected.isEmpty) {
      Get.snackbar('Warning', 'Please select at least one user',
          backgroundColor: TeamManagerColors.primaryOrange,
          colorText: Colors.white);
      return;
    }
    final resendUsers =
        selected.where((u) => u.status == UserStatus.resend).toList();
    if (resendUsers.isEmpty) {
      Get.snackbar('Warning', 'Selected users do not have "Resend" status',
          backgroundColor: TeamManagerColors.primaryOrange,
          colorText: Colors.white);
      return;
    }
    for (var user in resendUsers) {
      CustomDialogs.showResendConfirmation(
        userName: user.name,
        userEmail: user.email,
        onConfirm: () {
          user.status = UserStatus.pending;
          user.isSelected = false;
          Get.back();
        },
      );
    }
    filteredUserList.refresh();
    _updateSelectAllState();
  }

  void removeSelected() {
    final selected = filteredUserList.where((u) => u.isSelected).toList();
    if (selected.isEmpty) {
      Get.snackbar('Warning', 'Please select at least one user to remove',
          backgroundColor: TeamManagerColors.primaryOrange,
          colorText: Colors.white);
      return;
    }
    CustomDialogs.showRemoveConfirmation(onConfirm: () {
      filteredUserList.removeWhere((u) => u.isSelected);
      userList.removeWhere((u) => u.isSelected);
      Get.back();
    });
  }

  String getStatusText(UserStatus status) {
    switch (status) {
      case UserStatus.active:
        return 'Active';
      case UserStatus.pending:
        return 'Pending';
      case UserStatus.resend:
        return 'Resend';
      case UserStatus.remove:
        return 'Remove';
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    emailInputController.dispose();
    emailInputFocusNode.dispose();
    userListScrollController.dispose();
    emailInputScrollController.dispose();
    super.onClose();
  }
}

// ============================================================
// MODELS & ENUMS
// ============================================================
class UserModel {
  String name;
  String email;
  UserStatus status;
  bool isSelected;
  bool isEnrolled;

  UserModel({
    required this.name,
    required this.email,
    required this.status,
    this.isSelected = false,
    this.isEnrolled = false,
  });
}

enum UserStatus { active, pending, resend, remove }

// ============================================================
// CUSTOM SCROLL INDICATOR
// ============================================================
class CustomScrollIndicator extends StatefulWidget {
  final ScrollController scrollController;
  final double containerHeight;

  const CustomScrollIndicator({
    super.key,
    required this.scrollController,
    required this.containerHeight,
  });

  @override
  State<CustomScrollIndicator> createState() => _CustomScrollIndicatorState();
}

class _CustomScrollIndicatorState extends State<CustomScrollIndicator> {
  double _scrollPosition = 0.0;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (widget.scrollController.hasClients && mounted) {
      setState(() {
        _scrollPosition = widget.scrollController.offset;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.scrollController.hasClients) return const SizedBox.shrink();

    try {
      final position = widget.scrollController.position;
      final maxScroll = position.maxScrollExtent;
      if (maxScroll <= 0) return const SizedBox.shrink();

      final viewportHeight = position.viewportDimension;
      final contentHeight = maxScroll + viewportHeight;
      if (contentHeight <= 0 || widget.containerHeight <= 0) {
        return const SizedBox.shrink();
      }

      final indicatorHeight =
          (viewportHeight / contentHeight) * widget.containerHeight;
      final maxIndicatorTravel = widget.containerHeight - indicatorHeight;
      final indicatorTop = (_scrollPosition / maxScroll) * maxIndicatorTravel;

      return Positioned(
        right: context.w(5),
        top: indicatorTop.clamp(5.0, maxIndicatorTravel),
        child: GestureDetector(
          onVerticalDragUpdate: (details) {
            try {
              final dragRatio = details.delta.dy / widget.containerHeight;
              final newScroll = (_scrollPosition + dragRatio * maxScroll)
                  .clamp(0.0, maxScroll);
              widget.scrollController.jumpTo(newScroll);
            } catch (_) {}
          },
          child: Container(
            // context.w for width, context.h for height — correct
            width: context.w(9),
            height: indicatorHeight.clamp(context.h(5), widget.containerHeight),
            decoration: BoxDecoration(
              color: TeamManagerColors.primaryOrange,
              borderRadius: BorderRadius.circular(context.r(10)),
            ),
          ),
        ),
      );
    } catch (_) {
      return const SizedBox.shrink();
    }
  }
}

// ============================================================
// DIALOGS
// ============================================================
class CustomDialogs {
  // Get.context is reliably available any time Get.dialog can be invoked,
  // so dialogs can be triggered from the controller (no BuildContext there)
  // while still using the same context.w/h/sp/r responsive helpers.
  static void showRemoveConfirmation({required VoidCallback onConfirm}) {
    final context = Get.context!;
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        // context.w for horizontal inset
        insetPadding: EdgeInsets.symmetric(horizontal: context.w(15)),
        child: Container(
          decoration: const BoxDecoration(color: Color(0xFFB71C1C)),
          // context.w for all-side padding (visual consistency)
          padding: EdgeInsets.all(context.w(15)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SvgPicture.asset(
                    "assets/icons/bell-icon.svg",
                    height: context.h(20),
                    width: context.w(20),
                  ),
                  GestureDetector(
                    onTap: onConfirm,
                    child: Container(
                      width: context.w(79),
                      height: context.h(30),
                      decoration: BoxDecoration(
                        color: AppColors.darkGray,
                        borderRadius: BorderRadius.circular(context.r(5)),
                      ),
                      child: Center(
                        child: Text(
                          'Confirm',
                          style: GoogleFonts.lato(
                            color: Colors.white,
                            fontSize: context.sp(14),
                            fontWeight: FontWeight.w700,
                            // lineHeight — NO context.h, pure multiplier
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.h(10)),
              Text(
                'You are about to remove the selected User(s). Tap Confirm to continue.',
                textAlign: TextAlign.start,
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: context.sp(14),
                  fontWeight: FontWeight.w400,
                  // NO context.h on lineHeight
                  height: 1.5,
                ),
              ),
              SizedBox(height: context.h(24)),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  static void showDownloadSuccess() {
    final context = Get.context!;
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: context.w(15)),
        child: Container(
          decoration: const BoxDecoration(color: Color(0xFFB71C1C)),
          padding: EdgeInsets.all(context.w(15)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SvgPicture.asset(
                    "assets/icons/bell-icon.svg",
                    height: context.h(20),
                    width: context.w(20),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: SvgPicture.asset(
                      "assets/icons/Close-X-Circle.svg",
                      height: context.h(20),
                      width: context.w(20),
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.h(10)),
              Text(
                'Your Users list has been emailed to you at the email associated with this account. It is in .CSV format.',
                textAlign: TextAlign.start,
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: context.sp(14),
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
              SizedBox(height: context.h(24)),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  static void showResendConfirmation({
    required String userName,
    required String userEmail,
    required VoidCallback onConfirm,
  }) {
    final context = Get.context!;
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: context.w(15)),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.green.shade700,
            borderRadius: BorderRadius.circular(context.r(12)),
          ),
          padding: EdgeInsets.only(
              left: context.w(15),
              right: context.w(15),
              top: context.w(20),
              bottom: context.w(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_outline,
                  color: Colors.white, size: context.sp(60)),
              SizedBox(height: context.h(20)),
              Text(
                'Email Sent!',
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: context.sp(22),
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.h(15)),
              Text(
                'An email invite has been sent to',
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: context.sp(16),
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.h(8)),
              Text(
                userName,
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: context.sp(18),
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.h(4)),
              Text(
                userEmail,
                style: GoogleFonts.lato(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: context.sp(14),
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.h(15)),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: context.w(15), vertical: context.h(10)),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(context.r(8)),
                ),
                child: Text(
                  'They will have 7 days to respond.\nStatus will change to "Pending".',
                  style: GoogleFonts.lato(
                    color: Colors.white,
                    fontSize: context.sp(14),
                    fontWeight: FontWeight.w500,
                    // NO context.h
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: context.h(25)),
              GestureDetector(
                onTap: onConfirm,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: context.h(12)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(context.r(8)),
                  ),
                  child: Text(
                    'OK',
                    style: GoogleFonts.lato(
                      color: Colors.green.shade700,
                      fontSize: context.sp(18),
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  static void showHelpDialog() {
    final context = Get.context!;
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: context.w(15)),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.medGray,
            borderRadius: BorderRadius.circular(context.r(8)),
          ),
          padding: EdgeInsets.only(
              left: context.w(15),
              right: context.w(15),
              top: context.w(20),
              bottom: context.w(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SvgPicture.asset("assets/icons/dulogbox_person.svg",
                      width: context.w(30), height: context.h(30)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: SvgPicture.asset("assets/icons/Close-X-Circle.svg",
                        width: context.w(30), height: context.h(30)),
                  ),
                ],
              ),
              SizedBox(height: context.h(16)),
              _buildInstructionText(
                context,
                title: 'Single entry:',
                content:
                    'Tap inside field below, type first/last name and email separated by a comma.',
              ),
              _buildInstructionText(
                context,
                title: 'Example:',
                content: 'John Doe, email@email.com',
                isExample: true,
              ),
              SizedBox(height: context.h(12)),
              _buildInstructionText(
                context,
                title: 'Multiple entries:',
                content:
                    'Tap Import. List must be comma delineated in .CSV format, one user per line.',
              ),
              SizedBox(height: context.h(12)),
              Text(
                'After import, tap on name or email to edit. Clicking on Add moves the list to the Users list above.',
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: context.sp(16),
                  fontWeight: FontWeight.w500,
                  // NO context.h
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  static Widget _buildInstructionText(
    BuildContext context, {
    required String title,
    required String content,
    bool isExample = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.h(8)),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.lato(
            color: Colors.white,
            fontSize: context.sp(16),
            fontWeight: FontWeight.w400,
            // NO context.h on lineHeight
            height: 1.5,
          ),
          children: [
            TextSpan(
                text: title,
                style: GoogleFonts.lato(fontWeight: FontWeight.w700)),
            const TextSpan(text: ' '),
            TextSpan(
              text: content,
              style: GoogleFonts.lato(
                  fontStyle: isExample ? FontStyle.italic : FontStyle.normal),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// MAIN SCREEN
// ============================================================
class TeamManager extends StatelessWidget {
  TeamManager({super.key});

  final controller = Get.put(TeamManagerController());

  @override
  Widget build(BuildContext context) {
    final bool isLandscape = context.landscape;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1129),
      resizeToAvoidBottomInset: false,
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
          child: isLandscape
              ? _buildLandscapeLayout(context)
              : _buildPortraitLayout(context),
        ),
      ),
      bottomNavigationBar: const CustomNavbar(),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // PORTRAIT LAYOUT
  // ─────────────────────────────────────────────────────────────
  Widget _buildPortraitLayout(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          elevation: 0,
          backgroundColor: const Color(0xFF0B1129),
          automaticallyImplyLeading: false,
          // Matches 20.h top margin across all screens ((152 - 112) / 2 = 20)
          toolbarHeight: context.h(152),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(ImageManager.mapBackground),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(child: _buildLogo(context)),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: context.w(20)),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildBodyContent(context),
            ]),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // LANDSCAPE LAYOUT (mirrors history_screen / account_screen)
  // ─────────────────────────────────────────────────────────────
  Widget _buildLandscapeLayout(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.s(12)),
      child: Flex(
        direction: Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LEFT — sticky logo
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.35,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: context.h(10)),
                _buildLogo(context),
              ],
            ),
          ),
          SizedBox(width: context.w(15)),
          // RIGHT — scrollable content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: _buildBodyContent(context),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // SHARED BODY CONTENT
  // ─────────────────────────────────────────────────────────────
  Widget _buildBodyContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Team Manager',
          style: GoogleFonts.lato(
            color: Colors.white,
            fontSize: context.sp(32),
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            // NO context.h — lineHeight is a multiplier
            height: 0.88,
          ),
        ),
        SizedBox(height: context.h(8)),
        Divider(color: AppColors.dividerColor, thickness: 1),
        SizedBox(height: context.h(3)),
        _buildSubscriptionInfo(context),
        SizedBox(height: context.h(15)),
        Divider(color: AppColors.dividerColor, thickness: 1),
        SizedBox(height: context.h(20)),
        _buildUsersSection(context),
        GestureDetector(
          onTap: () => Get.offAllNamed(AppRoutes.accountScreen),
          child: Text(
            'Manage Account',
            textAlign: TextAlign.left,
            style: TextStyle(
              color: const Color(0xFF9DACF5),
              fontSize: context.sp(18),
              fontFamily: 'Lato',
              fontWeight: FontWeight.w500,
              // NO context.h
              height: 1.78,
            ),
          ),
        ),
        SizedBox(height: context.h(20)),
      ],
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Container(
      width: context.w(225),
      height: context.h(112),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(ImageManager.splashScreenLogo),
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildSubscriptionInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CURRENT PLAN',
          style: GoogleFonts.leagueGothic(
            color: AppColors.orange,
            fontSize: context.sp(28),
            fontWeight: FontWeight.w400,
            // NO context.h
            height: 1.56,
            letterSpacing: 1.50,
          ),
        ),
        SizedBox(height: context.h(8)),
        _buildInfoText(context, 'Up to 100 users'),
        _buildInfoText(context, 'Enrolled user total: 0 of 100'),
        _buildInfoText(context, 'Renewal date: [Month/Day/Year]'),
        _buildInfoText(context, 'Subscription ID: sub.100 monthly'),
        GestureDetector(
          onTap: () => Get.toNamed(AppRoutes.chooseATeamPlan),
          child: Text(
            'Upgrade / Downgrade',
            style: GoogleFonts.lato(
              color: AppColors.purple,
              fontSize: context.sp(18),
              fontWeight: FontWeight.w400,
              // NO context.h
              height: 1.56,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoText(BuildContext context, String text) {
    return Padding(
      // context.h for vertical padding only
      padding: EdgeInsets.only(bottom: context.h(8)),
      child: Text(
        text,
        style: GoogleFonts.lato(
          color: Colors.white,
          fontSize: context.sp(18),
          fontWeight: FontWeight.w400,
          // NO context.h
          // height: 1.56,
        ),
      ),
    );
  }

  Widget _buildUsersSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSearchHeader(context),
        SizedBox(height: context.h(16)),
        _buildUserListTable(context),
        SizedBox(height: context.h(16)),
        _buildActionButtons(context),
         SizedBox(height: context.h(16)),
        Divider(color: AppColors.dividerColor, thickness: 1),
        _buildAddEditUsersSection(context),
        SizedBox(height: context.h(25)),
        Divider(color: AppColors.dividerColor, thickness: 1),
        SizedBox(height: context.h(10)),
      ],
    );
  }

  Widget _buildSearchHeader(BuildContext context) {
    return Row(
      children: [
        Text(
          'USERS',
          style: GoogleFonts.leagueGothic(
            color: AppColors.orange,
            fontSize: context.sp(26),
            fontWeight: FontWeight.w400,
            // NO context.h
            height: 1.17,
            letterSpacing: 1.50,
          ),
        ),
        SizedBox(width: context.w(8)),
        // Everything after the title shares the remaining width, so it
        // shrinks gracefully instead of overflowing past the screen edge.
        Expanded(
          child: Row(
            children: [
              Obx(() => Container(
                    height: context.h(32),
                    width: context.w(50),
                    padding: EdgeInsets.only(left: context.w(8)),
                    decoration: BoxDecoration(
                      color: AppColors.medGray,
                      borderRadius: BorderRadius.circular(context.r(4)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: controller.enrolledFilter.value,
                        isExpanded: true,
                        dropdownColor: AppColors.medGray,
                        icon: Icon(Icons.arrow_drop_down,
                            color: Colors.white, size: context.sp(20)),
                        style: GoogleFonts.lato(
                            color: Colors.white, fontSize: context.sp(14)),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            controller.enrolledFilter.value = newValue;
                            controller
                                .filterUsers(controller.searchController.text);
                          }
                        },
                        items: <String>['All', 'Yes', 'No']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  )),
              SizedBox(width: context.w(8)),
              Icon(Icons.search,
                  color: TeamManagerColors.primaryWhite, size: context.sp(22)),
              SizedBox(width: context.w(2)),
              // Search box now flexes to fill whatever space is left instead
              // of a fixed width, so it never pushes the GO button off-screen.
              Expanded(
                child: Container(
                  height: context.h(32),
                  padding: EdgeInsets.symmetric(horizontal: context.w(12)),
                  decoration: BoxDecoration(
                    color: AppColors.medGray,
                    borderRadius: BorderRadius.circular(context.r(4)),
                  ),
                  child: Center(
                    child: Material(
                      color: Colors.transparent,
                      child: TextField(
                        controller: controller.searchController,
                        cursorColor: AppColors.white,
                        cursorHeight: context.h(18),
                        style: GoogleFonts.lato(
                          color: Colors.white,
                          fontSize: context.sp(14),
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search users...',
                          hintStyle: GoogleFonts.lato(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: context.sp(14),
                            fontWeight: FontWeight.w500,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: context.w(3)),
              GestureDetector(
                onTap: () =>
                    controller.filterUsers(controller.searchController.text),
                child: Container(
                  width: context.w(33),
                  height: context.h(32),
                  decoration: BoxDecoration(
                    color: AppColors.medGray,
                    borderRadius: BorderRadius.circular(context.r(4)),
                  ),
                  child: Center(
                    child: Text(
                      'GO',
                      style: GoogleFonts.lato(
                        color: Colors.white,
                        fontSize: context.sp(16),
                        fontWeight: FontWeight.w700,
                        // NO context.h
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserListTable(BuildContext context) {
    // context.h diye responsive — 375 base e 224 = correct
    final double containerHeight = context.h(158);

    return Obx(() {
      if (controller.filteredUserList.isEmpty) {
        return _buildEmptyState(context);
      }

      return Container(
        decoration: BoxDecoration(
          color: AppColors.darkGray,
          borderRadius: BorderRadius.circular(context.r(8)),
        ),
        child: Column(
          children: [
            _buildTableHeader(context),
            Stack(
              children: [
                Container(
                  constraints: BoxConstraints(maxHeight: containerHeight),
                  child: SingleChildScrollView(
                    controller: controller.userListScrollController,
                    child: Column(
                      children: List.generate(
                        controller.filteredUserList.length,
                        (index) => _buildTableRow(context, index),
                      ),
                    ),
                  ),
                ),
                CustomScrollIndicator(
                  scrollController: controller.userListScrollController,
                  containerHeight: containerHeight,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTableHeader(BuildContext context) {
    return Container(
      // context.w horizontal, context.h vertical
      padding: EdgeInsets.symmetric(horizontal: context.w(16), vertical: context.h(12)),
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(context.r(8)),
          topRight: Radius.circular(context.r(8)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Name',
              style: GoogleFonts.lato(
                color: Colors.white,
                fontSize: context.sp(16),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              'Email',
              style: GoogleFonts.lato(
                color: Colors.white,
                fontSize: context.sp(16),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Enrolled',
              maxLines: 1,
              overflow: TextOverflow.visible,
              softWrap: false,
              style: GoogleFonts.lato(
                color: Colors.white,
                fontSize: context.sp(16),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            width: context.w(70),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Obx(() => GestureDetector(
                      onTap: controller.toggleAllSelection,
                      child: Container(
                        alignment: Alignment.center,
                        width: 20.0,
                        height: 20.0,
                        decoration: BoxDecoration(
                          color: controller.isAllSelected.value
                              ? AppColors.orange
                              : Colors.transparent,
                          border: Border.all(color: Colors.white, width: 1.5),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: controller.isAllSelected.value
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 16.0)
                            : null,
                      ),
                    )),
                SizedBox(width: context.w(8)),
                GestureDetector(
                  onTap: () => _showUserManagementHelp(context),
                  child: SvgPicture.asset(
                    "assets/icons/Question-Box-gray.svg",
                    width: context.w(24),
                    height: context.h(24),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(BuildContext context, int index) {
    return Obx(() {
      final user = controller.filteredUserList[index];
      final nameEmailColor = user.isSelected
          ? TeamManagerColors.primaryOrange
          : TeamManagerColors.primaryWhite;
      final statusColor = _getTextColor(user.status);

      return Container(
        // context.w horizontal, context.h vertical
        padding: EdgeInsets.symmetric(horizontal: context.w(16), vertical: context.h(10)),
        decoration: BoxDecoration(
          color: AppColors.darkGray,
          border:
              Border(bottom: BorderSide(color: AppColors.medGray, width: 1)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                user.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.lato(
                  color: nameEmailColor,
                  fontSize: context.sp(14),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Text(
                user.email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.lato(
                  color: nameEmailColor,
                  fontSize: context.sp(14),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                user.isEnrolled ? 'Yes' : 'No',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.lato(
                  color: user.isEnrolled ? Colors.green : Colors.red,
                  fontSize: context.sp(14),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(
              width: context.w(70),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => controller.toggleUserSelection(index),
                    child: Container(
                      alignment: Alignment.center,
                      width: 20.0,
                      height: 20.0,
                      decoration: BoxDecoration(
                        color: user.isSelected
                            ? TeamManagerColors.primaryOrange
                            : Colors.transparent,
                        border: Border.all(color: Colors.white, width: 1.5),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: user.isSelected
                          ? const Icon(Icons.close,
                              color: Colors.white, size: 16.0)
                          : null,
                    ),
                  ),
                  SizedBox(width: context.w(8)),
                  GestureDetector(
                    onTap: () => controller.editUser(user),
                    child: SvgPicture.asset(
                      "assets/icons/Edit-Pencil-white.svg",
                      width: context.w(24),
                      height: context.h(24),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  void _showUserManagementHelp(BuildContext context) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: context.w(15)),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.medGray,
            borderRadius: BorderRadius.circular(context.r(8)),
          ),
          padding: EdgeInsets.only(
              left: context.w(15),
              right: context.w(15),
              top: context.w(20),
              bottom: context.w(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SvgPicture.asset("assets/icons/Edit-Pencil-white.svg",
                      height: context.h(30), width: context.w(30)),
                  SizedBox(width: context.w(12)),
                  Expanded(
                    child: Text(
                      'User Management',
                      style: GoogleFonts.lato(
                        color: Colors.white,
                        fontSize: context.sp(17),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Padding(
                      padding: EdgeInsets.all(context.w(4)),
                      child: SvgPicture.asset("assets/icons/Close-X-Circle.svg",
                          height: context.h(30), width: context.w(30)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.h(16)),
              Text(
                '• Click the checkbox to select individual users\n'
                '• Click the checkbox in the header to select/deselect all users\n'
                '• Click the pencil icon to edit a user\'s information\n'
                '• Select users and click action buttons for bulk operations',
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: context.sp(16),
                  fontWeight: FontWeight.w400,
                  // NO context.h
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.w(32)),
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        borderRadius: BorderRadius.circular(context.r(8)),
      ),
      child: Center(
        child: Text(
          'No users found',
          style: GoogleFonts.lato(
            color: TeamManagerColors.primaryWhite.withValues(alpha: 0.6),
            fontSize: context.sp(16),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
            width: context.w(80),
            child: _buildActionButton(
                context, 'Download', controller.downloadSelected)),
        SizedBox(width: context.w(10)),
        SizedBox(
            width: context.w(80),
            child: _buildActionButton(
                context, 'Cancel', controller.cancelSelected)),
        SizedBox(width: context.w(10)),
        SizedBox(
            width: context.w(80),
            child: _buildActionButton(
                context, 'Remove', controller.removeSelected)),
      ],
    );
  }

  Widget _buildActionButton(
      BuildContext context, String label, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        // context.w horizontal, context.h vertical
        padding: EdgeInsets.symmetric(horizontal: context.w(1), vertical: context.h(2)),
        decoration: BoxDecoration(
          color: AppColors.orange,
          borderRadius: BorderRadius.circular(context.r(5)),
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: context.sp(16),
              fontFamily: 'Lato',
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddEditUsersSection(BuildContext context) {
    // context.h diye responsive
    final double containerHeight = context.h(265);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: context.h(12)),
          child: Row(
            children: [
              Text(
                'ADD / EDIT USERS',
                style: GoogleFonts.leagueGothic(
                  color: AppColors.orange,
                  fontSize: context.sp(26),
                  fontWeight: FontWeight.w400,
                  // NO context.h
                  height: 1.17,
                  letterSpacing: 1.50,
                ),
              ),
              SizedBox(width: context.w(3)),
              GestureDetector(
                onTap: CustomDialogs.showHelpDialog,
                child: SvgPicture.asset(
                  "assets/icons/Question-Box-gray.svg",
                  height: context.h(21),
                  width: context.w(21),
                ),
              ),
            ],
          ),
        ),
        Stack(
          children: [
            Container(
              height: containerHeight,
              // context.w for all-side padding
              padding: EdgeInsets.all(context.w(16)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(context.r(8)),
                border:
                    Border.all(color: TeamManagerColors.borderColor, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      controller: controller.emailInputScrollController,
                      child: TextField(
                        controller: controller.emailInputController,
                        focusNode: controller.emailInputFocusNode,
                        maxLines: null,
                        minLines: 10,
                        style: GoogleFonts.lato(
                          color: Colors.black,
                          fontSize: context.sp(16),
                        ),
                        decoration: InputDecoration(
                          hintStyle: GoogleFonts.lato(
                            color: Colors.black.withValues(alpha: 0.4),
                            fontSize: context.sp(16),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ),
                  Divider(color: AppColors.darkGray, thickness: 1),
                  Obx(() => Text(
                        controller.limitText,
                        style: GoogleFonts.lato(
                          color: controller.limitColor,
                          fontSize: context.sp(16),
                          fontWeight: FontWeight.w400,
                        ),
                      )),
                ],
              ),
            ),
            CustomScrollIndicator(
              scrollController: controller.emailInputScrollController,
              containerHeight: containerHeight,
            ),
          ],
        ),
        SizedBox(height: context.h(16)),
        Row(
          children: [
            SizedBox(
              width: context.w(84),
              child: _buildActionButton(
                  context, 'Import', controller.importUsers),
            ),
            const Spacer(),
            SizedBox(
              width: context.w(84),
              child: _buildActionButton(
                  context, 'Cancel', controller.cancelInput),
            ),
            SizedBox(width: context.w(12)),
            SizedBox(
              width: context.w(64),
              child: GetBuilder<TeamManagerController>(
                id: 'add_button',
                builder: (ctrl) {
                  return GestureDetector(
                    onTap: ctrl.canAddUsers()
                        ? ctrl.addUserEmail
                        : () => Get.snackbar(
                              'Cannot Add',
                              'User limit exceeded. Remove some users or upgrade your plan.',
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                              duration: const Duration(seconds: 4),
                            ),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: context.w(1), vertical: context.h(2)),
                      decoration: BoxDecoration(
                        color: ctrl.addButtonColor(),
                        borderRadius: BorderRadius.circular(context.r(5)),
                      ),
                      child: Center(
                        child: Text(
                          'Add',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: context.sp(15),
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getTextColor(UserStatus status) {
    switch (status) {
      case UserStatus.active:
        return TeamManagerColors.primaryOrange;
      case UserStatus.pending:
        return TeamManagerColors.primaryWhite;
      case UserStatus.resend:
        return TeamManagerColors.primaryOrange;
      case UserStatus.remove:
        return TeamManagerColors.primaryWhite;
    }
  }
}