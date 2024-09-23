import 'package:flutter/material.dart';

import '../../app_themes/app_colors.dart';

class AppButtonWidget extends StatelessWidget {
  final VoidCallback? onPressed;
  final String title;
  final double? height;

  const AppButtonWidget({
    super.key,
    this.onPressed,
    required this.title,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height ?? 52,
      child: ElevatedButton(
        onPressed: onPressed,
        focusNode: FocusNode(skipTraversal: true),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xFF3DB54A),
          overlayColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          textStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        child: Text(
          title.toString(),
          style: const TextStyle(
            fontFamily: "Roboto",
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
