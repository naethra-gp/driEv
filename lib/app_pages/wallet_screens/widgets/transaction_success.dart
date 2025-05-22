import 'package:driev/app_storages/secure_storage.dart';
import 'package:driev/app_utils/app_loading/alert_services.dart';
import 'package:driev/app_utils/app_widgets/app_button.dart';
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
    Future.delayed(const Duration(seconds: 5), ()
    {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, "wallet_summary");
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        Navigator.pushReplacementNamed(context, "wallet_summary");
      },
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
                  child: Image.asset("assets/img/success_logo.png",
                      height: 150, width: 150),
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
                    fontSize: 22,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Wallet Balance",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                Text(
                  "\u{20B9} $walletBalance",
                  style: const TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.maxFinite,
                  child: AppButtonWidget(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, "wallet_summary");
                    },
                    title: "Go to Wallet",
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
        setState(() {
          walletBalance = [response][0]['balance'].toString();
        });
      }
    });
  }
}
