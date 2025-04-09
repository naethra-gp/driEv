import 'package:driev/app_themes/app_colors.dart';
import 'package:flutter/material.dart';


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
      width: width - 150,
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
      elevation: 5,
      foregroundColor: Colors.black,
      backgroundColor: Colors.white,
      side: const BorderSide(
        // color: Color(0xffC7C7C7),
        color: AppColors.primary,
        width: 1,
      ),
      padding: const EdgeInsets.all(5.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
      ),
      textStyle: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w500,
        // fontSize: 16,
      ),
    );
  }

  dynamicButton(icon, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 5),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xff626262),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
