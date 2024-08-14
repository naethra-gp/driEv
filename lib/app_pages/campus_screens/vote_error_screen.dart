import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../app_themes/app_colors.dart';
import '../../app_utils/app_loading/alert_services.dart';
import '../../app_utils/app_widgets/app_button.dart';

class VoteErrorScreen extends StatefulWidget {
  final dynamic params;

  const VoteErrorScreen({super.key, this.params});

  @override
  State<VoteErrorScreen> createState() => _VoteErrorScreenState();
}

class _VoteErrorScreenState extends State<VoteErrorScreen> {
  AlertServices alertServices = AlertServices();
  String message = "It seems you've already voted";

  @override
  void initState() {
    super.initState();
    setState(() {
      message = widget.params['message'].toString();
    });
    Future.delayed(const Duration(seconds: 5), () {
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
                  child: Center(
                    child: Image.asset(
                      "assets/img/error_logo.png",
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
                  "Already voted!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Text(message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
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
