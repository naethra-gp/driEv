import 'dart:convert';
import 'package:driev/app_themes/custom_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:otp_autofill/otp_autofill.dart';
import '../../../app_services/index.dart';
import '../../../app_storages/secure_storage.dart';
import '../../../app_themes/app_colors.dart';
import '../../../app_utils/app_loading/alert_services.dart';
import '../../../app_utils/app_widgets/app_button.dart';

class AadhaarVerifyScreen extends StatefulWidget {
  final String aadhaar;
  final Function(List) onConfirm;
  const AadhaarVerifyScreen(
      {super.key, required this.aadhaar, required this.onConfirm});

  @override
  State<AadhaarVerifyScreen> createState() => _AadhaarVerifyScreenState();
}

class _AadhaarVerifyScreenState extends State<AadhaarVerifyScreen> {
  TextEditingController otpCtrl = TextEditingController();
  List aadhaar = [];
  String clientId = '';
  AlertServices alertServices = AlertServices();
  OtpServices otpServices = OtpServices();
  SecureStorage secureStorage = SecureStorage();
  OTPInteractor otpInteractor = OTPInteractor();

  @override
  void initState() {
    _initInteractor();
    sendOtp();
    super.initState();
    otpCtrl = OTPTextEditController(
      codeLength: 6,
      onCodeReceive: (code) => print(
          'OTP for Aadhaar (XX8755) is $code (valid for 10 mins). To update Aadhaar, Upload documents on myaadhaar.uidai.gov.in or visit Aadhaar Center. Call 1947 for info. -UIDAI'),
      otpInteractor: otpInteractor,
    )..startListenUserConsent(
        (code) {
          final exp = RegExp(r'(\d{6})');
          return exp.stringMatch(code ?? '') ?? '';
        },
        // strategies: [
        //   SampleStrategy(),
        // ],
      );
  }

  Future<void> _initInteractor() async {
    otpInteractor = OTPInteractor();
    final appSignature = await otpInteractor.getAppSignature();
    if (kDebugMode) {
      print('Your app signature: $appSignature');
    }
  }

  sendOtp() {
    alertServices.showLoading();
    otpServices
        .aadhaarSentOtp({"id_number": widget.aadhaar}).then((response) async {
      alertServices.hideLoading();
      if (response == null) {
        Navigator.of(context).pop();
        // widget.onConfirm(aadhaar);
      }
      print("response -> $response");
      alertServices.successToast(response['message']);
      setState(() {
        clientId = response['data']['client_id'];
      });
    });
  }

  verifyOtp(request) {
    alertServices.showLoading();
    otpServices.aadhaarVerifyOtp(request).then((response) async {
      alertServices.hideLoading();
      alertServices.successToast(response['message_code']);
      aadhaar = [response];
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Aadhaar'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
          child: Column(
            children: [
              const SizedBox(height: 16),
              if (aadhaar.isEmpty) ...[
                const SizedBox(height: 75),
                Text(
                  "Aadhaar OTP sent your register mobile number.",
                  style: CustomTheme.subTittle1,
                ),
                const SizedBox(height: 16),
                OtpTextField(
                  autoFocus: false,
                  numberOfFields: 6,
                  borderColor: AppColors.primary,
                  enabledBorderColor: AppColors.primary,
                  focusedBorderColor: AppColors.primary,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  clearText: false,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  showFieldAsBox: true,
                  filled: false,
                  onCodeChanged: (String value) {
                    if (value.toString().trim().length == 6) {
                      FocusScope.of(context).unfocus();
                    }
                  },
                  handleControllers: (control) => {
                    for (int i = 0; i < otpCtrl.text.length; i++)
                      {
                        control[i]?.text = otpCtrl.text[i].toString(),
                      }
                  },
                  onSubmit: (String code) {
                    setState(() {
                      // buttonEnabled = code.length == 6;
                      otpCtrl.text = code;
                    });
                  }, // end onSubmit
                ),
                const SizedBox(height: 75),
                // TextFormWidget(
                //   title: 'Verify OTP',
                //   controller: otpCtrl,
                //   keyboardType: TextInputType.phone,
                //   maxLength: 10,
                //   required: false,
                //   prefixIcon: Icons.phone_iphone_outlined,
                //   onChanged: (String value) {
                //     if (value.toString().trim().length == 6) {
                //       FocusScope.of(context).unfocus();
                //     }
                //   },
                // ),
                // const SizedBox(height: 16),
                AppButtonWidget(
                  title: "Verify OTP",
                  onPressed: () {
                    var request = {
                      "otp": otpCtrl.text.toString(),
                      "client_id": clientId
                    };
                    verifyOtp(request);
                  },
                ),
                const SizedBox(height: 16),
              ],
              if (aadhaar.isNotEmpty) ...[
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              child: Image.memory(
                                base64Decode(
                                  aadhaar[0]['data']['profile_image'],
                                ),
                                height: 170,
                                width: 100,
                                fit: BoxFit.contain,
                              ),
                            ),
                            Container(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    aadhaar[0]['data']['full_name'].toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    aadhaar[0]['data']['care_of'].toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    aadhaar[0]['data']['dob'].toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    'Address: '
                                    '${aadhaar[0]['data']['address']['house'].toString()} '
                                    '${aadhaar[0]['data']['address']['street'].toString()} '
                                    '${aadhaar[0]['data']['address']['loc'].toString()} '
                                    '${aadhaar[0]['data']['address']['po'].toString()} '
                                    '${aadhaar[0]['data']['address']['vtc'].toString()} '
                                    '${aadhaar[0]['data']['address']['dist'].toString()} '
                                    '${aadhaar[0]['data']['address']['state'].toString()} '
                                    '${aadhaar[0]['data']['address']['country'].toString()}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AppButtonWidget(
                    title: "Confirm",
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onConfirm(aadhaar);
                    }),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
