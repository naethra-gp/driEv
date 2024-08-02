import 'package:flutter/material.dart';

class KycHoldWidget extends StatelessWidget {
  const KycHoldWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    return SizedBox(
      width: double.infinity,
      height: mediaQueryData.size.height / 3,
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
                const SizedBox(height: 50),
                Image.asset(
                  "assets/img/kyc_hold_logo.png",
                  height: 75,
                  width: 75,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * .02),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 75),
                  child: Text(
                    "Hold on! Your KYC verification is in process",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
