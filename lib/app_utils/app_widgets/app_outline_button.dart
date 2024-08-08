import 'package:flutter/material.dart';

import '../../app_themes/app_colors.dart';

class OutlineButtonWidget extends StatelessWidget {
  final VoidCallback? onPressed;
  final String title;
  final double? height;
  final Color? foregroundColor;

  const OutlineButtonWidget({
    super.key,
    this.onPressed,
    required this.title,
    this.height,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height ?? 45,
      child: OutlinedButton(
        onPressed: onPressed,
        focusNode: FocusNode(skipTraversal: true),
        style: OutlinedButton.styleFrom(
          elevation: 0,
          textStyle: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          overlayColor: AppColors.primary,
          foregroundColor: foregroundColor ?? Colors.black,
          backgroundColor: Colors.white,
          disabledForegroundColor: AppColors.gray,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
          side: const BorderSide(color: AppColors.primary, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        child: Text(
          title.toString(),
          style: const TextStyle(
            fontFamily: "Roboto",
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
