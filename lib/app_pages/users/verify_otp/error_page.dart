import 'package:flutter/material.dart';

import '../../../app_themes/app_colors.dart';
import '../../../app_utils/app_widgets/app_button.dart';

class OtpErrorPage extends StatefulWidget {
  const OtpErrorPage({super.key});

  @override
  State<OtpErrorPage> createState() => _OtpErrorPageState();
}

class _OtpErrorPageState extends State<OtpErrorPage> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: double.infinity,
              height: size.height * 0.25,
              child: SizedBox(
                child: Center(
                  child: Image.asset(
                    "assets/app/error_otp.png",
                    height: 150,
                    width: 150,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const Text(
              "Uh-oh!",
              style: TextStyle(
                fontSize: 30,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "It's a bummer with your mobile number verification. Let's try that again!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
                color: AppColors.blackLight,
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: AppButtonWidget(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, "login_page", (route) => false);
                },
                title: "Retry Verification",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
