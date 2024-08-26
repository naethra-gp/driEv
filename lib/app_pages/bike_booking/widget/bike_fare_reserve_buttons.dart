import 'package:flutter/material.dart';

import '../../../app_themes/app_colors.dart';

class BikeFareReserveButtons extends StatelessWidget {
  final double? height;
  final String title;
  final VoidCallback? onPressed;
  final bool selected;

  const BikeFareReserveButtons({
    super.key,
    this.height,
    required this.onPressed,
    required this.selected,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 40,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          // textStyle: const TextStyle(
          //   color: Colors.black,
          //   fontWeight: FontWeight.normal,
          //   fontSize: 12,
          // ),
          foregroundColor: Colors.black,
          backgroundColor: selected ? Colors.white : const Color(0xffF5F5F5),
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            // vertical: 10,
          ),
          animationDuration: const Duration(seconds: 1),
          splashFactory: InkRipple.splashFactory,
          side: BorderSide(
            color: selected ? AppColors.primary : const Color(0xFFE1E1E1),
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text('$title mins',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black,
            )),
      ),
    );
  }
}
