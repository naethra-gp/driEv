import 'package:driev/app_utils/app_loading/alert_services.dart';
import 'package:driev/app_utils/app_widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../app_themes/app_colors.dart';

class VoteSuccessPage extends StatefulWidget {
  const VoteSuccessPage({super.key});

  @override
  State<VoteSuccessPage> createState() => _VoteSuccessPageState();
}

class _VoteSuccessPageState extends State<VoteSuccessPage> {
  AlertServices alertServices = AlertServices();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, "rank_list", (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: double.infinity,
                height: size.height * 0.20,
                child: SizedBox(
                  // height: 400,
                  child: Center(
                    child: Image.asset(
                      "assets/app/hand_tick.png",
                      height: 110,
                      width: 110,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Text(
                  "Thank you for the invite!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 50),
                child: Text(
                    "See you soon on your campus. Stay tuned for more updates.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                      fontSize: 20,
                    )),
              ),
              const SizedBox(height: 50),
              AppButtonWidget(
                title: "Share With Your Friends",
                onPressed: () async {
                  final result = await Share.share('https://driev.bike');

                  if (result.status == ShareResultStatus.success) {}
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
