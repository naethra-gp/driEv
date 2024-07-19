import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

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
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white, // Set the status bar color here
      statusBarIconBrightness:
          Brightness.dark, // For Android to set the icons color
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // const SizedBox(height: 75),
                Center(
                  child: Image.asset(
                    "assets/app/get_started.png",
                    height: 277,
                    width: 370,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Let's get you road-ready!",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Get set to zip through the city, uncover hidden hotspots, and transform every journey into an epic adventure with our eco-friendly rides. Let's hit the road!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xff6F6F6F),
                  ),
                ),
                const SizedBox(height: 30),
                AppButtonWidget(
                  title: "Sign In / Sign Up",
                  onPressed: () {
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
    var status = await [
      Permission.location,
      Permission.locationAlways,
      Permission.sms,
      Permission.camera,
      Permission.photos,
      Permission.mediaLibrary,
      Permission.notification,
    ].request();
    print(status);
  }
}
