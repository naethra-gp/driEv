import 'package:flutter/material.dart';

class VehicleAlert extends StatelessWidget {
  final String message;
  const VehicleAlert({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    return SizedBox(
      height: height / 1.8,
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.only(bottom: mediaQueryData.viewInsets.bottom),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Positioned(
              top: height / 6 - 70,
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
              top: height / 7.5 - 70,
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
                  const SizedBox(height: 25),
                  const SizedBox(height: 25),
                  Image.asset("assets/img/block_user_logo.png"),
                  const SizedBox(height: 25),
                  message1(context, message),
                  const SizedBox(height: 25),

                ],
              ),
            )
          ],
        ),
      ),
    );
    // final MediaQueryData mediaQueryData = MediaQuery.of(context);
    // return SizedBox(
    //   width: double.infinity,
    //   // height: mediaQueryData.size.height / 2.2,
    //   child: Padding(
    //     padding: EdgeInsets.only(bottom: mediaQueryData.viewInsets.bottom),
    //     child: SingleChildScrollView(
    //       child: Padding(
    //         padding: const EdgeInsets.fromLTRB(10, 50, 10, 50),
    //         child: Column(
    //           mainAxisSize: MainAxisSize.max,
    //           mainAxisAlignment: MainAxisAlignment.center,
    //           crossAxisAlignment: CrossAxisAlignment.center,
    //           children: <Widget>[
    //             const SizedBox(height: 25),
    //             Image.asset("assets/img/block_user_logo.png"),
    //             const SizedBox(height: 25),

    //             Padding(
    //               padding: const EdgeInsets.symmetric(horizontal: 15),
    //               child: Text(
    //                 message,
    //                 textAlign: TextAlign.center,
    //                 style: const TextStyle(
    //                   fontSize: 18,
    //                   height: 1.5,
    //                   fontWeight: FontWeight.bold,
    //                 ),
    //                 // style: CustomTheme.termStyle1,
    //               ),
    //             ),
    //           ],
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }

  Widget message1(context, mes) {
    double cWidth = MediaQuery.of(context).size.width * 0.9;
    return Container(
      padding: const EdgeInsets.all(2.0),
      width: cWidth,
      child: Column(
        children: <Widget>[
          Text(
            mes,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              height: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
