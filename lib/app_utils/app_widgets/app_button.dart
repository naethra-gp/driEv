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
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xFF3DB54A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          textStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        child: Text(
          title.toString(),
        ),
      ),
    );
  }
}
