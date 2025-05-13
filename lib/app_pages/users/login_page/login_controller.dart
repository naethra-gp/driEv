import 'package:driev/app_config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

import '../../../app_services/index.dart';
import '../../../app_utils/app_loading/alert_services.dart';

mixin LoginController {
  // Controllers and Services
  final TextEditingController mobileCtrl = TextEditingController();
  final OtpServices otpServices = OtpServices();
  final AlertServices alertServices = AlertServices();
  final formKey = GlobalKey<FormState>();
  final otpFocus = FocusNode();

  // State Variables
  bool isStaging = Constants.isStaging;
  bool isLoading = false;
  bool isMobileValid = false;

  // UI Constants
  final double smallDeviceHeight = 600;
  final double largeDeviceHeight = 1024;
  final double logoSize = 96;
  final double defaultPadding = 25;
  final double defaultSpacing = 16;
  final double bottomSpacing = 50;
  final double switchSplashRadius = 50.0;
  final double fontSize = 14;
  final double titleFontSize = 20;
  final double subtitleFontSize = 16;

  // Colors
  final Color backgroundColor = const Color(0XFFF6F6F6);
  final Color hintColor = const Color(0xffDEDEDE);
  final Color borderColor = const Color(0xFFDEDEDE);
  final Color errorColor = Colors.redAccent;
  final Color textColor = Colors.black;
  final Color subtitleColor = const Color(0XFF6F6F6F);

  void initStateController(String? mobileNumber) {
    printPageTitle(AppTitles.loginScreen);
    mobileCtrl.addListener(_validateMobile);
    if (mobileNumber != null) {
      mobileCtrl.text = mobileNumber;
    } else {
      Future<void>.delayed(
          const Duration(milliseconds: 300), () => tryPasteCurrentPhone());
    }
  }

  void dispose() {
    mobileCtrl.removeListener(_validateMobile);
    mobileCtrl.dispose();
    otpFocus.dispose();
  }

  void _validateMobile() {
    isMobileValid = mobileCtrl.text.length == 10;
  }

  // UI Helper Methods
  double getContainerHeight(double height) {
    if (height < smallDeviceHeight) {
      return height / 1.2;
    } else if (height >= smallDeviceHeight && height < largeDeviceHeight) {
      return height / 1.35;
    } else {
      return height / 1.1;
    }
  }

  double getPositionedHeight(double height) {
    if (height < smallDeviceHeight) {
      return height / 0.925;
    } else if (height >= smallDeviceHeight && height < largeDeviceHeight) {
      return height / 1.045;
    } else {
      return height / 0.95;
    }
  }

  double getTopPadding(double height) => height / 12.5;
  double getLogoSpacing(double height) => height / 40;

  // Business Logic Methods
  void toggleApiMode(bool value, StateSetter setState) {
    setState(() {
      isStaging = value;
      Constants.isStaging = value;
    });
    if (!value) {
      EndPoints.baseApi = "https://iot.driev.bike/driev/api/app";
      EndPoints.baseApi1 = "https://iot.driev.bike/driev/api/app";
    } else {
      EndPoints.baseApi = "https://community-test.driev.bike/driev/api/app";
      EndPoints.baseApi1 = "https://community-test.driev.bike/driev/api";
    }
  }

  Future<void> tryPasteCurrentPhone() async {
    try {
      final autoFill = SmsAutoFill();
      final phone = await autoFill.hint;
      if (phone == null) return;
      if (phone.toString().startsWith('+91')) {
        mobileCtrl.text = phone.toString().replaceFirst('+91', '');
      }
    } on PlatformException catch (e, stack) {
      appLog(e, stack, reason: AppTitles.loginScreen, fatal: true);
    }
  }

  Future<void> submitLogin(BuildContext context, StateSetter setState) async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      setState(() => isLoading = true);
      try {
        final response = await otpServices.generateOtp(mobileCtrl.text);
        if (response['type'] == "success") {
          alertServices.successToast("OTP sent to +91${mobileCtrl.text}");
          Navigator.pushNamed(context, "verify_otp",
              arguments: mobileCtrl.text);
        } else {
          alertServices.errorToast(response['message'].toString());
        }
      } catch (e, stack) {
        alertServices.errorToast(AppErrors.failedToSendOTP);
        appLog(e, stack, reason: AppTitles.loginScreen, fatal: false);
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> openBrowser() async {
    final Uri url = Uri.parse('https://driev.bike/termsandconditions');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      alertServices.errorToast("Could not launch $url");
    }
  }

  KeyboardActionsConfig buildKeyboardActionsConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.IOS,
      actions: [
        KeyboardActionsItem(focusNode: otpFocus, toolbarButtons: [
          (node) {
            return GestureDetector(
              onTap: () => node.unfocus(),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                child: const Text(
                  "Done",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            );
          }
        ]),
      ],
    );
  }
}
