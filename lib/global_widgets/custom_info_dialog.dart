import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:right_routes/utils/colors.dart';

void showCustomInfoDialog({
  required BuildContext context,
  Widget? icon,
  List<String>? texts,
  List<Widget>? customWidgets,
}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.only(left: 20.w, right: 20.w),
        child: Container(
          padding:
              EdgeInsets.only(left: 15.w, right: 15.w, top: 20.w, bottom: 20.w),
          decoration: BoxDecoration(
            color: AppColors.medGray,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: icon != null
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.end,
                children: [
                  /// Left Icon (passed dynamically)
                  if (icon != null) icon,

                  /// Close button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: SvgPicture.asset(
                      "assets/icons/Close-X-Circle.svg",
                      height: 24.h,
                      width: 24.w,
                    ),
                  ),
                ],
              ),
              if (icon != null)
                SizedBox(height: 16.h)
              else
                SizedBox(height: 8.h),

              /// -------- DYNAMIC TEXT CONTENT --------
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: customWidgets ??
                        (texts ?? []).map((text) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: Text(
                              text,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.sp,
                                fontFamily: 'Lato',
                                height: 1.55,
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
