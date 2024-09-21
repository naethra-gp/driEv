import 'package:driev/app_themes/app_colors.dart';
import 'package:driev/app_utils/app_loading/alert_services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app_config/app_constants.dart';
import '../../../app_config/app_size_config.dart';
import '../../../app_services/index.dart';
import '../../../app_utils/app_widgets/app_button.dart';

class LoginPage extends StatefulWidget {
  final dynamic mobileNumber;
  const LoginPage({super.key, required this.mobileNumber});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController mobileCtrl = TextEditingController();
  OtpServices otpServices = OtpServices();
  AlertServices alertServices = AlertServices();
  final double smallDeviceHeight = 600;
  final double largeDeviceHeight = 1024;

  @override
  void initState() {
    super.initState();
    if (widget.mobileNumber != null) {
      setState(() {
        mobileCtrl.text = widget.mobileNumber!;
      });
    } else {
      Future<void>.delayed(const Duration(milliseconds: 300), _tryPasteCurrentPhone);
    }
  }
  Future _tryPasteCurrentPhone() async {
    if (!mounted) return;
    try {
      final autoFill = SmsAutoFill();
      final phone = await autoFill.hint;
      if (phone == null) return;
      if (!mounted) return;
      if (phone.toString().startsWith('+91')) {
        mobileCtrl.text = phone.toString().replaceFirst('+91', '');
        setState(() {

        });
      }
      // mobileCtrl.text = phone.toString();
    } on PlatformException catch (e) {
      print('Failed to get mobile number because of: ${e.message}');
    }
  }

  @override
  void dispose() {
    mobileCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double containerHeight;
    double positionedHeight;

    if (height < smallDeviceHeight) {
      containerHeight = height / 1.2;
      positionedHeight = height / 0.925;
    } else if (height >= smallDeviceHeight && height < largeDeviceHeight) {
      containerHeight = height / 1.35;
      positionedHeight = height / 1.045;
    } else {
      containerHeight = height / 1.1;
      positionedHeight = height / 0.95;
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          alignment: AlignmentDirectional.bottomStart,
          children: <Widget>[
            Align(
              alignment: FractionalOffset.bottomCenter,
              child: Container(
                height: containerHeight,
                alignment: Alignment.bottomCenter,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
                  color: Color(0XFFF6F6F6),
                ),
              ),
            ),
            Positioned(
              height: positionedHeight,
              width: width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(padding: EdgeInsets.all(height / 12.5)),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Image.asset(
                      Constants.appLogo,
                      fit: BoxFit.cover,
                      height: 96,
                      width: 96,
                    ),
                  ),
                  SizedBox(height: height / 40),
                  const Text(
                    Constants.divein,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25),
                    child: Text(
                      Constants.popin,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0XFF6F6F6F),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Form(
                    key: _formKey,
                    child: Align(
                      alignment: Alignment.center,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: TextFormField(
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            autofocus: true,
                            controller: mobileCtrl,
                            textAlignVertical: TextAlignVertical.center,
                            style: const TextStyle(fontSize: 14),
                            decoration: const InputDecoration(
                              fillColor: Colors.white,
                              filled: true,
                              counterText: "",
                              isDense: false,
                              contentPadding: EdgeInsets.only(bottom: 4),
                              hintText: "Enter your mobile number",
                              hintStyle: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                letterSpacing: 0,
                                color: Color(0xffDEDEDE),
                              ),
                              errorStyle: TextStyle(
                                color: Colors.redAccent,
                              ),
                              prefixIcon: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    '+91',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50)),
                                borderSide: BorderSide(
                                  width: 1,
                                  color: Color(0xFFDEDEDE),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50)),
                                borderSide: BorderSide(
                                  width: 1,
                                  color: Color(0xFFDEDEDE),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25)),
                                borderSide: BorderSide(
                                  width: 1,
                                  color: AppColors.primary,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4)),
                                borderSide: BorderSide(
                                  width: 1,
                                  color: Colors.redAccent,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4)),
                                borderSide: BorderSide(
                                  width: 1,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ),
                            onChanged: (String value) {
                              if (value.length == 10) {
                                FocusScope.of(context).unfocus();
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: AppButtonWidget(
                              title: 'Send OTP',
                              onPressed: mobileCtrl.text.length != 10
                                  ? null
                                  : submitLogin,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                children: <TextSpan>[
                                  const TextSpan(
                                    text: Constants.termCon1,
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  TextSpan(
                                    text: Constants.termCon2,
                                    style: const TextStyle(color: Colors.blue),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () async {
                                        openBrowser();
                                      },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  openBrowser() async {
    final Uri url = Uri.parse('https://driev.bike/termsandconditions');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      alertServices.errorToast("Could not launch $url");
    }
  }

  void submitLogin() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      alertServices.showLoading();
      String mobile = mobileCtrl.text.toString();
      otpServices.generateOtp(mobile).then(
        (response) async {
          alertServices.hideLoading();
          if (response['type'] == "success") {
            alertServices.successToast("OTP sent to +91$mobile");
            Navigator.pushNamed(context, "verify_otp",
                arguments: mobileCtrl.text.toString());
          } else {
            alertServices.errorToast(response['message'].toString());
          }
        },
      );
    }
  }
}
