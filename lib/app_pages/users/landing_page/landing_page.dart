import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../app_utils/app_widgets/app_button.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  void initState() {
    getPermissions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // SizedBox(height: MediaQuery.sizeOf(context).height / 10),
                const SizedBox(height: 124),
                Center(
                  child: Image.asset(
                    "assets/app/get_started.png",
                    height: 277,
                    width: 370,
                    // height: MediaQuery.sizeOf(context).height / 3,
                    // width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Let's get you road-ready!",
                  style: TextStyle(
                    // fontFamily: ,
                    fontFamily: "Roboto-Regular",
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Get set to zip through the city, uncover hidden hotspots, and transform every journey into an epic adventure with our\neco-friendly rides. Let's hit the road!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: "Roboto-Regular",
                    color: Color(0xff6F6F6F),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 30),
                AppButtonWidget(
                  title: "Sign In / Sign Up",
                  onPressed: () async {
                    Navigator.pushNamed(context, "login");
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  getPermissions() async {
    await [
      Permission.location,
      Permission.sms,
      Permission.camera,
      Permission.photos,
      Permission.mediaLibrary,
      Permission.notification,
    ].request();
  }
}
