import 'package:driev/app_config/app_config.dart';
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
                  const SizedBox(height: 50),
                  Image.asset(AppImages.blockUserLogo),
                  const SizedBox(height: 25),
                  vehicleAlertMessage(context, message),
                  const SizedBox(height: 25),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget vehicleAlertMessage(context, String message) {
    double width = MediaQuery.of(context).size.width * 0.9;
    return Container(
      padding: const EdgeInsets.all(2.0),
      width: width,
      child: Column(
        children: <Widget>[
          Text(
            message,
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
