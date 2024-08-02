import 'package:flutter/material.dart';

import '../../../app_themes/app_colors.dart';

class WalletBalanceWidget extends StatelessWidget {
  final String balance;
  const WalletBalanceWidget({super.key, required this.balance});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: AppColors.customGrey,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: <Widget>[
            Image.asset(
              "assets/img/savemoney.png",
              height: 50,
              width: 50,
            ),
            const SizedBox(width: 25),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                const Text(
                  "Current Wallet Balance",
                  style: TextStyle(
                    fontFamily: "Roboto",
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    // "₹ 1223,452.00",
                    "₹ $balance",
                    style: const TextStyle(
                      fontSize: 46,
                      fontFamily: "Roboto",
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
