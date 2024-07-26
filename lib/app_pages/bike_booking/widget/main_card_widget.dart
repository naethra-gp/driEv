import 'package:flutter/material.dart';

import '../../../app_config/app_constants.dart';
import '../../../app_themes/app_colors.dart';

class MainCardWidget extends StatelessWidget {
  final List fd;
  final List sd;
  const MainCardWidget({
    super.key,
    required this.fd,
    required this.sd,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IntrinsicHeight(
          child: Card(
            surfaceTintColor: Colors.transparent,
            color: const Color(0xffF5F5F5),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'dri',
                                      style: heading(Colors.black),
                                    ),
                                    TextSpan(
                                      text: 'EV ',
                                      style: heading(AppColors.primary),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Text(
                              '${fd[0]['planType']} ${fd[0]['vehicleId']}',
                              style: heading(Colors.black),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Image.asset(
                              "assets/img/slider_icon.png",
                              height: 18,
                              width: 13,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              "${sd[0]['campus']} (${sd[0]['distance'].toString()})",
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Estimated Range",
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xff626262),
                          ),
                        ),
                        Text(
                          "${fd[0]['estimatedRange'] ?? "0"} km",
                          style: const TextStyle(
                            fontSize: 12,
                            // fontFamily: "Poppins",
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 5),
                        fd[0]['imageUrl'] != null
                            ? Image.network(fd[0]['imageUrl'].toString(),
                                width: 200, height: 130, fit: BoxFit.contain)
                            : Image.asset("assets/img/bike2.png",
                                fit: BoxFit.cover),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: <TextSpan>[
              const TextSpan(
                text: "* ",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 10,
                ),
              ),
              TextSpan(
                text: Constants.bikeBookingNotes,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xff7E7E7E),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  TextStyle heading(Color color) {
    return TextStyle(
      fontFamily: "Poppins-Bold",
      fontWeight: FontWeight.normal,
      color: color,
      fontSize: 16,
    );
  }
}
