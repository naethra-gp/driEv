import 'dart:async';

import 'package:driev/app_themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app_services/index.dart';
import '../../../app_themes/custom_theme.dart';
import '../../../app_utils/app_loading/alert_services.dart';

class AadhaarFormField extends StatefulWidget {
  final String title;
  final bool required;
  final bool readOnly;
  final TextEditingController controller;
  final FormFieldValidator? validator;
  final ValueChanged<String>? onChanged;
  final IconData? prefixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final Function(bool, String) otpSent;

  const AadhaarFormField({
    super.key,
    required this.title,
    required this.required,
    required this.controller,
    this.validator,
    this.onChanged,
    this.prefixIcon,
    this.inputFormatters,
    this.maxLength,
    required this.otpSent,
    required this.readOnly,
  });

  @override
  State<AadhaarFormField> createState() => _AadhaarFormFieldState();
}

class _AadhaarFormFieldState extends State<AadhaarFormField> {
  String verifyButton = "Send OTP";
  AlertServices as = AlertServices();

  bool buttonEnabled = false;
  int _otpExpireTime = 30;
  Timer? _timer;
  String clientId = "";

  @override
  void dispose() {
    widget.controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          maxLength: widget.maxLength,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: widget.validator,
          readOnly: widget.readOnly,
          onChanged: widget.onChanged,
          inputFormatters: widget.inputFormatters,
          style: CustomTheme.formFieldStyle,
          decoration: InputDecoration(
            counterText: "",
            hintText: widget.title,
            filled: widget.readOnly,
            fillColor: Colors.grey[200],
            errorStyle: const TextStyle(
              color: Colors.redAccent,
              fontSize: 12,
              fontWeight: FontWeight.normal,
            ),
            hintStyle: CustomTheme.formHintStyle,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: const BorderSide(color: Color(0xffD2D2D2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xffD2D2D2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xffD2D2D2)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.only(left: 15.0),
            isDense: false,
            suffixIcon: TextButton(
              onPressed: () {
                String? aadhaar =
                    widget.controller.text.toString().replaceAll(" ", "");
                if (aadhaar.length != 12) {
                  as.errorToast("Please enter valid aadhaar!");
                } else {
                  if (verifyButton == "Send OTP" ||
                      verifyButton == "Resend" && !widget.readOnly) {
                    sentOtp();
                  } else {}
                }
              },
              child: Text(
                widget.readOnly ? "Verified" : verifyButton,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  sentOtp() {
    print("--- Sent OTP pressed ---");
    AlertServices alertServices = AlertServices();
    OtpServices otpServices = OtpServices();
    alertServices.showLoading();
    String aadhaarNo = widget.controller.text.toString().replaceAll(" ", "");
    print(aadhaarNo);
    otpServices.aadhaarSentOtp({"id_number": aadhaarNo}).then((response) async {
      alertServices.hideLoading();
      print("aadhaar 1st response -> $response");
      if (response != null) {
        print("aadhaar response -> $response");
        alertServices.successToast(response['message']);
        clientId = response['data']['client_id'].toString();
        widget.otpSent(true, clientId);
        _timer?.cancel();
        _otpExpireTime = 30;
        startTimer();
        setState(() {});
      } else {
        widget.otpSent(false, "");
      }
    });
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_otpExpireTime > 0) {
          _otpExpireTime--;
          verifyButton = "$_otpExpireTime s";
        } else {
          verifyButton = "Resend";
          _timer?.cancel();
        }
      });
    });
  }

  String getFormattedTime(int seconds) {
    int remainingSeconds = seconds % 60;
    return remainingSeconds.toString().padLeft(2, '0');
  }
}
