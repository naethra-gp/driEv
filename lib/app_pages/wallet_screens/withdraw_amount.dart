import 'package:driev/app_services/wallet_services.dart';
import 'package:driev/app_storages/secure_storage.dart';
import 'package:driev/app_utils/app_loading/alert_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app_config/app_constants.dart';
import '../../app_themes/app_colors.dart';
import '../../app_themes/custom_theme.dart';

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
  // FocusNode? _focusNode;
  String balance = "0";
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    getBalance();
    // _focusNode = FocusNode();
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
    // _focusNode?.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Theme.of(context).primaryColor,
      ),
      child: SafeArea(
        child: Scaffold(
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
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: const Color(0xffF5F5F5),
                        borderRadius: BorderRadius.circular(10),
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
                                balance,
                                style: const TextStyle(
                                  fontSize: 46,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
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
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 50,
                            vertical: 10,
                          ),
                          child: TextFormField(
                            maxLength: 5,
                            controller: _controller,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            textAlignVertical: TextAlignVertical.center,
                            validator: (String? value) {
                              print(value.toString().trim());
                              if (value.toString().trim().isEmpty) {
                                return "Please enter valid amount!";
                              }
                              return null;
                            },
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            style: const TextStyle(
                              fontSize: 18,
                              color: AppColors.black,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                            decoration: InputDecoration(
                              counterText: "",
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              prefixIcon: const Padding(
                                padding: EdgeInsets.all(10.0),
                                child: Row(
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
                              hintStyle: CustomTheme.formFieldStyle,
                            ),

                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 30,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.walletColor,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(25),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          "Pricing",
                          style: TextStyle(
                            fontSize: 16,
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
                        const Row(
                          children: [
                            Expanded(
                              flex: 10,
                              child: Text(
                                "Upto ₹ 1000.00",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                "₹ 4",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        const Row(
                          children: [
                            Expanded(
                                flex: 10,
                                child: Text(
                                  "₹ 1000.00 - ₹ 25,000.00",
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
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 50),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // if (_formKey.currentState!.validate()) {
                              //   submitWithdrawal();
                              // }
                              if (_controller.text == "") {
                                alertServices
                                    .errorToast("Enter amount to Withdraw");
                              } else if (convert(balance) <
                                  convert(_controller.text)) {
                                alertServices
                                    .errorToast("Enter below wallet amount!");
                              } else {
                                submitWithdrawal();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: AppColors.primary,
                              side: const BorderSide(
                                  color: AppColors.primary, width: 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: const Text(
                              "Proceed to Withdrawal",
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),
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
        alertServices.successToast(result[0]['description'].toString());
      }
    });
  }

  convert(String amount) {
    return double.parse(amount);
  }
}
