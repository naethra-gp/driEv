import 'package:driev/app_storages/secure_storage.dart';
import 'package:driev/app_utils/app_loading/alert_services.dart';
import 'package:flutter/material.dart';

import '../../../app_services/wallet_services.dart';
import '../../../app_themes/app_colors.dart';

class TransactionSuccess extends StatefulWidget {
  const TransactionSuccess({super.key});

  @override
  State<TransactionSuccess> createState() => _TransactionSuccessState();
}

class _TransactionSuccessState extends State<TransactionSuccess> {
  AlertServices alertServices = AlertServices();
  WalletServices walletServices = WalletServices();
  SecureStorage secureStorage = SecureStorage();
  String walletBalance = "0";

  @override
  void initState() {
    getWalletBalance();
    super.initState();
  }
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: SizedBox(
          height: size.height,
          width: size.width,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Image.asset(
                    "assets/img/success_logo.png",
                    height: 150,
                    width: 150,
                  ),
                ),
                const SizedBox(height: 25),
                const Text(
                  "Hooray!",
                  style: TextStyle(
                    fontSize: 35,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Wallet recharge successful!",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 25),
                const Text(
                  "Wallet Balance",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                // const SizedBox(height: 10),
                Text(
                  "\u{20B9} $walletBalance",
                  style: const TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "wallet_summary");
                      },
                      style: ElevatedButton.styleFrom(
                        textStyle: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                        foregroundColor: Colors.white,
                        backgroundColor: AppColors.primary,
                        side: const BorderSide(
                            color: AppColors.primary, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        "Go to Wallet",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
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

  getWalletBalance() async {
    alertServices.showLoading();
    String mobile = secureStorage.get("mobile");
    walletServices.getWalletBalance(mobile).then((dynamic response) {
      alertServices.hideLoading();
      if (response != null) {
        // debugPrint("Balance --> ${response][0]['balance']}");
        setState(() {
          walletBalance = [response][0]['balance'].toString();
        });
      }
    });
  }
}
