import 'package:flutter/material.dart';

class DeleteUserWidget extends StatelessWidget {
  final String message;
  const DeleteUserWidget({super.key, required this.message});

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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 75),
                  child: Text(message.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
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
