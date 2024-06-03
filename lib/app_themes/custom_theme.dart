import 'package:flutter/material.dart';

import 'app_colors.dart';

class CustomTheme {
  CustomTheme._();

  static TextStyle listTittleStyle = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: 14,
  );

  static List<BoxShadow>? boxShadow = [
    const BoxShadow(color: Colors.black54, blurRadius: .75, spreadRadius: .75),
  ];
  static BoxDecoration decoration = BoxDecoration(
    // boxShadow: CustomTheme.boxShadow,
    color: Colors.white,
    borderRadius: BorderRadius.circular(5.0),
    border: Border.all(color: const Color(0xffD2D2D2), width: 1),
  );
  static BoxDecoration selectedDecoration = BoxDecoration(
    boxShadow: const [
      BoxShadow(color: AppColors.primary),
    ],
    color: const Color(0xffF5F5F5),
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: AppColors.primary, width: 1),
  );
  static TextStyle successPageSubTitle = const TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.black87,
    fontSize: 20,
    // wordSpacing: 5,
  );
  static TextStyle title1 = const TextStyle(
    color: AppColors.primary,
    fontSize: 22,
    fontWeight: FontWeight.normal,
  );
  static TextStyle subTittle1 = const TextStyle(
    color: Colors.black87,
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );
  static TextStyle successPageTitle = const TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );
  static TextStyle formHintStyle = const TextStyle(
    fontSize: 12,
    // fontWeight: FontWeight.bold,
    color: Colors.grey,
  );
  static TextStyle formLabelStyle = const TextStyle(
    color: Colors.black54,
    // fontWeight: FontWeight.bold,
    fontSize: 12,
  );
  static TextStyle formFieldStyle = const TextStyle(
    fontSize: 14,
    // fontWeight: FontWeight.bold,
    color: Colors.black,
    // letterSpacing: 1,
    // wordSpacing: 2,
  );
  static BoxDecoration get fillGrey =>
      const BoxDecoration(color: Color(0xffF5F5F5));

  static SizedBox defaultHeight10 = const SizedBox(height: 15);

}
