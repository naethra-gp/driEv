import 'package:driev/app_config/app_config.dart';
import 'package:driev/app_themes/app_colors.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import '../../../app_utils/app_widgets/app_button.dart';
import 'login_controller.dart';

class LoginPage extends StatefulWidget {
  final dynamic mobileNumber;
  const LoginPage({super.key, required this.mobileNumber});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with LoginController {
  @override
  void initState() {
    super.initState();
    initStateController(widget.mobileNumber, setState);
  }

  @override
  void dispose() {
    super.dispose();
    dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: KeyboardActions(
          config: buildKeyboardActionsConfig(context),
          child: Stack(
            alignment: AlignmentDirectional.bottomStart,
            children: <Widget>[
              _buildBackgroundContainer(height),
              Positioned(
                height: getPositionedHeight(height),
                width: width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(padding: EdgeInsets.all(getTopPadding(height))),
                    _buildLogoSection(),
                    _buildHeaderSection(height),
                    _buildMobileInputSection(),
                    _buildBottomSection(context),
                    SizedBox(height: bottomSpacing),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundContainer(double height) {
    return Align(
      alignment: FractionalOffset.bottomCenter,
      child: Container(
        height: getContainerHeight(height),
        alignment: Alignment.bottomCenter,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          color: backgroundColor,
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Align(
      alignment: Alignment.topCenter,
      child: Image.asset(
        Constants.appLogo,
        fit: BoxFit.cover,
        height: logoSize,
        width: logoSize,
      ),
    );
  }

  Widget _buildHeaderSection(double height) {
    return Column(
      children: [
        SizedBox(height: getLogoSpacing(height)),
        Text(
          Constants.divein,
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        SizedBox(height: defaultSpacing),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: defaultPadding),
          child: Text(
            Constants.popin,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: subtitleFontSize,
              fontWeight: FontWeight.w500,
              color: subtitleColor,
            ),
          ),
        ),
        SizedBox(height: defaultPadding),
      ],
    );
  }

  Widget _buildMobileInputSection() {
    return Form(
      key: formKey,
      child: Align(
        alignment: Alignment.center,
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: defaultPadding),
            child: TextFormField(
              keyboardType: TextInputType.phone,
              maxLength: 10,
              autofocus: true,
              controller: mobileCtrl,
              focusNode: otpFocus,
              textAlignVertical: TextAlignVertical.center,
              style: TextStyle(fontSize: fontSize),
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                counterText: "",
                isDense: false,
                contentPadding: const EdgeInsets.only(bottom: 4),
                hintText: "Enter your mobile number",
                hintStyle: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.normal,
                  letterSpacing: 0,
                  color: hintColor,
                ),
                errorStyle: TextStyle(
                  color: errorColor,
                ),
                prefixIcon: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '+91',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide(
                    width: 1,
                    color: borderColor,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide(
                    width: 1,
                    color: borderColor,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(
                    width: 1,
                    color: AppColors.primary,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(
                    width: 1,
                    color: errorColor,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(
                    width: 1,
                    color: errorColor,
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
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    return Expanded(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildApiToggleSection(),
            SizedBox(height: defaultSpacing),
            _buildSendOtpButton(),
            SizedBox(height: defaultSpacing),
            _buildTermsAndConditions(),
          ],
        ),
      ),
    );
  }

  Widget _buildApiToggleSection() {
    return Column(
      children: [
        Center(
          child: Text(
            "Current API: ${isStaging ? "Staging (community-test.driev.bike)" : "Live (iot.driev.bike)"}",
          ),
        ),
        Switch(
          activeColor: AppColors.white,
          trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
          activeTrackColor: AppColors.primary,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: Colors.grey.shade500,
          splashRadius: switchSplashRadius,
          value: isStaging,
          onChanged: (value) => toggleApiMode(value, setState),
        ),
      ],
    );
  }

  Widget _buildSendOtpButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AppButtonWidget(
        title: 'Send OTP',
        onPressed: isMobileValid && !isLoading
            ? () => submitLogin(context, setState)
            : null,
      ),
    );
  }

  Widget _buildTermsAndConditions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: <TextSpan>[
            TextSpan(
              text: Constants.termCon1,
              style: TextStyle(color: textColor),
            ),
            TextSpan(
              text: Constants.termCon2,
              style: const TextStyle(color: Colors.blue),
              recognizer: TapGestureRecognizer()..onTap = () => openBrowser(),
            ),
          ],
        ),
      ),
    );
  }
}
