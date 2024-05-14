import 'package:driev/app_themes/app_colors.dart';
import 'package:driev/app_utils/app_widgets/app_button.dart';
import 'package:flutter/material.dart';

import '../../../app_config/app_constants.dart';

class SuccessScreen extends StatefulWidget {
  const SuccessScreen({super.key});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
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
                    Constants.excelogo,
                    height: 135,
                    width: 135,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Hooray!",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
              // style: CustomTheme.headingStyle3,
            ),
            const SizedBox(height: 16),
            const Text(
              Constants.verifySuc,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.normal,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 100),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: AppButtonWidget(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, "choose_your_campus", (route) => false);
                },
                title: "Choose Your Campus",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
