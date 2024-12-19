import 'dart:math';
import 'package:driev/app_pages/wallet_screens/widgets/wallet_list_widget.dart';
import 'package:driev/app_services/wallet_services.dart';
import 'package:driev/app_storages/secure_storage.dart';
import 'package:driev/app_utils/app_loading/alert_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paytm_allinonesdk/paytm_allinonesdk.dart';
import '../../app_config/app_constants.dart';
import '../../app_themes/app_colors.dart';
import '../../app_utils/app_widgets/app_bar_widget.dart';
import 'widgets/wallet_balance_widget.dart';

class WalletSummary extends StatefulWidget {
  const WalletSummary({super.key});

  @override
  State<WalletSummary> createState() => _WalletSummaryState();
}

class _WalletSummaryState extends State<WalletSummary> {
  AlertServices alertServices = AlertServices();
  WalletServices walletServices = WalletServices();
  SecureStorage secureStorage = SecureStorage();
  final GlobalKey secondComponentKey = GlobalKey();

  List walletSummaryDetails = [];
  String walletBalance = "";
  String result = "";

  @override
  void initState() {
    super.initState();
    getBalance();
    getWalletSummary();
  }

  getBalance() {
    alertServices.showLoading();
    String mobile = secureStorage.get("mobile");
    walletServices.getWalletBalance(mobile).then((response) {
      alertServices.hideLoading();
      List result = [response];
      print("response $response");
      if (response != null) {
        setState(() {
          walletBalance = result[0]['balance'].toStringAsFixed(2);
        });
      }
      print("walletBalance $walletBalance");
    });
  }

  void getWalletSummary() async {
    alertServices.showLoading();
    String mobile = secureStorage.get("mobile") ?? "";
    walletServices.getWalletTransaction(mobile).then((response) {
      alertServices.hideLoading();
      setState(() {
        walletSummaryDetails = List<Map<String, dynamic>>.from(response);
      });
    }).catchError((error) {
      alertServices.hideLoading();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        Navigator.pushReplacementNamed(context, "home");
      },
      child: Scaffold(
        appBar: const AppBarWidget(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            WalletBalanceWidget(balance: walletBalance),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ButtonTheme(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "add_more_fund", arguments: {
                        "stationDetails": [],
                        "rideId": "",
                        "rideID": []
                      });
                    },
                    focusNode: FocusNode(skipTraversal: true),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF3DB54A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    child: const Text(
                      "Add More Fund",
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: "Roboto",
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "withdraw_amount");
                      },
                      focusNode: FocusNode(skipTraversal: true),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF3DB54A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      child: const Text(
                        "Withdraw Fund",
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: "Roboto",
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text(
                          "* Charges Apply",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.black,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Image.asset(
                          "assets/img/vector.png",
                          width: 20,
                          height: 20,
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 25),
            walletTransaction(),
          ],
        ),
      ),
    );
  }

  Widget walletTransaction() {
    return Expanded(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(25, 15, 25, 30),
        decoration: const BoxDecoration(
          color: AppColors.walletColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              "Wallet History",
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            // const SizedBox(height: 15),
            if (walletSummaryDetails.isNotEmpty) ...[
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(0),
                  itemCount: min(4, walletSummaryDetails.length),
                  itemBuilder: (context, index) {
                    final td = walletSummaryDetails[index];
                    return WalletListWidget(
                      title: td['description'] ?? "",
                      subTitle: td['transactionTime'] ?? "",
                      amount: td['transactionAmount'].toStringAsFixed(2),
                      transactionType: td['transactionType'],
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const Divider();
                  },
                ),
              ),
              if (walletSummaryDetails.length > 4)
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "all_transaction",
                        arguments: walletSummaryDetails);
                  },
                  child: const Text(
                    "See All Transactions",
                    style: const TextStyle(
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                      color: AppColors.transacColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ] else ...[
              const Expanded(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 50),
                    child: Text(
                      "Take a ride and your transactions will appear here.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 14,
                        fontFamily: "Roboto",
                      ),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 5),
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                height: 42,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "home");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    side: const BorderSide(color: Colors.green),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    "Proceed to Booking",
                    style: TextStyle(
                        fontSize: 14,
                        color: AppColors.white,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
            // CustomTheme.defaultHeight10
          ],
        ),
      ),
    );
  }

  /// PAYMENT INTEGRATIONS
  paytm(String amount) {
    WalletServices walletServices = WalletServices();
    alertServices.showLoading();
    String mobile = secureStorage.get("mobile") ?? "";
    var params = {
      "amount": amount.toString(),
      "contact": mobile.toString(),
      "staging": Constants.isStagingMode,
    };
    walletServices.initiateTransaction(params).then((dynamic res) {
      print("response --> $res");
      List token = [res];

      String mid = token[0]['mid'].toString();
      String tToken = token[0]['txnToken'].toString();
      String amt = amount.toString();
      String oId = token[0]['orderId'].toString();
      String cbUrl = token[0]['callbackUrl'].toString();
      bool staging = Constants.isStagingMode;
      bool rai = true;
      debugPrint("-------------- PAYTM Payment ---------------------");
      debugPrint("mid: $mid");
      debugPrint("orderID: $oId");
      debugPrint("txtToken: $tToken");
      debugPrint("amount: $amt");
      debugPrint("callbackurl: $cbUrl");
      debugPrint("isStaging: $staging");
      debugPrint("-------------- // PAYTM Payment ---------------------");
      alertServices.hideLoading();
      var response = AllInOneSdk.startTransaction(
          mid, oId, amt, tToken, cbUrl, staging, rai);
      response.then((value) {
        setState(() {
          result = value.toString();
        });
        List res = [value];
        if (res[0]['STATUS'].toString() == "TXN_SUCCESS") {
          debugPrint("Transaction Success");
          Navigator.pushReplacementNamed(context, "transaction_success");
        }
      }).catchError((onError) {
        if (onError is PlatformException) {
          setState(() {
            result = "${onError.message!} \n  ${onError.details}";
          });
        } else {
          setState(() {
            result = onError.toString();
          });
        }
        List response = [onError.details];
        if (response[0]['STATUS'].toString() == "TXN_FAILURE") {
          debugPrint("Transaction Failure");
          Navigator.pushReplacementNamed(context, "transaction_failure");
        }
      });
    });
  }
}
