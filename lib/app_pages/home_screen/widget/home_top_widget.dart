import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../app_config/app_constants.dart';
import '../../../app_themes/app_colors.dart';

class HomeTopWidget extends StatelessWidget {
  final String location;
  final double balance;

  const HomeTopWidget({
    super.key,
    required this.location,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    double textScaleFactor = 1.1;

    return Positioned(
      top: 10,
      left: 15,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pushReplacementNamed(context, "profile");
            },
            child: CachedNetworkImage(
              width: 50,
              height: 50,
              imageUrl: "selfieUrl",
              errorWidget: (context, url, error) => Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  image: const DecorationImage(
                    image: AssetImage(
                      Constants.defaultUser,
                    ),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: Colors.white,
                    width: 1.5,
                  ),
                ),
              ),
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: Colors.white,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 5),
          Container(
            width: 260,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: const Color(0xffF5F5F5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xffD9D9D9),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 10),
                    const Icon(Icons.location_on_outlined),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        location,
                        style: TextStyle(
                          fontSize: 12 * textScaleFactor,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, "wallet_summary");
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 40,
                        width: 2,
                        color: const Color(0xffDEDEDE),
                      ),
                      const SizedBox(width: 10),
                      Image.asset(
                        "assets/img/wallet.png",
                        height: 25,
                        width: 25,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "\u{20B9} ${balance.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 12 * textScaleFactor,
                          fontWeight: FontWeight.bold,
                          color: getColor(balance),
                        ),
                      ),
                      const SizedBox(width: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getColor(double value) {
    if (value < 350) {
      return Colors.redAccent;
    } else {
      return AppColors.primary;
    }
  }
}