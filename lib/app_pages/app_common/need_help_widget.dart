import 'dart:io';

import 'package:driev/app_utils/app_loading/alert_services.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'widget/need_help_button_widget.dart';

class NeedHelpWidget extends StatelessWidget {
  const NeedHelpWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SizedBox(
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          _buildBackgroundContainer(height, width),
          _buildContent(context, height),
        ],
      ),
    );
  }

  /// Builds the background container with rounded corners at the top.
  Widget _buildBackgroundContainer(double height, double width) {
    return Positioned(
      top: height / 6 - 100,
      child: Container(
        height: height,
        width: width,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
      ),
    );
  }

  /// Builds the content (header, buttons) for the "Need Help" widget.
  Widget _buildContent(BuildContext context, double height) {
    return Positioned(
      top: height / 7.5 - 100,
      child: Column(
        children: <Widget>[
          _buildCloseButton(context),
          _buildHeaderImage(),
          const SizedBox(height: 5),
          _buildTitle(),
          const SizedBox(height: 30),
          _buildHelpButtons(),
        ],
      ),
    );
  }

  /// Builds the close button.
  Widget _buildCloseButton(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 50,
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.green,
        ),
        child: IconButton(
          icon: const Icon(Icons.close),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  /// Builds the header image.
  Widget _buildHeaderImage() {
    return Padding(
      padding: const EdgeInsets.only(
        right: 50,
        left: 50,
        top: 25,
        bottom: 20,
      ),
      child: Image.asset(
        "assets/img/question_mark.png",
        height: 60,
        width: 60,
      ),
    );
  }

  /// Builds the title text.
  Widget _buildTitle() {
    return const Text(
      "Need Help?",
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Color(0xff2c2c2c),
        fontSize: 25,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  /// Builds the help buttons (WhatsApp, Call, Mail).
  Widget _buildHelpButtons() {
    return Column(
      children: [
        NeedHelpButtonWidget(
          onPressed: clickToWhatsapp,
          icon: LineAwesome.whatsapp,
          title: "Whatsapp Us",
        ),
        const SizedBox(height: 25),
        NeedHelpButtonWidget(
          onPressed: clickToCall,
          icon: Icons.phone_callback_outlined,
          title: "Call Us",
        ),
        const SizedBox(height: 25),
        NeedHelpButtonWidget(
          onPressed: clickToMail,
          icon: Icons.mark_email_read_outlined,
          title: "Mail Us",
        ),
      ],
    );
  }

  /// Opens WhatsApp for user support.
  Future<void> clickToWhatsapp() async {
    const contact = "+919439099990";
    const androidUrl =
        "whatsapp://send?phone=$contact&text=Hi, I need some help";
    final iosUrl =
        "https://wa.me/$contact?text=${Uri.parse('Hi, I need some help')}";

    try {
      if (Platform.isIOS) {
        await launchUrl(Uri.parse(iosUrl));
      } else {
        await launchUrl(Uri.parse(androidUrl));
      }
    } catch (e) {
      AlertServices().errorToast("WhatsApp is not installed.");
    }
  }

  /// Initiates a phone call for user support.
  Future<void> clickToCall() async {
    final smsLaunchUri = Uri(scheme: 'tel', path: "+919439099990");
    await launchUrl(smsLaunchUri);
  }

  /// Opens the email app for user support.
  Future<void> clickToMail() async {
    final smsLaunchUri = Uri(scheme: 'mailto', path: "info@driev.bike");
    await launchUrl(smsLaunchUri);
  }
}
