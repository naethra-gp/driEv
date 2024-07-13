import 'package:flutter/material.dart';

import '../../../app_themes/app_colors.dart';

class NeedHelpButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String title;

  const NeedHelpButtonWidget({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return SizedBox(
      width: width - 200,
      height: 40,
      child: ElevatedButton(
        onPressed: onPressed,
        style: buttonStyle(),
        child: dynamicButton(icon, title),
      ),
    );
  }

  ButtonStyle buttonStyle() {
    return ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: Colors.black,
      backgroundColor: Colors.white,
      side: const BorderSide(
        color: Color(0xffC7C7C7),
        width: 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
      ),
      textStyle: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w500,
        fontSize: 16,
      ),
    );
  }

  dynamicButton(icon, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 10),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Color(0xff626262),
          ),
        ),
      ],
    );
  }
}
