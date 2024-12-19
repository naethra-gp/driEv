import 'package:driev/app_config/app_end_points.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

import '../../../app_config/app_constants.dart';
import '../../../app_themes/app_colors.dart';
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
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    "Get set to zip through the city, uncover hidden hotspots, and transform every journey into an epic adventure with our eco-friendly rides. Let's hit the road!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 16,
                      color: Color(0xff6F6F6F),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: AppButtonWidget(
                    title: "Sign In / Sign Up",
                    onPressed: () {
                      Navigator.pushNamed(context, "login");
                    },
                  ),
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
  }
}
