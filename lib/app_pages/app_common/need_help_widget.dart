import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app_themes/app_colors.dart';

class NeedHelpWidget extends StatelessWidget {
  const NeedHelpWidget({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return SizedBox(
      height: height / 2,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            top: height / 5.5 - 100,
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
            top: height / 6.6 - 100,
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
                ),
                const Text(
                  "Need Help?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xff2c2c2c),
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    children: [
                      SizedBox(
                        width: 200,
                        height: 40,
                        child: ElevatedButton(
                            onPressed: () async {
                              var contact = "+919439099990";
                              var androidUrl =
                                  "whatsapp://send?phone=$contact&text=Hi, I need some help";
                              var iosUrl =
                                  "https://wa.me/$contact?text=${Uri.parse('Hi, I need some help')}";
                              try {
                                if (Platform.isIOS) {
                                  await launchUrl(Uri.parse(iosUrl));
                                } else {
                                  await launchUrl(Uri.parse(androidUrl));
                                }
                              } on Exception {
                                EasyLoading.showError(
                                    'WhatsApp is not installed.');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              textStyle: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                              elevation: 0,
                              foregroundColor: Colors.black,
                              backgroundColor: Colors.white,
                              side: const BorderSide(
                                  color: Color(0xffC7C7C7), width: 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  LineAwesome.whatsapp,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "Whatsapp Us",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    color: Color(0xff626262),
                                  ),
                                ),
                              ],
                            )),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 200,
                        height: 40,
                        child: ElevatedButton(
                            onPressed: () async {
                              final Uri smsLaunchUri =
                                  Uri(scheme: 'tel', path: "+919439099990");
                              await launchUrl(smsLaunchUri);
                            },
                            style: ElevatedButton.styleFrom(
                              textStyle: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                              elevation: 0,
                              foregroundColor: Colors.black,
                              backgroundColor: Colors.white,
                              side: const BorderSide(
                                  color: Color(0xffC7C7C7), width: 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.phone_callback_outlined,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "Call Us",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    color: Color(0xff626262),
                                  ),
                                ),
                              ],
                            )),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 200,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () async {
                            final Uri smsLaunchUri =
                                Uri(scheme: 'mailto', path: "info@driev.bike");
                            await launchUrl(smsLaunchUri);
                          },
                          style: ElevatedButton.styleFrom(
                            textStyle: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                            elevation: 0,
                            foregroundColor: Colors.black,
                            backgroundColor: Colors.white,
                            side: const BorderSide(
                                color: Color(0xffC7C7C7), width: 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.mark_email_read_outlined,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Mail Us",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: Color(0xff626262),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
