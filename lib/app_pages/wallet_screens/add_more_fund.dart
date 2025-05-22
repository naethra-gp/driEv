import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:driev/app_services/customer_services.dart';
import 'package:driev/app_themes/app_colors.dart';
import 'package:driev/app_utils/app_widgets/app_base_screen.dart';
import 'package:driev/app_utils/app_widgets/app_button.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paytm_allinonesdk/paytm_allinonesdk.dart';

import '../../app_config/app_constants.dart';
import '../../app_services/wallet_services.dart';
import '../../app_storages/secure_storage.dart';
import '../../app_utils/app_loading/alert_services.dart';
import '../../app_utils/app_widgets/app_bar_widget.dart';
import '../registration_page/widget/reg_text_form_widget.dart';

class AddMoreFund extends StatefulWidget {
  final List stationDetails;
  final String rideId;
  final List rideID;

  const AddMoreFund({
    super.key,
    required this.stationDetails,
    required this.rideId,
    required this.rideID,
  });

  @override
  State<AddMoreFund> createState() => _AddMoreFundState();
}

class _AddMoreFundState extends State<AddMoreFund> {
  AlertServices alertServices = AlertServices();
  WalletServices walletServices = WalletServices();
  SecureStorage secureStorage = SecureStorage();
  CustomerService customerService = CustomerService();
  final TextEditingController amountCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();

  String result = "";
  String walletBalance = "0";
  List stationDetails = [];
  String rideId = "";
  List rideID = [];

  @override
  void initState() {
    getWalletBalance();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        Navigator.pushReplacementNamed(context, "wallet_summary");
      },
      child: BaseScreen(
        child: Scaffold(
          appBar: const AppBarWidget(),
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            children: <Widget>[
                              const SizedBox(height: 16),
                              Image.asset(
                                "assets/img/oops.png",
                                height: 70,
                                width: 70,
                              ),
                              const SizedBox(height: 40),
                              const Text(
                                "Your Wallet Balance",
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                "\u{20B9} $walletBalance",
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Form(
                                key: formKey,
                                child: TextFormWidget(
                                  title: 'Enter Amount',
                                  controller: amountCtrl,
                                  maxLength: 4,
                                  required: true,
                                  decoration: InputDecoration(
                                    counterText: "",
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                    ),
                                    prefixIcon: const Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.currency_rupee_sharp),
                                        ],
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Color(0xffD2D2D2)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Color(0xffD2D2D2)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Color(0xffD2D2D2)),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          const BorderSide(color: Colors.red),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          const BorderSide(color: Colors.red),
                                    ),
                                    hintStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    errorStyle: const TextStyle(
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                  textInputAction: TextInputAction.done,
                                  keyboardType: Platform.isIOS
                                      ? const TextInputType.numberWithOptions(
                                          signed: true)
                                      : TextInputType.phone,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  style: const TextStyle(
                                    fontSize: 25,
                                    fontFamily: "Roboto",
                                    color: AppColors.black,
                                    fontWeight: FontWeight.bold,
                                    textBaseline: TextBaseline.alphabetic,
                                  ),
                                  prefixIcon: Icons.account_circle_outlined,
                                  validator: (value) {
                                    if (value.toString().trim().isEmpty) {
                                      return "Amount is Mandatory!";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 25),
                              Wrap(
                                runSpacing: 5,
                                spacing: 8,
                                children: [
                                  addFundTextButton(100),
                                  addFundTextButton(200),
                                  addFundTextButton(500),
                                  addFundTextButton(1000),
                                ],
                              ),
                              const SizedBox(height: 50),

                              /// ENABLE / DISABLE TEST PAYMENT
                              Center(
                                child: Text(
                                    "${Constants.isStagingMode ? "Disable" : "Enable"} Test Payment"),
                              ),
                              Switch(
                                activeColor: AppColors.white,
                                trackOutlineColor:
                                    WidgetStateProperty.all(Colors.transparent),
                                activeTrackColor: AppColors.primary,
                                inactiveThumbColor: Colors.white,
                                inactiveTrackColor: Colors.grey.shade500,
                                splashRadius: 50.0,
                                value: Constants.isStagingMode,
                                onChanged: (value) => setState(
                                    () => Constants.isStagingMode = value),
                              ),
                              const SizedBox(height: 16),

                              SizedBox(
                                height: 50,
                                width: double.infinity,
                                child: AppButtonWidget(
                                  title: "Proceed",
                                  onPressed: () {
                                    if (formKey.currentState!.validate()) {
                                      FocusScope.of(context).unfocus();
                                      formKey.currentState!.save();
                                      paytm(amountCtrl.text.toString());
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  addFundTextButton(amount) {
    return SizedBox(
      child: TextButton(
        onPressed: () => addAmount(amount),
        style: ButtonStyle(
          elevation: WidgetStateProperty.all(0),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: WidgetStateProperty.all(
              const EdgeInsets.only(top: 0, bottom: 0, right: 5, left: 5)),
          minimumSize: WidgetStateProperty.all(const Size(75, 35)),
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return const BorderSide(color: AppColors.primary, width: 2);
            }
            return const BorderSide(color: Color(0xffDEDEDE));
          }),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
          ),
        ),
        child: Text(
          "+ ${amount.toString()}",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontFamily: "Roboto",
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

  getCustomerDetails() {
    alertServices.showLoading("Getting user details...");
    String mobile = secureStorage.get("mobile");
    customerService.getCustomer(mobile.toString(), true).then((response) async {
      alertServices.hideLoading();
      List customer = [response];
      return customer[0]['city'] ?? "";
    });
  }

  paytm(String userAmount) async {
    debugPrint("===> PAYTM PROCESS START <===");
    var city = await getCustomerDetails();
    WalletServices walletServices = WalletServices();
    alertServices.showLoading();
    String mobile = secureStorage.get("mobile") ?? "";
    FirebaseCrashlytics.instance
        .log("1. PAYTM PROCESS START - ${mobile.toString()}");
    var initiateTransactionRequest = {
      "amount": userAmount.toString(),
      "contact": mobile.toString(),
      "staging": Constants.isStagingMode,
      "city": city,
    };
    debugPrint("===> Calling Initiate Transaction API <===");
    FirebaseCrashlytics.instance.log("2. Calling Initiate Transaction API");
    debugPrint("Request Params ===> ${jsonEncode(initiateTransactionRequest)}");

    try {
      final res =
          await walletServices.initiateTransaction(initiateTransactionRequest);
      List token = [res];
      debugPrint("====> Initiate Transaction Response <====");
      debugPrint(token.toString());

      if (token[0]['status'].toString().toLowerCase() == "failed") {
        alertServices.hideLoading();
        alertServices.errorToast(token[0]['description']);
        FirebaseCrashlytics.instance
            .log("Initiate API Error: ${token[0]['description'].toString()}");
        return;
      }

      String merchantID = token[0]['mid'].toString();
      String txtToken = token[0]['txnToken'].toString();
      String amount = userAmount.toString();
      String orderID = token[0]['orderId'].toString();
      String callbackURL = token[0]['callbackUrl'].toString();
      bool isStagingMode = Constants.isStagingMode;
      bool rai = false;

      debugPrint("""
      -------------- PAYTM Payment ---------------------
        MerchantID    : $merchantID
        OrderID       : $orderID
        txtToken      : $txtToken
        Amount        : $amount
        callbackURL   : $callbackURL
        isStagingMode : $isStagingMode
      -------------- EOL PAYTM Payment ---------------------
      """);

      alertServices.hideLoading();

      try {
        final response = await AllInOneSdk.startTransaction(
          merchantID,
          orderID,
          amount,
          txtToken,
          callbackURL,
          isStagingMode,
          rai,
        );

        log("===> PAYTM SERVER RESPONSE => $response");
        setState(() {
          result = response.toString();
        });

        List res = [response];
        debugPrint("===> PayTM Success Result ---> ${res[0]}");
        debugPrint("===> Transaction Success <===");
        String txtId = res[0]['TXNID'];
        String status = res[0]['STATUS'];
        String txtTime = res[0]['TXNDATE'];
        FirebaseCrashlytics.instance.log("Paytm Success: ${res[0]}");
        await creditMoneyToWallet(amount, orderID, status, txtId, txtTime);
      } catch (onError, stack) {
        FirebaseCrashlytics.instance
            .recordError(onError, stack, reason: 'PAYTM Error');
        if (onError is PlatformException) {
          setState(() {
            result = "${onError.message!} \n  ${onError.details}";
          });
        } else {
          setState(() {
            result = onError.toString();
          });
        }

        if (onError is Map) {
          String txtId = onError['TXNID'] ?? '';
          String status = onError['STATUS'] ?? '';
          String txtTime = onError['TXNDATE'] ?? '';
          await creditMoneyToWallet(amount, orderID, status, txtId, txtTime);
        }
      }
    } catch (e, stack) {
      FirebaseCrashlytics.instance
          .recordError(e, stack, reason: 'Initiate Transaction Error');
      alertServices.hideLoading();
      alertServices.errorToast("Failed to initiate transaction");
    }
  }

  creditMoneyToWallet(amount, oId, status, txtId, txtTime) async {
    alertServices.showLoading();
    String mobile = secureStorage.get("mobile");
    var params = {
      "contact": mobile.toString(),
      "transactionAmount": amount,
      "transactionTime": txtTime,
      "orderId": oId.toString(),
      "transactionStatus": status.toString(),
      "transactionId": txtId.toString(),
    };
    debugPrint("====> Credit Money Request -> ${jsonEncode(params)}");
    walletServices.creditMoneyToWallet(params).then((dynamic response) {
      alertServices.hideLoading();
      debugPrint("====> Credit Money Response -> $response");
      try {
        if (response != null) {
          setState(() {
            walletBalance = [response][0]['closingBalance'].toString();
            stationDetails = widget.stationDetails;
            rideId = widget.rideId;
            rideID = widget.rideID;
          });
          if (stationDetails.isNotEmpty ||
              rideID.isNotEmpty ||
              rideId.isNotEmpty) {
            alertSuccess(context, "TRANSACTION SUCCESS");
          } else {
            Navigator.pushNamed(context, "transaction_success");
          }
        } else {
          debugPrint("===> Credit Money Error <===");
          Navigator.pushReplacementNamed(context, "transaction_failure");
        }
      } catch (e, stack) {
        debugPrint("Catch Error: ${e.toString()}");
        FirebaseCrashlytics.instance
            .recordError(e, stack, reason: 'Credit Money API error');
        Navigator.pushReplacementNamed(context, "transaction_failure");
      }
    });
  }

  void addAmount(int amount) {
    int currentAmount = int.tryParse(amountCtrl.text.trim()) ?? 0;
    int newAmount = currentAmount + amount;
    amountCtrl.text = newAmount.toString();
  }

  Future alertSuccess(BuildContext context, String msg) async {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: ((context) {
        return PopScope(
            canPop: false,
            child: AlertDialog(
              title: Text(
                msg,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              actions: [
                TextButton(
                    style: TextButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.labelLarge,
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('OK',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () {
                      if (stationDetails.isNotEmpty) {
                        Navigator.pushReplacementNamed(
                          context,
                          "bike_fare_details",
                          arguments: {"query": stationDetails},
                        );
                      } else if (rideId.isNotEmpty) {
                        Navigator.pushReplacementNamed(
                          context,
                          "on_ride",
                          arguments: rideId,
                        );
                      } else if (rideID.isNotEmpty) {
                        Navigator.pushReplacementNamed(
                          context,
                          "scan_to_end_ride",
                          arguments: rideID,
                        );
                      }
                    }),
              ],
            ));
      }),
    );
  }
}
