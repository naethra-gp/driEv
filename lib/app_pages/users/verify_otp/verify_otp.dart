import 'dart:async';
import 'package:flutter/material.dart';
import 'package:driev/app_storages/secure_storage.dart';
import 'package:driev/app_themes/app_colors.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:readsms/readsms.dart';

import '../../../app_config/app_constants.dart';
import '../../../app_services/index.dart';
import '../../../app_utils/app_loading/alert_services.dart';
import '../../../app_utils/app_widgets/app_button.dart';

class VerifyOTP extends StatefulWidget {
  final String mobileNumber;
  const VerifyOTP({super.key, required this.mobileNumber});

  @override
  State<VerifyOTP> createState() => _VerifyOTPState();
}

class _VerifyOTPState extends State<VerifyOTP> {
  OtpServices otpServices = OtpServices();
  CustomerService customerService = CustomerService();
  AlertServices alertServices = AlertServices();
  TextEditingController otpCtrl = TextEditingController();
  CampusServices campusServices = CampusServices();
  SecureStorage secureStorage = SecureStorage();
  VehicleService vehicleService = VehicleService();

  bool buttonEnabled = false;
  int _otpExpireTime = 30;
  Timer? _timer;
  bool invalidOtp = false;
  bool enableResend = false;
  bool clearOtp = false;
  bool hasError = false;

  /// NEW OTP AUTO FILL
  StreamController<ErrorAnimationType>? errorController;
  final _plugin = Readsms();

  @override
  void initState() {
    super.initState();
    print("----> Verify OTP <----");
    errorController = StreamController<ErrorAnimationType>();
    startTimer();
    getPermission().then((value) {
      if (value) {
        _plugin.read();
        _plugin.smsStream.listen((event) {
          String sms = event.body;
          RegExp regExp = RegExp(r'\b\d+\b');
          String otpCode = regExp.firstMatch(sms)?.group(0) ?? "";
          setState(() {
            otpCtrl.text = otpCode;
          });
        });
      }
    });
  }

  @override
  void dispose() {
    errorController!.close();
    _timer?.cancel();
    otpCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          alignment: AlignmentDirectional.bottomStart,
          children: <Widget>[
            Align(
              alignment: FractionalOffset.bottomCenter,
              child: Container(
                height: MediaQuery.of(context).size.height / 1.35,
                alignment: Alignment.bottomCenter,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(26),
                    topRight: Radius.circular(26),
                  ),
                  color: Color(0XFFF6F6F6),
                ),
              ),
            ),
            Column(
              children: [
                Padding(
                    padding: EdgeInsets.all(
                        MediaQuery.of(context).size.height / 12.5)),
                Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    height: 96,
                    child: Image.asset(
                      Constants.appLogo,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  child: Text(
                    "Verify your Phone number to finish setting up your account",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text:
                              "Please enter the verification code send to \n +91 ${maskMobileNumber(widget.mobileNumber)} ",
                          style: const TextStyle(
                            fontSize: 16.0,
                            height: 1.5,
                            color: Color(0xff6F6F6F),
                          ),
                        ),
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushReplacementNamed(context, "login",
                                  arguments: widget.mobileNumber.toString());
                            },
                            child: const Icon(
                              Icons.edit_outlined,
                              size: 20,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: PinCodeTextField(
                    appContext: context,
                    length: 6,
                    autoFocus: true,
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    keyboardType: TextInputType.phone,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    blinkWhenObscuring: true,
                    animationType: AnimationType.fade,
                    errorAnimationController: errorController,
                    autoDisposeControllers: false,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(10),
                      fieldHeight: 55,
                      fieldWidth: 50,
                      activeFillColor: Colors.white,
                      selectedFillColor: Colors.white,
                      inactiveFillColor: Colors.white,
                      inactiveColor: Colors.grey,
                      activeColor:
                          hasError ? Colors.redAccent : AppColors.primary,
                      selectedColor: AppColors.primary,
                      borderWidth: 2,
                    ),
                    cursorColor: Colors.black,
                    animationDuration: const Duration(milliseconds: 300),
                    enableActiveFill: true,
                    controller: otpCtrl,
                    boxShadows: const [
                      BoxShadow(
                        offset: Offset(0, 1),
                        color: Colors.black,
                        blurRadius: 10,
                      )
                    ],
                    onCompleted: (v) {
                      if (v.toString().length == 6) {
                        setState(() {
                          buttonEnabled = true;
                        });
                      }
                    },
                    onChanged: (value) {
                      if (value.toString().length == 6) {
                        setState(() {
                          buttonEnabled = true;
                        });
                      } else {
                        setState(() {
                          hasError = false;
                        });
                      }
                    },
                    pastedTextStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (invalidOtp)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      "Oops! Looks like that OTP didn't hit the mark. Please enter the correct OTP",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                if (!invalidOtp)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      "Your OTP will expire in ${getFormattedTime(_otpExpireTime)} Secs.",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.redAccent, fontWeight: FontWeight.bold),
                    ),
                  ),
                const SizedBox(height: 10),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: <TextSpan>[
                        const TextSpan(
                          text: 'Did not get the code? ',
                          style: TextStyle(
                            color: AppColors.blackLight,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: 'Resend code',
                          style: TextStyle(
                            color: !enableResend
                                ? Colors.grey[600]
                                : AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              if (enableResend) {
                                resendOTP();
                              }
                            },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height / 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: AppButtonWidget(
                    title: 'Verify',
                    onPressed: !buttonEnabled
                        ? null
                        : () {
                            if (otpCtrl.text.length == 6) {
                              var vRequest = {
                                "mobileNos": widget.mobileNumber,
                                "otp": otpCtrl.text.toString(),
                                "source": "app",
                                "clientId": Constants.clientId,
                                "clientSecret": Constants.clientSecret,
                              };
                              alertServices.showLoading();
                              otpServices
                                  .verifyOtp(vRequest)
                                  .then((vResponse) async {
                                if (vResponse['type'] == "success") {
                                  String mobile =
                                      widget.mobileNumber.toString();
                                  String token = vResponse['token_info']
                                          ['token']
                                      .toString();

                                  /// SAVE LOCAL VALUES
                                  secureStorage.saveToken(token);
                                  secureStorage.save("mobile", mobile);

                                  /// REDIRECT
                                  customerService
                                      .getCustomer(mobile, true)
                                      .then((cResponse) async {
                                    alertServices.hideLoading();
                                    if (cResponse != null) {
                                      secureStorage.save("isLogin", true);
                                      getActiveRides(mobile);
                                    } else {
                                      Navigator.pushNamedAndRemoveUntil(context,
                                          "success_page", (route) => false);
                                    }
                                  });
                                } else {
                                  alertServices.hideLoading();
                                  setState(() {
                                    hasError = true;
                                    enableResend = true;
                                    invalidOtp = true;
                                    buttonEnabled = false;
                                    clearOtp = true;
                                  });
                                  errorController!
                                      .add(ErrorAnimationType.shake);
                                  Future.delayed(
                                      const Duration(milliseconds: 100), () {
                                    setState(() {
                                      clearOtp = false;
                                    });
                                  });
                                }
                              });
                            } else {
                              alertServices
                                  .errorToast("Please enter valid OTP!");
                            }
                          },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        clearOtp = false;
        if (_otpExpireTime > 0) {
          _otpExpireTime--;
        } else {
          enableResend = true;
          _timer?.cancel();
        }
      });
    });
  }

  void resendOTP() {
    otpCtrl.clear();
    setState(() {
      hasError = false;
      invalidOtp = false;
      enableResend = false;
    });
    _timer?.cancel();
    alertServices.showLoading();
    otpServices
        .generateOtp(widget.mobileNumber.toString())
        .then((response) async {
      alertServices.hideLoading();
      if (response['type'] == "success") {
        alertServices
            .successToast("OTP sent to +91${widget.mobileNumber.toString()}");
        setState(() {
          _otpExpireTime = 30;
        });
        startTimer();
      } else {
        alertServices.errorToast(response['message'].toString());
      }
    });
  }

  String getFormattedTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String maskMobileNumber(String mobileNumber) {
    if (mobileNumber.length != 10) {
      return 'Invalid mobile number';
    }
    String maskedNumber = mobileNumber.substring(0, 2);
    maskedNumber += 'XXXXXX';
    maskedNumber += mobileNumber.substring(8);

    return maskedNumber;
  }

  Future<bool> getPermission() async {
    if (await Permission.sms.status == PermissionStatus.granted) {
      return true;
    } else {
      if (await Permission.sms.request() == PermissionStatus.granted) {
        return true;
      } else {
        return false;
      }
    }
  }

  getActiveRides(String mobile) {
    alertServices.showLoading();
    vehicleService.getActiveRides(mobile).then((r) {
      alertServices.hideLoading();
      if (r != null) {
        List rideList = [r][0]['rideList'];
        List a =
            rideList.where((e) => e['status'].toString() == "On Ride").toList();
        if (a.isEmpty) {
          getBlockRides(mobile);
        } else {
          Navigator.pushNamed(context, "on_ride",
              arguments: a[0]['rideId'].toString());
        }
      }
    });
  }

  getBlockRides(String mobile) {
    alertServices.showLoading();
    vehicleService.getBlockedRides(mobile).then((r) {
      alertServices.hideLoading();
      if (r != null) {
        if (r.isNotEmpty) {
          Navigator.pushNamed(context, "extend_bike", arguments: r);
        } else {
          Navigator.pushNamedAndRemoveUntil(context, "home", (route) => false);
        }
      }
    });
  }
}
