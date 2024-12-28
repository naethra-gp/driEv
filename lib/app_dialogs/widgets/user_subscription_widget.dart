import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../app_pages/app_common/widget/need_help_button_widget.dart';

class UserSubscriptionWidget extends StatelessWidget {
  const UserSubscriptionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    return SizedBox(
      width: double.infinity,
      height: mediaQueryData.size.height / 2,
      child: Padding(
        padding: EdgeInsets.only(bottom: mediaQueryData.viewInsets.bottom),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 25),
                Image.asset("assets/img/block_user_logo.png"),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Oops! It seems like you’re not registered with our community. Don’t worry - feel free to reach out to us, and we’ll be happy to assist you further.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      height: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: 150,
                  child: NeedHelpButtonWidget(
                    onPressed: () async {
                      final Uri call =
                          Uri(scheme: 'tel', path: "+919439099990");
                      await launchUrl(call);
                    },
                    title: 'Call Us',
                    icon: Icons.phone_outlined,
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: 150,
                  child: NeedHelpButtonWidget(
                    onPressed: () async {
                      const String url = "https://driev.bike/";
                      if (await canLaunchUrlString(url)) {
                        await launchUrlString(
                          url,
                          mode: LaunchMode.inAppWebView,
                        );
                      } else {
                        throw 'Could not launch $url';
                      }
                    },
                    title: 'Visit Us',
                    icon: Icons.public_outlined,
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
}
