import 'package:driev/app_themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:otp_autofill/otp_autofill.dart';

import '../../../app_services/index.dart';
import '../../../app_storages/secure_storage.dart';
import '../../../app_themes/custom_theme.dart';
import '../../../app_utils/app_loading/alert_services.dart';

class AadhaarOtpFormField extends StatefulWidget {
  final String title;
  final String clientId;
  final bool required;
  final FormFieldValidator? validator;
  final ValueChanged<String>? onChanged;
  final IconData? prefixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final Function(List) onConfirm;

  const AadhaarOtpFormField({
    super.key,
    required this.title,
    required this.required,
    this.validator,
    this.onChanged,
    this.prefixIcon,
    this.inputFormatters,
    this.maxLength,
    required this.clientId,
    required this.onConfirm,
  });

  @override
  State<AadhaarOtpFormField> createState() => _AadhaarOtpFormFieldState();
}

class _AadhaarOtpFormFieldState extends State<AadhaarOtpFormField> {
  AlertServices alertServices = AlertServices();
  OtpServices otpServices = OtpServices();
  SecureStorage secureStorage = SecureStorage();
  OTPInteractor otpInteractor = OTPInteractor();
  List aadhaar = [];
  TextEditingController otpCtrl = TextEditingController();

  @override
  void initState() {
    _initInteractor();
    super.initState();
  }

  @override
  void dispose() {
    otpCtrl.dispose();
    super.dispose();
  }

  Future<void> _initInteractor() async {
    otpInteractor = OTPInteractor();
    await otpInteractor.getAppSignature();
    otpCtrl = OTPTextEditController(codeLength: 6, otpInteractor: otpInteractor)
      ..startListenUserConsent(
        (code) {
          final exp = RegExp(r'(\d{6})');
          return exp.stringMatch(code ?? '') ?? '';
        },
      );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: otpCtrl,
          maxLength: widget.maxLength,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: widget.validator,
          onChanged: widget.onChanged,
          inputFormatters: widget.inputFormatters,
          style: CustomTheme.formFieldStyle,
          decoration: InputDecoration(
            counterText: "",
            hintText: widget.title,
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
            contentPadding: const EdgeInsets.only(left: 15),
            isDense: true,
            suffixIcon: TextButton(
              onPressed: () {
                var request = {
                  "otp": otpCtrl.text.toString(),
                  "client_id": widget.clientId,
                };
                verifyOtp(request);
              },
              child: const Text(
                "Verify OTP",
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  verifyOtp(request) {
    alertServices.showLoading();
    otpServices.aadhaarVerifyOtp(request).then((response) async {
      alertServices.hideLoading();
      if (response != null) {
        alertServices.successToast(response['message_code']);
        aadhaar = [response];
        widget.onConfirm(aadhaar);
        setState(() {});
      } else {}
    });
  }
}
