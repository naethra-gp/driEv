import 'dart:convert';

import 'package:driev/app_services/wallet_services.dart';
import 'package:driev/app_storages/secure_storage.dart';
import 'package:driev/app_utils/app_loading/alert_services.dart';
import 'package:flutter/material.dart';
import '../../app_config/app_constants.dart';
import '../../app_themes/app_colors.dart';
import '../../app_themes/custom_theme.dart';

class WithdrawAmount extends StatefulWidget {
  final String balance;
  const WithdrawAmount({super.key, required this.balance});

  @override
  State<WithdrawAmount> createState() => _WithdrawAmountState();
}

class _WithdrawAmountState extends State<WithdrawAmount> {
  AlertServices alertServices = AlertServices();
  SecureStorage secureStorage = SecureStorage();
  WalletServices walletServices = WalletServices();
  String mobile = "";
  TextEditingController withdrawAmountCtl = TextEditingController();
  @override
  void initState() {
    super.initState();
    mobile = secureStorage.get("mobile") ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Image.asset(Constants.backButton),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Help",
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.black,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w300),
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
        ],
      ),
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
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
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      "assets/img/savemoney.png",
                      height: 57,
                      width: 57,
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text(
                          "Current Wallet Balance",
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w400),
                        ),
                        Text(
                          widget.balance,
                          style: const TextStyle(
                              fontSize: 46,
                              color: Colors.black,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text(
                    "Withdrawal Amount",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w500),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Container(
                          width: 270,
                          height: 40,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  width: 1, color: Color(0xffD2D2D2)),
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          child: TextFormField(
                            controller: withdrawAmountCtl,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            textAlignVertical: TextAlignVertical.center,
                            style: const TextStyle(
                                fontSize: 22,
                                color: Colors.black,
                                fontWeight: FontWeight.w500),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintStyle: CustomTheme.formFieldStyle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Container(
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
                    "Pricing",
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "For Money Withdrawal",
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.green,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "One withdrawal/month is Free, post which the \n following charges will be incurred.",
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                        fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  const Row(
                    children: [
                      Expanded(
                          flex: 10,
                          child: Text(
                            "Upto ₹ 1000.00",
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.w700),
                          )),
                      Expanded(
                          flex: 1,
                          child: Text(
                            "₹ 4",
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.w700),
                          )),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const Row(
                    children: [
                      Expanded(
                          flex: 10,
                          child: Text(
                            "₹ 1000.00 - ₹ 25,000.00 ",
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.w700),
                          )),
                      Expanded(
                          flex: 1,
                          child: Text(
                            "₹ 6",
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.w700),
                          )),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const Row(
                    children: [
                      Expanded(
                          flex: 10,
                          child: Text(
                            "Above ₹ 25,000.00 ",
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.w700),
                          )),
                      Expanded(
                        flex: 1,
                        child: Text(
                          "₹ 9",
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: ElevatedButton(
                      onPressed: () {
                        if (withdrawAmountCtl.text == "") {
                          alertServices.errorToast("Enter amount to Withdraw");
                        } else {
                          submitWithdrawal();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        side: const BorderSide(color: Colors.green),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      child: const Text(
                        "Proceed to Withdrawal",
                        style: TextStyle(
                            fontSize: 14,
                            color: AppColors.white,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  CustomTheme.defaultHeight10
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void submitWithdrawal() async {
    alertServices.showLoading();
    var params = {
      "contact": mobile,
      "transactionAmount": withdrawAmountCtl.text,
      "orderId": "0126",
      "transactionStatus": "SUCCESS",
    };
    print("params ${jsonEncode(params)}");
    walletServices.withdrawMoneyFromWallet(params).then((response) {
      alertServices.hideLoading();
      if (response != null) {
        Navigator.pushNamed(context, "home");
      }
    });
  }
}
