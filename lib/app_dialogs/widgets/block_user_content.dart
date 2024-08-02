import 'package:flutter/material.dart';

class BlockUserContent extends StatelessWidget {
  const BlockUserContent({super.key});

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    return SizedBox(
      width: double.infinity,
      height: mediaQueryData.size.height / 2.2,
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
                const SizedBox(height: 75),
                Image.asset("assets/img/block_user_logo.png"),
                const SizedBox(height: 25),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    "Uh-oh! Looks like we've spotted some irregular activity on your account. Hang tight while we sort it out!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      height: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                    // style: CustomTheme.termStyle1,
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
