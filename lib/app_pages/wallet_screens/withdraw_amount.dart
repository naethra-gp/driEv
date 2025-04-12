import 'dart:io';

import 'package:driev/app_pages/app_common/need_help_widget.dart';
import 'package:driev/app_services/wallet_services.dart';
import 'package:driev/app_storages/secure_storage.dart';
import 'package:driev/app_utils/app_loading/alert_services.dart';
import 'package:driev/app_utils/app_widgets/app_bar_widget.dart';
import 'package:driev/app_utils/app_widgets/app_base_screen.dart';
import 'package:driev/app_utils/app_widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app_themes/app_colors.dart';
import 'widgets/wallet_balance_widget.dart';

class WithdrawAmount extends StatefulWidget {
  const WithdrawAmount({super.key});

  @override
  State<WithdrawAmount> createState() => _WithdrawAmountState();
}

class _WithdrawAmountState extends State<WithdrawAmount> {
  AlertServices alertServices = AlertServices();
  SecureStorage secureStorage = SecureStorage();
  WalletServices walletServices = WalletServices();
  String mobile = "";
  final TextEditingController _controller = TextEditingController();
  String balance = "0";
  final _formKey = GlobalKey<FormState>();

  final double smallDeviceHeight = 600;
  final double largeDeviceHeight = 1024;

  @override
  void initState() {
    super.initState();
    getBalance();
  }

  getBalance() {
    alertServices.showLoading();
    mobile = secureStorage.get("mobile");
    walletServices.getWalletBalance(mobile).then((response) {
      alertServices.hideLoading();
      List result = [response];
      if (response != null) {
        setState(() {
          balance = result[0]['balance'].toString();
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    final ScrollPhysics scrollOption;

    if (height < smallDeviceHeight) {
      scrollOption = const AlwaysScrollableScrollPhysics();
    } else if (height >= smallDeviceHeight && height < largeDeviceHeight) {
      scrollOption = const NeverScrollableScrollPhysics();
    } else {
      scrollOption = const NeverScrollableScrollPhysics();
    }

    return BaseScreen(
      child: Scaffold(
        appBar: AppBarWidget(
          rightWidget: IconButton(
            onPressed: () {
              needHelpAlert(context);
            },
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Help",
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.black,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(width: 5),
                Image.asset(
                  "assets/img/vector.png", // Make sure this asset exists
                  width: 20,
                  height: 20,
                ),
                const SizedBox(width: 10),
              ],
            ),
          ),
        ),
        body: SingleChildScrollView(
          physics: scrollOption,
          scrollDirection: Axis.vertical,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                WalletBalanceWidget(balance: balance.toString()),
                const SizedBox(height: 50),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Text(
                        "Withdrawal Amount",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: "Roboto",
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 35,
                          vertical: 10,
                        ),
                        child: TextFormField(
                          maxLength: 5,
                          controller: _controller,
                          textAlign: TextAlign.center,
                          textAlignVertical: TextAlignVertical.center,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          keyboardType: Platform.isIOS
                              ? const TextInputType.numberWithOptions(
                                  signed: true)
                              : TextInputType.phone,
                          style: const TextStyle(
                            fontSize: 30,
                            fontFamily: "Roboto",
                            color: AppColors.black,
                            fontWeight: FontWeight.bold,
                            textBaseline: TextBaseline.alphabetic,
                          ),
                          validator: (String? value) {
                            if (value.toString().trim().isEmpty) {
                              return "Please enter valid amount!";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            counterText: "",
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 50),
                            prefixIcon: const Padding(
                              padding: EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.currency_rupee_sharp),
                                ],
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: Color(0xffD2D2D2)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: Color(0xffD2D2D2)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: Color(0xffD2D2D2)),
                            ),
                            hintStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  decoration: const BoxDecoration(
                    color: AppColors.walletColor,
                    // color: Colors.red,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(25),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: 25),
                      const Text(
                        "Pricing",
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: "Poppins",
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "For Money Withdrawal",
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: "Poppins",
                          color: Colors.green,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "One withdrawal a month is Free, post which the following charges will be incurred.",
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: "Poppins",
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildPricingRow("Upto ₹ 1000.00", "₹ 4"),
                      const SizedBox(height: 10),
                      _buildPricingRow("₹ 1000.00 - ₹ 25,000.00", "₹ 6"),
                      const SizedBox(height: 10),
                      _buildPricingRow("Above ₹ 25,000.00", "₹ 9"),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: AppButtonWidget(
                          onPressed: () {
                            if (_controller.text == "") {
                              alertServices
                                  .errorToast("Enter amount to Withdraw");
                            } else if (RegExp(r'^0+$')
                                .hasMatch(_controller.text)) {
                              alertServices
                                  .errorToast("Enter valid amount to Withdraw");
                            } else if (convert(balance) <
                                convert(_controller.text)) {
                              alertServices.errorToast(
                                  "Insufficient funds for withdrawal.");
                            } else {
                              submitWithdrawal();
                            }
                          },
                          title: "Proceed to Withdrawal",
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void submitWithdrawal() async {
    alertServices.showLoading();
    var params = {"contact": mobile, "transactionAmount": _controller.text};
    walletServices.withdrawMoneyFromWallet(params).then((response) {
      alertServices.hideLoading();
      List result = [response];
      if (response != null) {
        setState(() {
          balance = result[0]['closingBalance'].toString();
          _controller.text = "";
        });
        alertServices.successToast(result[0]['message'].toString());
        Navigator.pushReplacementNamed(context, "wallet_summary");
      }
    });
  }

  convert(String amount) {
    return double.parse(amount);
  }

  Widget _buildPricingRow(String title, String price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: "Roboto",
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            price,
            style: const TextStyle(
              fontFamily: "Roboto",
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  needHelpAlert(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      barrierColor: Colors.black87,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: false,
      builder: (context) {
        return const NeedHelpWidget();
      },
    );
  }
}
