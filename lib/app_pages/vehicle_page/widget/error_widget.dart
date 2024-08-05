import 'package:flutter/material.dart';

import '../../../app_themes/app_colors.dart';

class NoMatches extends StatelessWidget {
  const NoMatches({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SizedBox(height: 25),
        Text(
          "Oh Snap!",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 16),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 25),
          child: Text(
            "Bikes of your preference are currently on an adventure. Why not try other options?",
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 25),
      ],
    );
  }
}
