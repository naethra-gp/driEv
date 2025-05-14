import 'package:driev/app_services/coupon_services.dart';
import 'package:driev/app_storages/secure_storage.dart';
import 'package:driev/app_utils/app_loading/alert_services.dart';
import 'package:flutter/material.dart';
import '../../app_config/app_constants.dart';
import '../../app_themes/app_colors.dart';
import '../../app_themes/custom_theme.dart';

class ReferCodeApply extends StatefulWidget {
  const ReferCodeApply({super.key});

  @override
  State<ReferCodeApply> createState() => _ReferCodeApplyState();
}

class _ReferCodeApplyState extends State<ReferCodeApply> {
  SecureStorage secureStorage = SecureStorage();
  CouponServices couponServices = CouponServices();
  AlertServices alertServices = AlertServices();
  TextEditingController referCtl = TextEditingController();
  List referCodeStatusDetails = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        alignment: AlignmentDirectional.bottomStart,
        children: <Widget>[
          Align(
            alignment: FractionalOffset.bottomCenter,
            child: Container(
              height: height / 1.5,
              alignment: Alignment.bottomCenter,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                color: Color(0XFFF6F6F6),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(padding: EdgeInsets.all(height / 7.3)),
                Align(
                  alignment: Alignment.topCenter,
                  child: Image.asset(
                    Constants.appLogo,
                    fit: BoxFit.cover,
                    height: 96,
                    width: 96,
                  ),
                ),
                CustomTheme.defaultHeight10,
                CustomTheme.defaultHeight10,
                const Text(
                  "Do you have Referral Code?",
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                CustomTheme.defaultHeight10,
                const Text(
                  "Drop it like it's hot below and\nunlock the perks of rolling with us!",
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.referColor,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                CustomTheme.defaultHeight10,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: TextFormField(
                    controller: referCtl,
                    maxLength: 15,
                    textAlign: TextAlign.center,
                    textAlignVertical: TextAlignVertical.center,
                    textCapitalization: TextCapitalization.characters,
                    style: const TextStyle(
                      fontSize: 18,
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      counterText: "",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xffD2D2D2)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xffD2D2D2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xffD2D2D2)),
                      ),
                      hintStyle: CustomTheme.formFieldStyle,
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        validateCode();
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        textStyle: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.green,
                        side: const BorderSide(
                            color: AppColors.primary, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: const Text(
                        "Continue",
                        style: TextStyle(color: AppColors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "success_page");
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        textStyle: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white,
                        side: const BorderSide(
                            color: AppColors.primary, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: const Text(
                        "Skip",
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void validateCode() async {
    // String code = secureStorage.get("referCode") ?? "";
    if (referCtl.text == "") {
      alertServices.errorToast("Referral Code is empty");
    } else {
      alertServices.showLoading();
      couponServices.validateCouponCode(referCtl.text).then((response) {
        referCodeStatusDetails = [response];
        String msg = referCodeStatusDetails[0]['message'].toString();
        String status = referCodeStatusDetails[0]['status'].toString();
        alertServices.hideLoading();
        if (status == "Valid") {
          secureStorage.save("referCode", referCtl.text.toString());
          alertServices.successToast(msg);
          Navigator.pushNamed(context, "success_page");
        } else {
          alertServices.errorToast(msg);
        }
        setState(() {});
      });
    }
  }
}
