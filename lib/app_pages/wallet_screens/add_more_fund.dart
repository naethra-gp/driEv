import 'package:driev/app_themes/app_colors.dart';
import 'package:driev/app_utils/app_widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paytm_allinonesdk/paytm_allinonesdk.dart';

import '../../app_config/app_constants.dart';
import '../../app_services/wallet_services.dart';
import '../../app_storages/secure_storage.dart';
import '../../app_utils/app_loading/alert_services.dart';
import '../registration_page/widget/reg_text_form_widget.dart';

class AddMoreFund extends StatefulWidget {
  final List stationDetails;
  final String rideId;
  final List rideID;
  const AddMoreFund({super.key,required this.stationDetails,required this.rideId,required this.rideID});
  @override
  State<AddMoreFund> createState() => _AddMoreFundState();
}

class _AddMoreFundState extends State<AddMoreFund> {
  AlertServices alertServices = AlertServices();
  WalletServices walletServices = WalletServices();
  SecureStorage secureStorage = SecureStorage();
  String result = "";
  String walletBalance = "0";
  final TextEditingController amountCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();
  List stationDetails=[];
  String rideId="";
  List rideID=[];

  @override
  void initState() {
    print("stationDetails---->");
    print(widget.stationDetails);
    print("rideId---->");
    print(widget.rideId);
    print("End Scan rideId---->");
    print(widget.rideID);
    getWalletBalance();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.red,
            statusBarIconBrightness:
                Brightness.dark, // For Android (dark icons)
            statusBarBrightness: Brightness.light, // For iOS (dark icons)
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
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
              // const SizedBox(height: 10),
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
                  prefixText: "\u{20B9}",
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.account_circle_outlined,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    if (value.toString().trim().isEmpty) {
                      return "Amount is Mandatory!";
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => addAmount(100),
                    style: ButtonStyle(
                      overlayColor: MaterialStateProperty.all(Colors.transparent),
                      side: MaterialStateProperty.resolveWith((states) {
                        if (states.contains(MaterialState.pressed)) {
                          return const BorderSide(color: AppColors.primary,width: 2);
                        }
                        return const BorderSide(color: Color(0xffDEDEDE));
                      }),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    child: const Text(" +100 ", style: TextStyle(color: Colors.black)),
                  ),
                  TextButton(
                    onPressed: () => addAmount(200),
                    style: ButtonStyle(
                      overlayColor: MaterialStateProperty.all(Colors.transparent),
                      side: MaterialStateProperty.resolveWith((states) {
                        if (states.contains(MaterialState.pressed)) {
                          return const BorderSide(color: AppColors.primary,width: 2);
                        }
                        return const BorderSide(color: Color(0xffDEDEDE));
                      }),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    child: const Text(" +200 ", style: TextStyle(color: Colors.black)),
                  ),
                  TextButton(
                    onPressed: () => addAmount(500),
                    style: ButtonStyle(
                      overlayColor: MaterialStateProperty.all(Colors.transparent),
                      side: MaterialStateProperty.resolveWith((states) {
                        if (states.contains(MaterialState.pressed)) {
                          return const BorderSide(color: AppColors.primary,width: 2);
                        }
                        return const BorderSide(color: Color(0xffDEDEDE));
                      }),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    child: const Text(" +500 ", style: TextStyle(color: Colors.black)),
                  ),
                  TextButton(
                    onPressed: () => addAmount(1000),
                    style: ButtonStyle(
                      overlayColor: MaterialStateProperty.all(Colors.transparent),
                      side: MaterialStateProperty.resolveWith((states) {
                        if (states.contains(MaterialState.pressed)) {
                          return const BorderSide(color: AppColors.primary,width: 2);
                        }
                        return const BorderSide(color: Color(0xffDEDEDE));
                      }),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    child: const Text(" +1000 ", style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
              const SizedBox(height: 50),
              SizedBox(
                height: 42,
                width: double.maxFinite,
                child: AppButtonWidget(
                  title: "Proceed",
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
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

  paytm(String amount) {
    WalletServices walletServices = WalletServices();
    alertServices.showLoading();
    String mobile = secureStorage.get("mobile") ?? "";
    var params = {
      "amount": amount.toString(),
      "contact": mobile.toString(),
      "staging": Constants.isStagingMode,
    };
    print(params);
    walletServices.initiateTransaction(params).then((dynamic res) {
      List token = [res];
      print(token);
      String mid = token[0]['mid'].toString();
      String tToken = token[0]['txnToken'].toString();
      String amt = amount.toString();
      String oId = token[0]['orderId'].toString();
      String cbUrl = token[0]['callbackUrl'].toString();
      bool staging = Constants.isStagingMode;
      bool rai = false;
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
          creditMoneyToWallet(amt, oId, res[0]['STATUS'].toString());
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
  creditMoneyToWallet(amount, oId, status) async {
    alertServices.showLoading();
    String mobile = secureStorage.get("mobile");
    var params = {
      "contact": mobile.toString(),
      "transactionAmount": amount,
      "orderId": oId.toString(),
      "transactionStatus": status.toString()
    };
    walletServices.creditMoneyToWallet(params).then((dynamic response) {
      alertServices.hideLoading();
      if (response != null) {
        setState(() {
          walletBalance = [response][0]['closingBalance'].toString();
          stationDetails=widget.stationDetails;
          rideId=widget.rideId;
          rideID=widget.rideID;
          print("final-------->");
          print(stationDetails);
          print(rideId);
          print(rideID);
        });
        if(stationDetails.isNotEmpty||rideID.isNotEmpty||rideId.isNotEmpty) {
          AlertSuccess(context, "TRANSACTION SUCCESS");
        }else{
          Navigator.pushNamed(context, "transaction_success");
        }
      }
    });
  }
  void addAmount(int amount) {
    int currentAmount = int.tryParse(amountCtrl.text.trim()) ?? 0;
    int newAmount = currentAmount + amount;
    amountCtrl.text = newAmount.toString();
  }
  Future AlertSuccess(BuildContext context,String msg) async {
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
            const TextStyle(fontSize:18,fontWeight: FontWeight.bold),
          ),
          actions: [
            TextButton(
                style: TextButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.labelLarge,
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  if(stationDetails.isNotEmpty) {
                    print("GO TO --> BIKEFARE");
                    Navigator.pushReplacementNamed(context, "bike_fare_details",
                      arguments: {"query": stationDetails},
                    );
                  }
                  else if(rideId.isNotEmpty){
                    print("GO TO--> ONRIDE");
                    Navigator.pushReplacementNamed(context, "on_ride",
                        arguments: rideId);
                  }
                  else if(rideID.isNotEmpty){
                    print("GO TO--> SCANTO END RIDE");
                    Navigator.pushReplacementNamed(context, "scan_to_end_ride",
                        arguments: rideID);
                  }

                }),
          ],
        ));
      }),
    );
  }

}
