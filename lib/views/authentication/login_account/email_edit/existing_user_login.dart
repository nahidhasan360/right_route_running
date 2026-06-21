// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:right_routes/core/routes/all_routes.dart';
// import 'package:right_routes/utils/colors.dart';
// import '../../../../utils/assets_manager.dart';
// import 'package:get/get.dart';
// import 'package:local_auth/local_auth.dart';
// import 'package:flutter/services.dart';
//
// // ============================================================================
// // CONTROLLER WITH BIOMETRIC AUTHENTICATION - FULLY UPDATED
// // ============================================================================
// class LoginController extends GetxController {
//   // Password visibility toggle
//   RxBool hidePassword = true.obs;
//
//   // Touch ID enabled state
//   RxBool isTouchIDEnabled = false.obs;
//
//   // Biometric authentication instance
//   final LocalAuthentication auth = LocalAuthentication();
//
//   // Check if biometric is available
//   RxBool canCheckBiometrics = false.obs;
//   RxBool isBiometricSupported = false.obs;
//
//   // Available biometric types
//   RxList<BiometricType> availableBiometrics = <BiometricType>[].obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     initializeBiometrics();
//   }
//
//   void togglePassword() {
//     hidePassword.value = !hidePassword.value;
//   }
//
//   void toggleTouchID(bool value) {
//     isTouchIDEnabled.value = value;
//     print('✅ Touch ID enabled: $value');
//   }
//
//   // Initialize all biometric checks
//   Future<void> initializeBiometrics() async {
//     await checkBiometricSupport();
//     await checkAvailableBiometrics();
//   }
//
//   // Check if device supports biometric authentication
//   Future<void> checkBiometricSupport() async {
//     try {
//       canCheckBiometrics.value = await auth.canCheckBiometrics;
//       isBiometricSupported.value = await auth.isDeviceSupported();
//
//       print('🔐 === BIOMETRIC SUPPORT CHECK ===');
//       print('📱 Device supported: ${isBiometricSupported.value}');
//       print('✋ Can check biometrics: ${canCheckBiometrics.value}');
//
//     } catch (e) {
//       print('❌ Error checking biometric support: $e');
//       canCheckBiometrics.value = false;
//       isBiometricSupported.value = false;
//     }
//   }
//
//   // Check available biometric types
//   Future<void> checkAvailableBiometrics() async {
//     try {
//       List<BiometricType> biometrics = await auth.getAvailableBiometrics();
//       availableBiometrics.value = biometrics;
//
//       print('📋 === AVAILABLE BIOMETRICS ===');
//
//       if (biometrics.isEmpty) {
//         print('❌ No biometrics enrolled on this device');
//         print('⚠️ User needs to add fingerprint/face in device settings');
//       } else {
//         if (biometrics.contains(BiometricType.fingerprint)) {
//           print('👆 ✅ Fingerprint available');
//         }
//         if (biometrics.contains(BiometricType.face)) {
//           print('😀 ✅ Face ID available');
//         }
//         if (biometrics.contains(BiometricType.iris)) {
//           print('👁️ ✅ Iris scanner available');
//         }
//         if (biometrics.contains(BiometricType.strong)) {
//           print('💪 ✅ Strong biometric available');
//         }
//         if (biometrics.contains(BiometricType.weak)) {
//           print('⚡ ✅ Weak biometric available');
//         }
//       }
//       print('=================================');
//
//     } catch (e) {
//       print('❌ Error getting available biometrics: $e');
//     }
//   }
//
//   // Authenticate with biometrics
//   Future<bool> authenticateWithBiometrics() async {
//     try {
//       print('\n🚀 === STARTING BIOMETRIC AUTHENTICATION ===');
//       print('📱 Device supported: ${isBiometricSupported.value}');
//       print('✋ Can check biometrics: ${canCheckBiometrics.value}');
//       print('📋 Available biometrics: ${availableBiometrics.length}');
//
//       // Check if biometric is available
//       if (!canCheckBiometrics.value) {
//         print('❌ FAILED: Biometric not available on device');
//         Get.snackbar(
//           'Not Available',
//           'Biometric authentication is not available on this device',
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//           snackPosition: SnackPosition.TOP,
//           duration: Duration(seconds: 3),
//           margin: EdgeInsets.all(10.w),
//         );
//         return false;
//       }
//
//       // Check if any biometrics are enrolled
//       if (availableBiometrics.isEmpty) {
//         print('❌ FAILED: No biometrics enrolled');
//         Get.snackbar(
//           'Setup Required',
//           'Please add fingerprint or face ID in your device settings first',
//           backgroundColor: Colors.orange,
//           colorText: Colors.white,
//           snackPosition: SnackPosition.TOP,
//           duration: Duration(seconds: 4),
//           margin: EdgeInsets.all(10.w),
//         );
//         return false;
//       }
//
//       print('👆 Prompting user for biometric authentication...');
//
//       // Authenticate
//       final bool didAuthenticate = await auth.authenticate(
//         localizedReason: 'Please authenticate to login to Right Routes',
//         options: const AuthenticationOptions(
//           stickyAuth: true,
//           biometricOnly: true,
//           useErrorDialogs: true,
//           sensitiveTransaction: false,
//         ),
//       );
//
//       print('📊 Authentication result: $didAuthenticate');
//
//       if (didAuthenticate) {
//         print('✅ ✅ ✅ AUTHENTICATION SUCCESSFUL! ✅ ✅ ✅');
//
//         // Show success snackbar
//         Get.snackbar(
//           'Success!',
//           'Fingerprint authentication successful!',
//           backgroundColor: Colors.green,
//           colorText: Colors.white,
//           snackPosition: SnackPosition.TOP,
//           duration: Duration(seconds: 2),
//           margin: EdgeInsets.all(10.w),
//           icon: Icon(Icons.check_circle, color: Colors.white, size: 35.sp),
//           shouldIconPulse: true,
//         );
//
//         // Wait a bit before navigation
//         await Future.delayed(Duration(milliseconds: 800));
//
//         print('🚀 Navigating to OTP screen...');
//         Get.toNamed(AppRoutes.otpVerificationScreen);
//
//         return true;
//
//       } else {
//         print('❌ Authentication failed - User cancelled or didn\'t match');
//         Get.snackbar(
//           'Authentication Failed',
//           'Fingerprint not recognized. Please try again.',
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//           snackPosition: SnackPosition.TOP,
//           duration: Duration(seconds: 2),
//           margin: EdgeInsets.all(10.w),
//         );
//         return false;
//       }
//
//     } on PlatformException catch (e) {
//       print('⚠️ === PLATFORM EXCEPTION ===');
//       print('Error code: ${e.code}');
//       print('Error message: ${e.message}');
//       print('Error details: ${e.details}');
//
//       String errorMessage = 'Authentication error';
//
//       // Handle specific error codes
//       switch (e.code) {
//         case 'NotAvailable':
//           errorMessage = 'Biometric authentication is not available';
//           break;
//         case 'NotEnrolled':
//           errorMessage = 'No fingerprint enrolled. Please add one in settings';
//           break;
//         case 'LockedOut':
//           errorMessage = 'Too many attempts. Please try again later';
//           break;
//         case 'PermanentlyLockedOut':
//           errorMessage = 'Biometric authentication is locked. Use device password';
//           break;
//         case 'PasscodeNotSet':
//           errorMessage = 'Please set up a passcode on your device first';
//           break;
//         default:
//           errorMessage = e.message ?? 'Authentication error occurred';
//       }
//
//       Get.snackbar(
//         'Error',
//         errorMessage,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         snackPosition: SnackPosition.TOP,
//         duration: Duration(seconds: 3),
//         margin: EdgeInsets.all(10.w),
//       );
//       return false;
//
//     } catch (e) {
//       print('💥 === GENERAL ERROR ===');
//       print('Error: $e');
//
//       Get.snackbar(
//         'Error',
//         'An unexpected error occurred during authentication',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         snackPosition: SnackPosition.TOP,
//         duration: Duration(seconds: 2),
//         margin: EdgeInsets.all(10.w),
//       );
//       return false;
//     }
//   }
// }
//
// // ============================================================================
// // SCREEN
// // ============================================================================
// class LoginAccount extends StatelessWidget {
//   LoginAccount({super.key});
//
//   final loginTroggleController = Get.put(ToggleController());
//   final controller = Get.put(LoginController());
//
//   @override
//   Widget build(BuildContext context) {
//     ScreenUtil.init(context);
//     return Scaffold(
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         decoration: BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage(ImageManager.mapBackground),
//             fit: BoxFit.cover,
//           ),
//         ),
//         child: SafeArea(
//           child: SingleChildScrollView(
//             padding: EdgeInsets.symmetric(horizontal: 19.w),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 SizedBox(height: 21.h),
//
//                 // Logo
//                 Container(
//                   width: 225.w,
//                   height: 112.h,
//                   decoration: BoxDecoration(
//                     image: DecorationImage(
//                       image: AssetImage(ImageManager.splashScreenLogo),
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//
//                 SizedBox(height: 21.h),
//
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     /// TITLE
//                     Text(
//                       'Good News you already have a Right Route account',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 25.sp,
//                         fontFamily: 'Lato',
//                         fontWeight: FontWeight.w700,
//                         height: 1.12.h,
//                       ),
//                     ),
//
//                     SizedBox(height: 17.h),
//
//                     /// EMAIL TEXT
//                     Text(
//                       'Since you\'ve already used your email to sign up for this service, you can now log in using',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 18.sp,
//                         fontFamily: 'Lato',
//                         fontWeight: FontWeight.w500,
//                         height: 1.44.h,
//                       ),
//                     ),
//
//                     /// EMAIL
//                     Row(
//                       children: [
//                         Text(
//                           'tanvirhasan890@gmail.com',
//                           style: TextStyle(
//                             color: AppColors.white,
//                             fontSize: 18.sp,
//                             fontFamily: 'Lato',
//                             fontWeight: FontWeight.bold,
//                             height: 1.44.h,
//                           ),
//                         ),
//                         SizedBox(width: 4.w),
//                         GestureDetector(
//                           onTap: () {
//                             Get.toNamed(AppRoutes.emailEdit);
//                           },
//                           child: Text(
//                             'edit',
//                             style: TextStyle(
//                               color: AppColors.purple,
//                               fontSize: 18.sp,
//                               fontFamily: 'Lato',
//                               fontWeight: FontWeight.bold,
//                               height: 1.44.h,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//
//                     SizedBox(height: 14.h),
//
//                     Text(
//                       'Enter your current password to log in.',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 18.sp,
//                         fontFamily: 'Lato',
//                         fontWeight: FontWeight.w500,
//                         height: 1.56.h,
//                       ),
//                     ),
//
//                     SizedBox(height: 9.h),
//
//                     /// PASSWORD FIELD
//                     Container(
//                       height: 57.h,
//                       padding: EdgeInsets.symmetric(horizontal: 14.w),
//                       decoration: BoxDecoration(
//                         color: AppColors.medGray,
//                         borderRadius: BorderRadius.circular(10.r),
//                       ),
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: Obx(() => TextField(
//                               obscureText: controller.hidePassword.value,
//                               style: TextStyle(color: Colors.white),
//                               decoration: InputDecoration(
//                                 border: InputBorder.none,
//                                 hintText: 'password',
//                                 hintStyle: TextStyle(
//                                   color: const Color(0xFFBFBFBF),
//                                   fontSize: 16.sp,
//                                   fontFamily: 'Lato',
//                                   fontWeight: FontWeight.w400,
//                                   height: 1.75.h,
//                                 ),
//                               ),
//                             )),
//                           ),
//                           Obx(() => IconButton(
//                             icon: Icon(
//                               controller.hidePassword.value
//                                   ? Icons.visibility_off
//                                   : Icons.visibility,
//                               color: Colors.white54,
//                             ),
//                             onPressed: () => controller.togglePassword(),
//                           )),
//                         ],
//                       ),
//                     ),
//
//                     SizedBox(height: 24.h),
//
//                     /// ============ LOGIN BUTTON + FINGERPRINT ================
//                     Row(
//                       children: [
//                         Expanded(
//                           child: GestureDetector(
//                             onTap: () {
//                               Get.toNamed(AppRoutes.homeNewRoutes);
//                             },
//                             child: Container(
//                               height: 50.h,
//                               decoration: BoxDecoration(
//                                 color: AppColors.orange,
//                                 borderRadius: BorderRadius.circular(10.r),
//                               ),
//                               child: Center(
//                                 child: Text(
//                                   'LOG IN',
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 24.sp,
//                                     fontFamily: "League Gothic",
//                                     fontWeight: FontWeight.w600,
//                                     height: 1.17.h,
//                                     letterSpacing: 2,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         SizedBox(width: 10.w),
//
//                         /// ✅ FINGERPRINT BUTTON - FULLY FUNCTIONAL WITH ANIMATIONS
//                         Obx(() => GestureDetector(
//                           onTap: () async {
//                             print('\n👆 Fingerprint button pressed!');
//                             // Trigger biometric authentication
//                             await controller.authenticateWithBiometrics();
//                           },
//                           child: AnimatedContainer(
//                             duration: Duration(milliseconds: 150),
//                             height: 50.h,
//                             width: 55.w,
//                             decoration: BoxDecoration(
//                               color: controller.availableBiometrics.isEmpty
//                                   ? AppColors.orange
//                                   : AppColors.orange,
//                               borderRadius: BorderRadius.circular(50.r),
//                             ),
//                             child: Center(
//                               child: Icon(
//                                 Icons.fingerprint,
//                                 color: AppColors.white,
//                                 size: 45.sp,
//                               ),
//                             ),
//                           ),
//                         )),
//                       ],
//                     ),
//
//                     SizedBox(height: 15.h),
//
//                     /// ✅ TOUCH ID SWITCH
//                     Row(
//                       children: [
//                         CustomToggleSwitchAdvanced(
//                           height: 24.h,
//                           width: 51.w,
//                           value: loginTroggleController.isEnabled,
//                           onChanged: (val) {
//                             controller.toggleTouchID(val);
//                           },
//                           activeSvgPath: 'assets/icons/Check-orange.svg',
//                           svgColor: AppColors.orange,
//                           activeColor: AppColors.orange,
//                           inactiveColor: Colors.white.withOpacity(0.3),
//                         ),
//                         SizedBox(width: 7.w),
//                         Text(
//                           'Use touch ID',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 16.sp,
//                             fontFamily: 'Lato',
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ],
//                     ),
//
//                     SizedBox(height: 45.h),
//
//                     /// TROUBLE LOGGING IN
//                     GestureDetector(
//                       onTap: () {
//                         Get.toNamed(AppRoutes.otpVerificationScreen);
//                       },
//                       child: Text(
//                         'Having trouble logging in? Send a one time code.',
//                         style: TextStyle(
//                           color: const Color(0xFF9DACF5),
//                           fontSize: 16.sp,
//                           fontFamily: 'Lato',
//                           fontWeight: FontWeight.w500,
//                           height: 1.38.h,
//                         ),
//                         textAlign: TextAlign.start,
//                       ),
//                     ),
//
//                     SizedBox(height: 20.h),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
