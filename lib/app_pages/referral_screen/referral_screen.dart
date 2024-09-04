import 'dart:ui';

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
  CustomerService customerService = CustomerService();

  /// INITIATION STATE
  @override
  void initState() {
    debugPrint(" --- Referral Screen --- ");
    super.initState();
    getCouponCode();
  }

  void getCouponCode() {
    alertServices.showLoading();
    String mobile = secureStorage.get("mobile") ?? "";
    customerService.getCustomer(mobile).then((response) {
      customerDetails = [response];
      referCode = customerDetails[0]['uniqueReferralCode'].toString();
      secureStorage.save("referCode", referCode);
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
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Text(
              Constants.spreadword,
              style: TextStyle(
                fontSize: 22,
                color: AppColors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              Constants.rewardText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: AppColors.referColor,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: 250,
              height: 45,
              child: TextFormField(
                readOnly: true,
                controller: referCodeCtl,
                textAlign: TextAlign.center,
                textAlignVertical: TextAlignVertical.center,
                style: fieldStyle(),
                decoration: decoration(),
              ),
            ),
            const SizedBox(height: 40),
            buttonWidget(),
          ],
        ),
      ),
    );
  }

  clickToCopy() {
    Clipboard.setData(ClipboardData(text: referCodeCtl.text));
    alertServices.toast("Referral code copied to clipboard");
  }

  TextStyle fieldStyle() {
    return const TextStyle(
      fontSize: 20,
      fontFamily: "Roboto",
      color: AppColors.black,
      fontWeight: FontWeight.w900,
    );
  }

  Widget buttonWidget() {
    return SizedBox(
      width: 180,
      height: 45,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.green,
          side: const BorderSide(color: Colors.green),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        onPressed: () async {
          RenderBox? box = context.findRenderObject() as RenderBox?;
          String msg =
              "Spreading the word means sharing the perks! Use my referral code ${referCodeCtl.text.toString()} to sign up with Let’s driEV and start enjoying the perks right away! It’s a win-win!\n https://play.google.com/store/apps/details?id=com.release.community";
          await Share.share(
            msg,
            subject: "",
            sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
          );
        },
        child: const Text(
          "Share Now",
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  InputDecoration decoration() {
    return InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.only(left: 45),
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
      suffixIcon: IconButton(
        icon: const Icon(Icons.copy, color: Color(0XffB0B0B0), size: 20),
        onPressed: () {
          clickToCopy();
        },
      ),
    );
  }
}
