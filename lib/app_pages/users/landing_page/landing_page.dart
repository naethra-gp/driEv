import 'package:driev/app_config/app_config.dart';
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
  // Constants
  static const double _imageHeight = 277;
  static const double _imageWidth = 370;
  static const double _titleFontSize = 20;
  static const double _descriptionFontSize = 16;
  static const double _horizontalPadding = 30;
  static const double _verticalSpacing = 16;
  static const double _smallSpacing = 10;
  static const double _largeSpacing = 30;

  @override
  void initState() {
    super.initState();
    printPageTitle(AppTitles.landingScreen);
    _initializePage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildImageSection(),
                const SizedBox(height: _smallSpacing),
                _buildTitleText(),
                const SizedBox(height: _verticalSpacing),
                _buildDescriptionText(),
                const SizedBox(height: _largeSpacing),
                _buildActionButton(context),
                const SizedBox(height: _verticalSpacing),
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
      Permission.photos,
    ].request();
  }

  // Builds the image section
  Widget _buildImageSection() {
    return Center(
      child: Image.asset(
        AppImages.getStarted,
        height: _imageHeight,
        width: _imageWidth,
        fit: BoxFit.contain,
      ),
    );
  }

  // Builds the title text
  Widget _buildTitleText() {
    return const Text(
      AppStrings.landingTitle,
      style: TextStyle(
        fontSize: _titleFontSize,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Builds the description text
  Widget _buildDescriptionText() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: _smallSpacing),
      child: Text(
        AppStrings.landingDescription,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: "Roboto",
          fontSize: _descriptionFontSize,
          color: Color(0xff6F6F6F),
        ),
      ),
    );
  }

  // Builds the action button
  Widget _buildActionButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _smallSpacing),
      child: AppButtonWidget(
        title: AppStrings.signInSignUp,
        onPressed: () => Navigator.pushNamed(context, "login"),
      ),
    );
  }
}
