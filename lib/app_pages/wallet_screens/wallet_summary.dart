import 'dart:math';

import 'package:driev/app_pages/wallet_screens/widgets/wallet_list_widget.dart';
import 'package:driev/app_services/wallet_services.dart';
import 'package:driev/app_storages/secure_storage.dart';
import 'package:driev/app_utils/app_loading/alert_services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:paytm_allinonesdk/paytm_allinonesdk.dart';
import 'package:shimmer/shimmer.dart';
import '../../app_config/app_constants.dart';
import '../../app_themes/app_colors.dart';
import '../../app_themes/custom_theme.dart';
import '../../app_utils/app_widgets/app_bar_widget.dart';
import 'widgets/place_holder.dart';

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
    getWalletSummary();
  }

  void getWalletSummary() async {
    alertServices.showLoading();
    String mobile = secureStorage.get("mobile") ?? "";
    walletServices.getWalletTransaction(mobile).then((response) {
      setState(() {
        walletSummaryDetails = List<Map<String, dynamic>>.from(response);
        alertServices.hideLoading();
      });
      walletBalance =
          walletSummaryDetails[0]["closingBalance"].toStringAsFixed(2);
      setState(() {});
    }).catchError((error) {
      alertServices.hideLoading();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: AppColors.customGrey,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    "assets/img/savemoney.png",
                    height: 70,
                    width: 70,
                  ),
                  const SizedBox(width: 25),
                  Column(
                    children: <Widget>[
                      const Text(
                        "Current Wallet Balance",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      if (walletSummaryDetails.isNotEmpty) ...[
                        Text(
                          "₹ ${walletSummaryDetails[0]["closingBalance"].toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 45,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ] else ...[
                        Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          enabled: true,
                          child: Container(
                            width: 100,
                            height: 40.0,
                            color: Colors.white,
                            margin: const EdgeInsets.only(bottom: 8.0),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
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
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    "Add More Fund",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ButtonTheme(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "withdraw_amount");
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        "Withdraw Fund",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
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
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
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
                  const SizedBox(height: 15),
                  if (walletSummaryDetails.isEmpty)
                    Expanded(
                      child: Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          enabled: true,
                          child: const SingleChildScrollView(
                            physics: NeverScrollableScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                SizedBox(height: 16.0),
                                ContentPlaceholder(
                                    lineType: ContentLineType.threeLines),
                                Divider(color: AppColors.centerAlign),
                                SizedBox(height: 16.0),
                                ContentPlaceholder(
                                    lineType: ContentLineType.threeLines),
                                Divider(color: AppColors.centerAlign),
                                SizedBox(height: 16.0),
                                ContentPlaceholder(
                                    lineType: ContentLineType.threeLines),
                                Divider(color: AppColors.centerAlign),
                                SizedBox(height: 16.0),
                                ContentPlaceholder(
                                    lineType: ContentLineType.threeLines),
                                Divider(color: AppColors.centerAlign),
                                SizedBox(height: 16.0),
                              ],
                            ),
                          )),
                    ),
                  if (walletSummaryDetails.isNotEmpty)
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(0),
                        itemCount: min(4, walletSummaryDetails.length),
                        itemBuilder: (context, index) {
                          final td = walletSummaryDetails[index];
                          return WalletListWidget(
                            title: td['description'],
                            subTitle: td['transactionTime'],
                            amount: td['transactionAmount'].toStringAsFixed(2),
                            transactionType: td['transactionType'],
                          );
                        },
                        separatorBuilder: (context, index) {
                          return const Divider();
                        },
                      ),
                    ),
                  Align(
                    alignment: Alignment.center,
                    child: RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            text: "See All Transactions",
                            style: const TextStyle(
                              fontSize: 12,
                              decoration: TextDecoration.underline,
                              color: AppColors.transacColor,
                              fontWeight: FontWeight.w500,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.pushNamed(context, "all_transaction",
                                    arguments: walletSummaryDetails);
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
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
                  CustomTheme.defaultHeight10
                ],
              ),
            ),
          ),
        ],
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

class WalletSummaryList extends StatelessWidget {
  final String title;
  final String subTitle;
  final String amount;
  final String transactionType;

  const WalletSummaryList({
    super.key,
    required this.title,
    required this.subTitle,
    required this.amount,
    required this.transactionType,
  });

  @override
  Widget build(BuildContext context) {
    String symbol = transactionType == "Credit" ? "+" : "-";
    Color amountColor = transactionType == "Credit" ? Colors.green : Colors.red;
    String formattedTransactionTime = _formatTransactionTime(subTitle);

    return Row(
      children: <Widget>[
        Expanded(
          flex: 5,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                formattedTransactionTime,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.fontgrey,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            "$symbol ${amount.toString()}",
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14,
              color: amountColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        )
      ],
    );
  }

  String _formatTransactionTime(String timeString) {
    final DateTime time = DateTime.parse(timeString);
    final now = DateTime.now();
    if (time.year == now.year &&
        time.month == now.month &&
        time.day == now.day - 1) {
      return "Yesterday, ${DateFormat('HH:mm a').format(time)}";
    } else {
      return DateFormat('yyyy-MM-dd, HH:mm a').format(time);
    }
  }
}
