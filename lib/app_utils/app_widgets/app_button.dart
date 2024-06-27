import 'package:flutter/material.dart';

import '../../app_themes/app_colors.dart';

class AppButtonWidget extends StatelessWidget {
  final VoidCallback? onPressed;
  final String title;

  const AppButtonWidget({super.key, this.onPressed, required this.title});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 42,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            // fontSize: 15,
          ),
          foregroundColor: Colors.white,
          backgroundColor: AppColors.primary,
          side: const BorderSide(
              color: AppColors.primary, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Text(title.toString(),),
      ),
    );
  }
}
