import 'package:driev/app_services/Coupon_services.dart';
import 'package:driev/app_services/customer_services.dart';
import 'package:driev/app_utils/app_loading/alert_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../app_config/app_constants.dart';
import '../../app_storages/secure_storage.dart';
import '../../app_themes/app_colors.dart';
import '../../app_themes/custom_theme.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  TextEditingController referCodeCtl = TextEditingController();
  CouponServices couponServices = CouponServices();
  String referCode = "";
  List customerDetails = [];
  SecureStorage secureStorage = SecureStorage();
  AlertServices alertServices = AlertServices();
  CustomerService customerService=CustomerService();
  @override
  void initState() {
    super.initState();
    getCouponCode();
  }

  void getCouponCode() {
    alertServices.showLoading();
    String mobile = secureStorage.get("mobile") ?? "";
    customerService.getCustomer(mobile).then((response) {
      print(response);
      customerDetails = [response];
     referCode = customerDetails[0]['uniqueReferralCode'];
      secureStorage.save("referCode", referCode);
      print(response["uniqueReferralCode"]);
      referCodeCtl.text = referCode;
      alertServices.hideLoading();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Image.asset(Constants.backButton),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const ScrollPhysics(),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              const Text(
                Constants.spreadword,
                style: TextStyle(
                    fontSize: 20,
                    color: AppColors.black,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(
                height: 15,
              ),
              const Text(Constants.sharefreinds,
                  style: TextStyle(
                      fontSize: 18,
                      color: AppColors.referColor,
                      fontWeight: FontWeight.w400),
                  textAlign: TextAlign.center),
              const SizedBox(
                height: 20,
              ),
              Align(
                alignment: Alignment.center,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      width: 240,
                      height: 36,
                      decoration: BoxDecoration(
                        border: Border.all(width: 0.1),borderRadius: BorderRadius.circular(6),
                        color: Colors.white,
                      ),
                      child: TextFormField(
                        controller: referCodeCtl,
                        textAlign: TextAlign.center,
                        textAlignVertical: TextAlignVertical.center,
                        style: const TextStyle(fontSize: 16,
                          color: AppColors.black,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.copy,
                                color: Color(0XffB0B0B0)),
                            onPressed: () {
                              Clipboard.setData(
                                  ClipboardData(text: referCodeCtl.text));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Referral code copied to clipboard')),
                              );
                            },
                          ),
                          hintStyle: CustomTheme.formFieldStyle,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                width: 165,
                height: 42,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      side: const BorderSide(color: Colors.green),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0))),
                  onPressed: () async {
                    final box = context.findRenderObject() as RenderBox?;
                    await Share.share(referCodeCtl.text,
                        subject: "",
                        sharePositionOrigin:
                            box!.localToGlobal(Offset.zero) & box.size);
                  },
                  child: const Text(
                    "Share Now",
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
