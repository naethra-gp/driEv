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
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return SizedBox(
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
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
          ),
          Positioned(
            top: height / 7.5 - 100,
            child: Column(
              children: <Widget>[
                SizedBox(
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
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      right: 50, left: 50, top: 25, bottom: 20),
                  child: Image.asset("assets/img/question_mark.png",
                      height: 60, width: 60),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Need Help?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xff2c2c2c),
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 30),
                Column(
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
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  clickToWhatsapp() async {
    var contact = "+919439099990";
    var androidUrl = "whatsapp://send?phone=$contact&text=Hi, I need some help";
    var iosUrl =
        "https://wa.me/$contact?text=${Uri.parse('Hi, I need some help')}";
    try {
      if (Platform.isIOS) {
        await launchUrl(Uri.parse(iosUrl));
      } else {
        await launchUrl(Uri.parse(androidUrl));
      }
    } on Exception {
      AlertServices alertServices = AlertServices();
      alertServices.errorToast("WhatsApp is not installed.");
    }
  }

  clickToCall() async {
    final Uri smsLaunchUri = Uri(scheme: 'tel', path: "+919439099990");
    await launchUrl(smsLaunchUri);
  }

  clickToMail() async {
    final Uri smsLaunchUri = Uri(scheme: 'mailto', path: "info@driev.bike");
    await launchUrl(smsLaunchUri);
  }
}
