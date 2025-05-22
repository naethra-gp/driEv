import 'dart:io';
import 'package:driev/app_dialogs/widgets/delete_user_widget.dart';
import 'package:driev/app_utils/app_widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';

import '../../app_dialogs/widgets/block_user_content.dart';
import '../../app_dialogs/widgets/kyc_block_widget.dart';
import '../../app_dialogs/widgets/kyc_hold_widget.dart';
import '../../app_dialogs/widgets/user_subscription_widget.dart';
import 'widgets/balance_alert_widget.dart';
import 'widgets/vehicle_alert.dart';

class AlertServices {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // Toast configuration
  static const _toastDuration = Toast.LENGTH_LONG;
  static const _toastGravity = ToastGravity.BOTTOM;
  static const _toastIosDuration = 1;
  static const _toastFontSize = 12.0;

  // Dialog configuration
  static const _dialogBorderRadius = 15.0;
  static const _dialogBarrierOpacity = 0.5;
  static const _bottomSheetBarrierOpacity = 0.8;

  // Loading configuration
  static const _loadingRadius = 100.0;
  static const _loadingIndicatorSize = 80.0;

  Future<void> showLoading([String? title]) async {
    EasyLoading.instance
      ..loadingStyle = EasyLoadingStyle.light
      ..toastPosition = EasyLoadingToastPosition.center
      ..animationStyle = EasyLoadingAnimationStyle.scale
      ..radius = _loadingRadius;

    return await EasyLoading.show(
      maskType: EasyLoadingMaskType.black,
      dismissOnTap: false,
      indicator: Lottie.asset(
        'assets/loading/loading1.json',
        height: _loadingIndicatorSize,
        width: _loadingIndicatorSize,
      ),
    );
  }

  Future<void> hideLoading() async => await EasyLoading.dismiss();

  void errorToast(String message) => _showToast(
        message,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );

  void successToast(String message) => _showToast(
        message,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

  void toast(String message) => _showToast(message);

  void _showToast(
    String message, {
    Color? backgroundColor,
    Color? textColor,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: _toastDuration,
      gravity: _toastGravity,
      timeInSecForIosWeb: _toastIosDuration,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: _toastFontSize,
    );
  }

  Future<bool?> _showBackDialog(BuildContext context) {
    return showDialog<bool>(
      barrierColor: Colors.black.withOpacity(_dialogBarrierOpacity),
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text(
          'Exit App',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: "Roboto",
          ),
        ),
        content: const Text(
          'Are you sure you want to exit app?',
          style: TextStyle(
            fontWeight: FontWeight.normal,
            fontFamily: "Roboto-Bold",
            fontSize: 16,
          ),
        ),
        actions: <Widget>[
          _buildDialogButton(
              context, 'Cancel', () => Navigator.pop(context, false)),
          _buildDialogButton(
            context,
            'Exit',
            () {
              if (Platform.isAndroid) {
                SystemNavigator.pop();
              } else if (Platform.isIOS) {
                exit(0);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDialogButton(
      BuildContext context, String text, VoidCallback onPressed) {
    return TextButton(
      style: TextButton.styleFrom(
        textStyle: Theme.of(context).textTheme.labelLarge,
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: "Roboto",
        ),
      ),
    );
  }

  Future<void> holdKycAlert(BuildContext context) =>
      kycMainModel(context, const KycHoldWidget());

  Future<void> deleteUserAlert(
          BuildContext context, String msg, String? status) =>
      kycMainModel(context, DeleteUserWidget(message: msg, status: status));

  Future<void> rejectKycAlert(BuildContext context) =>
      kycMainModel(context, const KycBlockWidget());

  Future<void> blockedKycAlert(BuildContext context, String reason) =>
      kycMainModel(context, const BlockUserContent());

  Future<void> subscriptionAlert(BuildContext context, String reason) =>
      kycMainModel(context, const UserSubscriptionWidget());

  Future<void> kycMainModel(BuildContext context, Widget child) {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(_dialogBorderRadius)),
      ),
      isDismissible: false,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: false,
      backgroundColor: Colors.white,
      barrierColor: Colors.black.withOpacity(_bottomSheetBarrierOpacity),
      builder: (context) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          final bool shouldPop = await _showBackDialog(context) ?? false;
          if (context.mounted && shouldPop) {
            Navigator.pop(context);
          }
        },
        child: child,
      ),
    );
  }

  Future<void> balanceAlert(
    BuildContext context,
    dynamic message,
    List stationDetails,
    String rideID,
    List scanEndRideId,
  ) {
    return showModalBottomSheet(
      context: context,
      barrierColor: Colors.black87,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: false,
      builder: (context) => BalanceAlertWidget(
        message: message,
        stationDetails: stationDetails,
        rideID: rideID,
        scanEndRideId: scanEndRideId,
      ),
    );
  }

  Future<void> vehicleAlert(BuildContext context, String message) {
    return showModalBottomSheet(
      context: context,
      barrierColor: Colors.black87,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: false,
      builder: (context) => VehicleAlert(message: message),
    );
  }

  Future<void> insufficientBalanceAlert(
    BuildContext context,
    String balance,
    String balSub,
    List stationDetails,
    String rideID,
    List scanEndRideId,
  ) {
    final size = MediaQuery.of(context).size;
    return showModalBottomSheet(
      context: context,
      barrierColor: Colors.black87,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: false,
      builder: (context) => _buildInsufficientBalanceContent(
        context,
        size,
        balSub,
        stationDetails,
        rideID,
        scanEndRideId,
      ),
    );
  }

  Widget _buildInsufficientBalanceContent(
    BuildContext context,
    Size size,
    String balSub,
    List stationDetails,
    String rideID,
    List scanEndRideId,
  ) {
    return SizedBox(
      height: size.height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: size.height / 6 - 70,
            child: Container(
              height: size.height,
              width: size.width,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
            ),
          ),
          Positioned(
            top: size.height / 7.5 - 70,
            child: Column(
              children: [
                _buildCloseButton(context),
                const SizedBox(height: 25),
                _buildOopsImage(),
                const SizedBox(height: 10),
                _buildOopsText(),
                const SizedBox(height: 18),
                _buildBalanceSubText(size.width, balSub),
                const SizedBox(height: 30),
                _buildTopUpButton(
                    context, size.width, stationDetails, rideID, scanEndRideId),
                const SizedBox(height: 25),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 50,
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.green,
        ),
        child: IconButton(
          icon: const Icon(Icons.close),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  Widget _buildOopsImage() {
    return Image.asset(
      "assets/img/oops.png",
      height: 60,
      width: 60,
    );
  }

  Widget _buildOopsText() {
    return const Text(
      "Oops!",
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Color(0xff2c2c2c),
        fontSize: 30,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildBalanceSubText(double width, String balSub) {
    return SizedBox(
      width: width * 0.9,
      child: Text(
        balSub,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.visible,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildTopUpButton(
    BuildContext context,
    double width,
    List stationDetails,
    String rideID,
    List scanEndRideId,
  ) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        width: width - 25,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: AppButtonWidget(
            title: 'Top Up Now',
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(
                context,
                "add_more_fund",
                arguments: {
                  "stationDetails": stationDetails,
                  "rideId": rideID,
                  "rideID": scanEndRideId
                },
              );
            },
            height: 45,
          ),
        ),
      ),
    );
  }
}
