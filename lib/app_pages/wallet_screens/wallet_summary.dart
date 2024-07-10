import 'dart:math';

import 'package:driev/app_services/wallet_services.dart';
import 'package:driev/app_storages/secure_storage.dart';
import 'package:driev/app_utils/app_loading/alert_services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:paytm_allinonesdk/paytm_allinonesdk.dart';
import '../../app_config/app_constants.dart';
import '../../app_themes/app_colors.dart';
import '../../app_themes/custom_theme.dart';

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
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Image.asset(Constants.backButton),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: AppColors.customGrey,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    "assets/img/savemoney.png",
                    height: 60,
                    width: 60,
                  ),
                  const SizedBox(width: 25),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
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
                      ]
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ButtonTheme(
                minWidth: 140,
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "add_more_fund", arguments: {
                      "stationDetails": [],
                      "rideId": "",
                      "rideID": []
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    side: const BorderSide(color: Colors.green),
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
                    minWidth: 140,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "withdraw_amount",
                            arguments: walletBalance);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        side: const BorderSide(color: Colors.green),
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
                    children: [
                      const Text(
                        "* Charges Apply",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.black,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w300,
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
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: AppColors.walletColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    "Wallet History",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(5),
                      itemCount: min(
                        4,
                        walletSummaryDetails.length,
                      ),
                      itemBuilder: (context, index) {
                        final transaction = walletSummaryDetails[index];
                        return Column(
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            WalletSummaryList(
                              title: transaction['description'],
                              subTitle: transaction['transactionTime'],
                              amount: transaction['transactionAmount']
                                  .toStringAsFixed(2),
                              transactionType: transaction['transactionType'],
                            ),
                            const SizedBox(height: 10),
                            const Divider(color: AppColors.centerAlign),
                          ],
                        );
                      },
                    ),
                  ),
                  CustomTheme.defaultHeight10,
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
                  CustomTheme.defaultHeight10,
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
      // String mid = "cxAfAZ34251794799551";
      // String tToken = "cc302ad05939411cbf77d4f2010e5d6c1718892040879";
      // String amt = "1.00";
      // String oId = "OD_59";
      // String cbUrl = "https://securegw.paytm.in/theia/paytmCallback?ORDER_ID=OD_59";
      // bool staging = false;
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
        print("---------------------");
        print("result ---> ${res[0]['STATUS']}");
        print("---------------------");

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
        print("---------------------");
        print("error result ---> ${response[0]['STATUS']}");
        print("error result ---> ${response[0]['RESPMSG']}");
        print("---------------------");

        if (response[0]['STATUS'].toString() == "TXN_FAILURE") {
          debugPrint("Transaction Failure");
          Navigator.pushReplacementNamed(context, "transaction_failure");
        }
      });
    });
  }

  // CREDIT API CALL
  // addMoreFunds(GlobalKey key) {
  //   double height = MediaQuery.of(context).size.height;
  //   double width = MediaQuery.of(context).size.width;
  //   final renderBox = key.currentContext?.findRenderObject();
  //   print("renderBox  $renderBox");
  //
  //   return showModalBottomSheet(
  //     context: context,
  //     barrierColor: Colors.black87,
  //     backgroundColor: Colors.transparent,
  //     isDismissible: true,
  //     enableDrag: false,
  //     builder: (context) {
  //       return Wrap(children: <Widget>[
  //         SizedBox(
  //           // height: sheetHeight,
  //           height: height / 2,
  //           // height: SizeConfig.screenHeight * 0.6,
  //           child: Stack(
  //             alignment: Alignment.center,
  //             children: <Widget>[
  //               Positioned(
  //                 top: height / 5.5 - 100,
  //                 child: Container(
  //                   height: height,
  //                   width: width,
  //                   decoration: const BoxDecoration(
  //                     color: Colors.white,
  //                     borderRadius: BorderRadius.vertical(
  //                       top: Radius.circular(20),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //               Positioned(
  //                 top: height / 6.6 - 100,
  //                 child: Column(
  //                   children: <Widget>[
  //                     SizedBox(
  //                       width: 50,
  //                       height: 50,
  //                       child: Container(
  //                         decoration: const BoxDecoration(
  //                           shape: BoxShape.circle,
  //                           color: Colors.green,
  //                         ),
  //                         child: IconButton(
  //                           icon: const Icon(Icons.close),
  //                           color: Colors.white,
  //                           onPressed: () {
  //                             Navigator.pop(context);
  //                           },
  //                         ),
  //                       ),
  //                     ),
  //                     const SizedBox(height: 10),
  //                     SizedBox(
  //                       width: MediaQuery.of(context).size.width - 100,
  //                       child: TextFormField(
  //                         keyboardType: TextInputType.phone,
  //                         textInputAction: TextInputAction.done,
  //                         autofocus: false,
  //                         autovalidateMode: AutovalidateMode.onUserInteraction,
  //                         style: const TextStyle(
  //                             fontSize: 12,
  //                             fontWeight: FontWeight.normal,
  //                             color: Colors.black),
  //                         decoration: InputDecoration(
  //                           prefix: IconButton(
  //                             onPressed: (){},
  //                             icon: const Icon(Icons.currency_rupee),
  //                           ),
  //                           // hintText: hintText ?? title,
  //                           // counterText: counterText ?? '',
  //                           // errorMaxLines: errorMaxLines ?? 2,
  //                           // helperText: helperText,
  //                           // filled: readOnly,
  //                           // fillColor: Colors.grey[200],
  //                           errorStyle: const TextStyle(
  //                             color: Colors.redAccent,
  //                             fontSize: 12,
  //                             fontWeight: FontWeight.normal,
  //                           ),
  //                           // helperStyle: helperStyle,
  //                           hintStyle: const TextStyle(
  //                             fontSize: 12,
  //                             color: Colors.grey,
  //                           ),
  //                           border: OutlineInputBorder(
  //                             borderRadius: BorderRadius.circular(10),
  //                             borderSide:
  //                             const BorderSide(color: Color(0xffD2D2D2)),
  //                           ),
  //                           enabledBorder: OutlineInputBorder(
  //                             borderRadius: BorderRadius.circular(10),
  //                             borderSide:
  //                             const BorderSide(color: Color(0xffD2D2D2)),
  //                           ),
  //                           focusedBorder: OutlineInputBorder(
  //                             borderRadius: BorderRadius.circular(10),
  //                             borderSide:
  //                             const BorderSide(color: AppColors.primary),
  //                           ),
  //                           focusedErrorBorder: OutlineInputBorder(
  //                             borderRadius: BorderRadius.circular(10),
  //                             borderSide:
  //                             const BorderSide(color: Colors.redAccent),
  //                           ),
  //                           disabledBorder: OutlineInputBorder(
  //                             borderRadius: BorderRadius.circular(10),
  //                             borderSide:
  //                             const BorderSide(color: Color(0xffD2D2D2)),
  //                           ),
  //                           errorBorder: OutlineInputBorder(
  //                             borderRadius: BorderRadius.circular(10),
  //                             borderSide:
  //                             const BorderSide(color: Colors.redAccent),
  //                           ),
  //                           contentPadding: const EdgeInsets.only(left: 15),
  //                           isDense: false,
  //                           // prefixIcon: prefixIcon != null
  //                           //     ? Icon(
  //                           //         prefixIcon,
  //                           //         color: iconColor ?? themeColor,
  //                           //         size: 26,
  //                           //       )
  //                           //     : null,
  //                         ),
  //                       ),
  //                     ),
  //                     const SizedBox(height: 20),
  //                     Padding(
  //                       padding: const EdgeInsets.symmetric(horizontal: 0),
  //                       child: SizedBox(
  //                         width: MediaQuery.of(context).size.width - 100,
  //                         height: 45,
  //                         child: ElevatedButton(
  //                           onPressed: () {},
  //                           style: ElevatedButton.styleFrom(
  //                             backgroundColor: Colors.green,
  //                             side: const BorderSide(color: Colors.green),
  //                             shape: RoundedRectangleBorder(
  //                               borderRadius: BorderRadius.circular(25.0),
  //                             ),
  //                           ),
  //                           child: const Text(
  //                             "Proceed",
  //                             style: TextStyle(
  //                               fontSize: 14,
  //                               color: AppColors.white,
  //                               fontWeight: FontWeight.w500,
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                     const SizedBox(height: 10),
  //                   ],
  //                 ),
  //               )
  //             ],
  //           ),
  //         )
  //       ]);
  //     },
  //   );
  // }
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
                  fontSize: 12,
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                formattedTransactionTime,
                style: const TextStyle(
                  fontSize: 10,
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
