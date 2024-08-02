import 'package:flutter/material.dart';

import '../../app_utils/app_widgets/app_button.dart';

class KycBlockWidget extends StatelessWidget {
  const KycBlockWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final MediaQueryData media = MediaQuery.of(context);
    return SizedBox(
      width: double.infinity,
      height: media.size.height / 2.2,
      child: Padding(
        padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 25),
                Image.asset("assets/img/kyc_reject.png", height: 75, width: 75),
                const SizedBox(height: 10),
                const Text(
                  "KYC Rejected.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: "Roboto",
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: media.size.height * .015),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    "Looks like the documents you uploaded has some issue.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.red,
                      fontFamily: "Roboto",
                      fontSize: 15,
                    ),
                  ),
                ),
                SizedBox(height: media.size.height * .015),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    "Please visit your profile page to try recapturing a clearer image",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: "Roboto",
                      fontSize: 15,
                    ),
                  ),
                ),
                SizedBox(height: media.size.height * .03),
                SizedBox(
                  height: 45,
                  width: media.size.width - 10,
                  child: AppButtonWidget(
                    title: "Go to Profile",
                    onPressed: () {
                      Navigator.pushNamed(context, "profile");
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
