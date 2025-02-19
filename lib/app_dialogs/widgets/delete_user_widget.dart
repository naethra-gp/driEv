import 'package:flutter/material.dart';

class DeleteUserWidget extends StatelessWidget {
  final String message;
  final String? status;
  const DeleteUserWidget({
    super.key,
    required this.message,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    return SizedBox(
      width: double.infinity,
      height: mediaQueryData.size.height / 2.5,
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
                  status == "SUCCESS"
                      ? "assets/img/kyc_hold_logo.png"
                      : "assets/img/block_user_logo.png",
                  height: 70,
                  width: 70,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * .02),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Text(
                    message.toString(),
                    overflow: TextOverflow.clip,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (status.toString().toLowerCase() == 'failure') ...[
                  SizedBox(height: MediaQuery.of(context).size.height * .03),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "home");
                    },
                    child: const Text(
                      "Okay",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        // decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * .02),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
