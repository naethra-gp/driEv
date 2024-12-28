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
    super.initState();
    _initializePage();
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
                _buildImageSection(),
                const SizedBox(height: 10),
                _buildTitleText(),
                const SizedBox(height: 16),
                _buildDescriptionText(),
                const SizedBox(height: 30),
                _buildActionButton(context),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Initializes necessary permissions and system UI settings
  void _initializePage() {
    _requestPermissions();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  // Requests app permissions
  Future<void> _requestPermissions() async {
    await [
      Permission.camera,
      Permission.location,
      Permission.locationAlways,
      Permission.sms,
      Permission.photos,
      Permission.mediaLibrary,
      Permission.notification,
    ].request();
  }

  // Builds the image section
  Widget _buildImageSection() {
    return Center(
      child: Image.asset(
        "assets/app/get_started.png",
        height: 277,
        width: 370,
        fit: BoxFit.contain,
      ),
    );
  }

  // Builds the title text
  Widget _buildTitleText() {
    return const Text(
      "Let's get you road-ready!",
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Builds the description text
  Widget _buildDescriptionText() {
    return const Padding(
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
    );
  }

  // Builds the action button
  Widget _buildActionButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: AppButtonWidget(
        title: "Sign In / Sign Up",
        onPressed: () {
          Navigator.pushNamed(context, "login");
        },
      ),
    );
  }
}
