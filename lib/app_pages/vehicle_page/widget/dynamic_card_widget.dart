import 'package:flutter/material.dart';

import '../../../app_themes/app_colors.dart';
import 'dynamic_image_widget.dart';

class DynamicCardWidget extends StatelessWidget {
  final GestureTapCallback onTap;
  final String imageUrl;
  final String plan;
  final String vehicleId;
  final String distanceRange;

  const DynamicCardWidget({
    super.key,
    required this.onTap,
    required this.imageUrl,
    required this.plan,
    required this.vehicleId,
    required this.distanceRange,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Card(
          elevation: 0,
          surfaceTintColor: const Color(0xffF5F5F5),
          color: const Color(0xffF5F5F5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          clipBehavior: Clip.none,
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                DynamicImageWidget(imageUrl: imageUrl),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.center,
                  child: RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: 'dri',
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 12,
                          ),
                        ),
                        const TextSpan(
                          text: 'EV ',
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            fontSize: 12,
                          ),
                        ),
                        TextSpan(
                          text: '$plan $vehicleId',
                          style: const TextStyle(
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Estimated Range",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xff626262),
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            distanceRange.toString() == "null"
                                ? "-"
                                : "$distanceRange KM",
                            style: const TextStyle(
                              fontSize: 10,
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // const SizedBox(height: 5),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
