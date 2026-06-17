import 'package:nasmotives/presentation/shared/theme/app_colors.dart';
import 'package:nasmotives/presentation/shared/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NasMotivesWatermark extends StatelessWidget {
  const NasMotivesWatermark({
    super.key,
    required this.backgroundColor,
    required this.textColor,
  });

  final Color backgroundColor;
  final Color textColor;

  static const _txt = 'nasmotives · Powered by NasTech AI';

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        decoration: ShapeDecoration(
          color: backgroundColor,
          shape: const RoundedSuperellipseBorder(
            borderRadius: BorderRadius.all(Radius.circular(24)),
            side: BorderSide(color: AppColors.black10),
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Text(_txt, style: bodyS.copyWith(color: textColor)),
      ),
    );
  }
}
