import 'package:driev/app_services/Coupon_services.dart';
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
  SecureStorage secureStorage=SecureStorage();
  CouponServices couponServices= CouponServices();
  AlertServices alertServices= AlertServices();
  TextEditingController referCtl= TextEditingController();
  List referCodeStatusDetails=[];
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return MaterialApp(
      home: Scaffold(
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
                  borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
                  color: Color(0XFFF6F6F6),
                ),
              ),
            ),
            Column(
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
                      fontWeight: FontWeight.w700),
                ),
                CustomTheme.defaultHeight10,
                const Text(
                  "Drop it like it's hot below and \n unlock the perks of rolling with us!",
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.referColor,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                CustomTheme.defaultHeight10,
                Align(
                  alignment: Alignment.center,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Container(
                        width: 220,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(width: 0.1),borderRadius: BorderRadius.circular(6),
                          color: Colors.white,
                        ),
                        child: TextFormField(
                          controller: referCtl,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 18,
                            color: AppColors.black,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintStyle: CustomTheme.formFieldStyle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                CustomTheme.defaultHeight10,
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
                CustomTheme.defaultHeight10,
                CustomTheme.defaultHeight10,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
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
          ],
        ),
      ),
    );
  }

  void validateCode() async {
    String code = secureStorage.get("referCode") ?? "";
    if(referCtl.text=="") {
      alertServices.errorToast("Referral Code is empty");
    }else {
      couponServices.validateCouponCode(referCtl.text).then((response) {
        print(response);
        referCodeStatusDetails = [response];
        if( referCodeStatusDetails[0]['status']=="Valid"){
          alertServices.successToast(referCodeStatusDetails[0]['message']);
          Navigator.pushNamed(context, "home");
        }
        else{
          alertServices.errorToast(referCodeStatusDetails[0]['message']);
        }
        setState(() {});
      });
    }
  }
}
