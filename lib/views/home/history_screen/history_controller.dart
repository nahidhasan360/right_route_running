import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import 'package:right_routes/utils/colors.dart';

/// ---------------------------------------------------------------------------
/// CONTROLLER (GetX)
/// ---------------------------------------------------------------------------
class HistoryController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  RxString searchQuery = "".obs;
  RxBool selectAll = false.obs;

  RxList<RouteItem> routes = <RouteItem>[
    RouteItem(
      id: "001",
      date: "05/26/2025",
      title: "Aurora Wind Farm in Tygard",
      isSelected: false.obs,
    ),
    RouteItem(
      id: "002",
      date: "06/04/2025",
      title: "Badger Wind Farm in Logan",
      isSelected: false.obs,
    ),
    RouteItem(
      id: "003",
      date: "06/12/2025",
      title: "Propane Tanks Downtown Fargo",
      isSelected: false.obs,
    ),
    RouteItem(
      id: "004",
      date: "06/21/2025",
      title: "Beethoven Wind SD",
      isSelected: false.obs,
      highlighted: true,
    ),
    RouteItem(
      id: "005",
      date: "07/15/2025",
      title: "Crane move in Dallas",
      isSelected: false.obs,
    ),
    RouteItem(
      id: "006",
      date: "08/28/2025",
      title: "Equipment Transport",
      isSelected: false.obs,
    ),
  ].obs;

  void updateSearch(String value) {
    searchQuery.value = value;
  }

  void toggleSelectAll() {
    selectAll.value = !selectAll.value;
    for (var route in routes) {
      route.isSelected.value = selectAll.value;
    }
  }

  void toggleRoute(int index) {
    routes[index].isSelected.value = !routes[index].isSelected.value;
    selectAll.value = routes.every((route) => route.isSelected.value);
  }

  void deleteSelected() {
    final selectedCount =
        routes.where((route) => route.isSelected.value).length;

    if (selectedCount == 0) {
      Get.snackbar(
        'No Selection',
        'Please select routes to delete',
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 15.w),
        child: Container(
          decoration: const BoxDecoration(color: Color(0xFFB71C1C)),
          padding: EdgeInsets.all(15.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.notifications, color: Colors.white, size: 20),
                  GestureDetector(
                    onTap: () {
                      routes.removeWhere((route) => route.isSelected.value);
                      selectAll.value = false;
                      Get.back();
                      Get.snackbar(
                        'Success',
                        'Routes deleted successfully',
                        backgroundColor: Colors.green.shade400,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.TOP,
                      );
                    },
                    child: Container(
                      // ✅ UPDATED: Fluid padding instead of fixed height/width
                      padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 6.r),
                      decoration: BoxDecoration(
                        color: AppColors.darkGray,
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      child: Center(
                        child: Text(
                          'Confirm',
                          style: GoogleFonts.lato(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Text(
                'Are you sure you want to delete $selectedCount Route(s)?',
                textAlign: TextAlign.start,
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  height: 1.5.h,
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  void duplicateSelected() {
    final selectedRoutes =
        routes.where((route) => route.isSelected.value).toList();

    if (selectedRoutes.isEmpty) {
      Get.snackbar(
        'No Selection',
        'Please select a route to duplicate',
        backgroundColor: Colors.orange.shade400,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    if (selectedRoutes.length > 1) {
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          backgroundColor: AppColors.darkGray,
          title: Row(
            children: [
              const Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 8.w),
              const Text('Error', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: const Text(
            'You can only duplicate one route at a time. Please check one only.',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      return;
    }

    final routeToDuplicate = selectedRoutes.first;
    Get.toNamed(AppRoutes.confirmYourRoutes, arguments: routeToDuplicate); 

    Get.snackbar(
      'Opening Editor',
      'Edit and save your duplicated route',
      backgroundColor: Colors.blue.shade400,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }

  void cancel() {
    for (var route in routes) {
      route.isSelected.value = false;
      route.highlighted = false;
    }
    selectAll.value = false;

    Get.snackbar(
      'Cancelled',
      'All selections cleared',
      backgroundColor: Colors.grey.shade600,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 1),
    );
  }

  void searchRoutes() {
    final query = searchController.text.trim(); 

    if (query.isEmpty) {
      for (var route in routes) {
        route.highlighted = false;
      }
      Get.snackbar(
        'Search',
        'Please enter a search term',
        backgroundColor: Colors.orange.shade400,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    bool foundMatch = false;

    for (var route in routes) {
      final searchLower = query.toLowerCase();
      final matchesId = route.id.toLowerCase().contains(searchLower);
      final matchesDate = route.date.toLowerCase().contains(searchLower);
      final matchesTitle = route.title.toLowerCase().contains(searchLower);

      if (matchesId || matchesDate || matchesTitle) {
        route.highlighted = true;
        foundMatch = true;
      } else {
        route.highlighted = false;
      }
    }

    routes.refresh(); 

    if (!foundMatch) {
      Get.snackbar(
        'No Results',
        'No routes found matching "$query"',
        backgroundColor: Colors.orange.shade400,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } else {
      Get.snackbar(
        'Search Complete',
        'Found matching routes',
        backgroundColor: Colors.green.shade400,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 1),
      );
    }
  }

  void openRouteDetails(int index) {
    final route = routes[index];

    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.darkGray,
        title: const Text('Route Details', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${route.id}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 8.h),
            Text('Date: ${route.date}', style: const TextStyle(color: Colors.white)),
            SizedBox(height: 8.h),
            Text('Title: ${route.title}', style: const TextStyle(color: Colors.white)),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Get.back(),
              child: const Text('Close', style: TextStyle(color: Colors.white))),
          TextButton(
            onPressed: () {
              Get.back();
              Get.toNamed(AppRoutes.confirmYourRoutes, arguments: route);
            },
            child: const Text('Edit Route', style: TextStyle(color: AppColors.orange)),
          ),
        ],
      ),
    );
  }

  @override
  void onClose() {
    searchController.dispose(); 
    super.onClose();
  }
}

class RouteItem {
  final String id;
  final String date;
  final String title;
  final RxBool isSelected;
  bool highlighted;

  RouteItem({
    required this.id,
    required this.date,
    required this.title,
    required this.isSelected,
    this.highlighted = false,
  });
}