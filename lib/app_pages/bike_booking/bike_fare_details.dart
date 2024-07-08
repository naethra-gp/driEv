import 'dart:async';
import 'dart:convert';

import 'package:driev/app_utils/app_widgets/app_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import '../../app_config/app_constants.dart';
import '../../app_storages/secure_storage.dart';
import '../../app_themes/app_colors.dart';
import '../../app_utils/app_loading/alert_services.dart';
import 'package:driev/app_services/booking_services.dart';

import '../registration_page/widget/reg_text_form_widget.dart';
import 'widget/fare_details_widget.dart';

class BikeFareDetails extends StatefulWidget {
  final List stationDetails;

  const BikeFareDetails({super.key, required this.stationDetails});

  @override
  State<BikeFareDetails> createState() => _BikeFareDetailsState();
}

class _BikeFareDetailsState extends State<BikeFareDetails> {
  AlertServices alertServices = AlertServices();
  SecureStorage secureStorage = SecureStorage();
  BookingServices bookingServices = BookingServices();
  String notes =
      "Battery swap after the given range might be chargeable and depends on the availability of assets & resources";
  List fareDetails = [];
  List reserveTime = [
    {"mins": 5, "selected": false, "disabled": false},
    {"mins": 10, "selected": false, "disabled": false},
    {"mins": 15, "selected": false, "disabled": false},
  ];

  bool isReserve = false;
  bool isReserveReady = false;
  TextEditingController reserveTimeCtrl = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  bool isInputDisabled = false;
  bool enableChasingTime = false;
  bool isReservedDone = false;
  String reserveMins = "";
  String blockId = "";

  int _start = 0;
  late Timer _timer;
  String formattedMinutes = "";
  String formattedSeconds = "";
  Timer? countdownTimer;

  @override
  void initState() {
    String id = widget.stationDetails[0]['vehicleId'];
    getFareDetails(id);
    super.initState();
  }

  @override
  void dispose() {
    _timeController.dispose();
    _timer.cancel();
    super.dispose();
  }

  String get _formattedTime {
    int minutes = _start ~/ 60;
    int seconds = _start % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  getFareDetails(String id) {
    alertServices.showLoading();
    bookingServices.getFare(id).then((response) async {
      alertServices.hideLoading();
      setState(() {
        fareDetails = [response];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    List fd = fareDetails;
    List sd = widget.stationDetails;
    print("fd ${jsonEncode(fd)}");
    return Scaffold(
        appBar: AppBar(
          surfaceTintColor: Colors.white,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Image.asset(Constants.backButton),
            onPressed: () async {
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              if (fd.isNotEmpty) ...[
                IntrinsicHeight(
                  child: Card(
                    surfaceTintColor: Colors.transparent,
                    color: const Color(0xffF5F5F5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  //  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: 'dri',
                                              style: heading(Colors.black),
                                            ),
                                            TextSpan(
                                              text: 'EV ',
                                              style: heading(AppColors.primary),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${fd[0]['planType']} ${fd[0]['vehicleId']}',
                                      style: heading(Colors.black),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 15),
                                Row(
                                  children: [
                                    Image.asset(
                                      "assets/img/slider_icon.png",
                                      height: 18,
                                      width: 13,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      "${sd[0]['campus']} (${sd[0]['distance']}km)",
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  "Estimated Range",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: "Poppins",
                                    color: Color(0xff626262),
                                  ),
                                ),
                                Text(
                                  "${fd[0]['estimatedRange'] ?? "0"} km",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontFamily: "Poppins",
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // const SizedBox(height: 40),
                                fd[0]['imageUrl'] != null
                                    ? Image.network(
                                        fd[0]['imageUrl'].toString(),
                                        // Replace with your image URL
                                        width: 200,
                                        height: 130,
                                        fit: BoxFit.contain,
                                      )
                                    : Image.asset(
                                        "assets/img/bike.png",
                                        fit: BoxFit.fitWidth,
                                        // width: 210,
                                        // height: 20,
                                        // height: 130,
                                      ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 5),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: <TextSpan>[
                    const TextSpan(
                      text: "* ",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 10,
                      ),
                    ),
                    TextSpan(
                      text: notes,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xff7E7E7E),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Fare Details",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    // letterSpacing: 0.15,
                  ),
                ),
              ),
              if (fd.isNotEmpty) ...[
                const SizedBox(height: 8.0),
                FareDetailsWidget(
                  title: "Base fare",
                  info: true,
                  fareDetails: fd,
                  price: fd[0]['offer']['basePrice'].toString(),
                ),
                const SizedBox(height: 8),
                FareDetailsWidget(
                  title: "Ride charge per minute",
                  info: false,
                  fareDetails: fd,
                  price: (fd[0]['offer']['perMinPaisa'] / 100).toString(),
                ),
                const SizedBox(height: 8),
                FareDetailsWidget(
                  title: "Ride charge per km",
                  info: false,
                  fareDetails: fd,
                  price: (fd[0]['offer']['perKmPaisa'] / 100).toString(),
                ),
                const SizedBox(height: 10),
                if (!isReservedDone) ...[
                  if (isReserve) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      // TODO: To change text to rich text
                      child: Text(
                        "Reserve Your Bike (₹${fd[0]['offer']['blockAmountPerMin'].toString()} per min)",
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          // letterSpacing: 0.15,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(reserveTime.length, (index) {
                        return SizedBox(
                          height: MediaQuery.sizeOf(context).height / 16.8,
                          child: ElevatedButton(
                            onPressed: reserveTime[index]['disabled']
                                ? null
                                : () {
                                    setState(() {
                                      for (var i in reserveTime) {
                                        i['selected'] = false;
                                      }
                                      reserveMins =
                                          reserveTime[index]['mins'].toString();
                                      reserveTimeCtrl.text = "";
                                      reserveTime[index]['selected'] = true;
                                    });
                                  },
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              textStyle: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.normal,
                                fontSize: 16,
                              ),
                              foregroundColor: Colors.black,
                              backgroundColor: reserveTime[index]['selected']
                                  ? Colors.white
                                  : const Color(0xffF5F5F5),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                              animationDuration: const Duration(seconds: 1),
                              splashFactory: InkRipple.splashFactory,
                              side: BorderSide(
                                color: reserveTime[index]['selected']
                                    ? AppColors.primary
                                    : const Color(0xFFE1E1E1),
                                width: 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              '${reserveTime[index]['mins']} mins',
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    TextFormWidget(
                      title: 'Enter Manually',
                      controller: reserveTimeCtrl,
                      required: true,
                      decoration: InputDecoration(
                        hintText: "Enter Manually",
                        fillColor: Colors.grey[200],
                        counterText: "",
                        errorStyle: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                        hintStyle: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Color(0xffD2D2D2)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Color(0xffD2D2D2)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Color(0xffD2D2D2)),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.redAccent),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Color(0xffD2D2D2)),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.redAccent),
                        ),
                        contentPadding: const EdgeInsets.only(left: 20),
                        isDense: false,
                      ),
                      maxLength: 2,
                      readOnly: isInputDisabled,
                      prefixIcon: Icons.account_circle_outlined,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      onChanged: (String value) {
                        setState(() {
                          for (var i in reserveTime) {
                            i['selected'] = false;
                          }
                          reserveMins = value.toString();
                          reserveTimeCtrl.text = reserveMins;
                        });
                      },
                      validator: (value) {
                        if (value.toString().isNotEmpty) {
                          if (int.parse(value) > 60) {
                            return "Only allowed 60 Mins.";
                          }
                          if (int.parse(value) == 0) {
                            return "Invalid Time";
                          }
                        }
                        return null;
                      },
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(
                          RegExp('[0-9]'),
                        ),
                      ],
                    ),
                  ] else ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height / 16.8,
                      child: AppButtonWidget(
                        title:
                            "Reserve Your Bike (₹${fd[0]['offer']['blockAmountPerMin'].toString()} per min)",
                        onPressed: () {
                          setState(() {
                            isReserve = true;
                            isReserveReady = true;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: MediaQuery.sizeOf(context).height / 16.8,
                      child: OutlinedButton(
                        onPressed: () {
                          scanToUnlock();
                        },
                        style: OutlinedButton.styleFrom(
                          textStyle: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.white,
                          side: const BorderSide(
                              color: AppColors.primary, width: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text("Scan to Unlock"),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ] else ...[
                  /// isReservedDone
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: MediaQuery.sizeOf(context).height / 16.8,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        textStyle: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                        elevation: 0,
                        foregroundColor: Colors.white,
                        backgroundColor: enableChasingTime
                            ? const Color(0xffFB8F80)
                            : const Color(0xffE1FFE6),
                        side: const BorderSide(
                            color: Color(0xffE1FFE6), width: 0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: Text(
                        "$formattedMinutes:$formattedSeconds Minute to Ride Time!",
                        // "$_formattedTime Minute to Ride Time!",
                        style: TextStyle(
                            color: enableChasingTime
                                ? Colors.white
                                : AppColors.primary,
                            fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (enableChasingTime) ...[
                    const Text(
                      "Chasing time?",
                      style: TextStyle(fontSize: 18),
                    ),
                    // const SizedBox(height: 16),
                    const Text(
                      "Give your adventure a stylish extension!",
                      style: TextStyle(fontSize: 16),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(reserveTime.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: reserveTime[index]['disabled']
                                ? null
                                : () {
                                    setState(() {
                                      for (var i in reserveTime) {
                                        i['selected'] = false;
                                        // i['disabled'] = true;
                                      }
                                      reserveMins =
                                          reserveTime[index]['mins'].toString();
                                      reserveTimeCtrl.text = "";
                                      reserveTime[index]['selected'] = true;
                                    });
                                  },
                            style: ElevatedButton.styleFrom(
                              textStyle: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 13),
                              foregroundColor: Colors.black,
                              backgroundColor: Colors.white,
                              disabledBackgroundColor: reserveTime[index]
                                      ['selected']
                                  ? Colors.white
                                  : const Color(0xffF5F5F5),
                              disabledForegroundColor: Colors.black,
                              animationDuration: const Duration(seconds: 1),
                              splashFactory: InkRipple.splashFactory,
                              side: BorderSide(
                                color: reserveTime[index]['selected']
                                    ? AppColors.primary
                                    : Colors.grey,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text('${reserveTime[index]['mins']} mins'),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 4),

                    Center(
                      child: Text(
                          "(₹${fd[0]['offer']['blockAmountPerMin'].toString()} per min)"),
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      height: MediaQuery.sizeOf(context).height / 16.8,
                      child: ElevatedButton(
                        onPressed: () {
                          /// --- Start
                          extendBlocking();
                        },
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
                          "Extend to reserve your bike",
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    height: MediaQuery.sizeOf(context).height / 16.8,
                    child: ElevatedButton(
                      onPressed: () {
                        scanToUnlock();
                      },
                      style: ElevatedButton.styleFrom(
                        textStyle: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                        foregroundColor: Colors.white,
                        backgroundColor: AppColors.primary,
                        side: const BorderSide(
                            color: AppColors.primary, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: const Text("Scan to Unlock"),
                    ),
                  ),
                ],
                const SizedBox(height: 15),
                if (isReserveReady && !isReservedDone) ...[
                  SizedBox(
                    width: double.infinity,
                    height: MediaQuery.sizeOf(context).height / 16.8,
                    child: ElevatedButton(
                      onPressed: () {
                        /// --- Start
                        reserveBike();
                      },
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
                        "Proceed to reserve your bike",
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: MediaQuery.sizeOf(context).height / 16.8,
                    child: ElevatedButton(
                      onPressed: () {
                        scanToUnlock();
                      },
                      style: ElevatedButton.styleFrom(
                        textStyle: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                        foregroundColor: Colors.white,
                        backgroundColor: AppColors.primary,
                        side: const BorderSide(
                            color: AppColors.primary, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: const Text("Scan to Unlock"),
                    ),
                  ),
                ],
                const SizedBox(height: 25),
              ],
            ],
          ),
        )));
  }

  TextStyle heading(Color color) {
    return TextStyle(
      fontFamily: "Poppins",
      fontWeight: FontWeight.bold,
      color: color,
      fontSize: 16,
    );
  }

  reserveBike() async {
    double balance = 0;
    String mobile = await secureStorage.get("mobile");
    double reserve = fareDetails[0]['offer']['blockAmountPerMin'];
    if (reserveMins.isEmpty) {
      alertServices.errorToast("Please select/enter valid mins!");
    } else {
      alertServices.showLoading();
      double amount = double.parse(reserveMins) * reserve;
      print("Reserve Amount -> $amount");
      bookingServices.getWalletBalance(mobile).then((r) {
        balance = r['balance'];
        print("Available Balance -> $balance");
        Map<String, Object> params = {
          "contact": secureStorage.get("mobile").toString(),
          "vehicleId": fareDetails[0]['vehicleId'].toString(),
          "duration": reserveMins.toString()
        };
        print("params $params");
        bookingServices.blockBike(params).then((r2) async {
          alertServices.hideLoading();
          if (amount > balance) {
            alertServices.insufficientBalanceAlert(context, "₹$balance",
                r2["message"], widget.stationDetails, "", []);
          } else {
            // alertServices.showLoading();
            print("blockBike --> $r2");
            if (r2 != null) {
              setState(() {
                blockId = r2['blockId'].toString();
                enableChasingTime = false;
                _start = int.parse(reserveMins.toString()) * 60;
                isReservedDone = true;
              });
              var time1 = DateTime.parse(r2['blockedOn'].toString());
              var time2 = DateTime.parse(r2['blockedTill'].toString());
              print(DateFormat.jm()
                  .format(DateTime.parse(r2['blockedOn'].toString())));
              print(DateFormat.jm()
                  .format(DateTime.parse(r2['blockedTill'].toString())));
              Duration difference = time2.difference(time1);
              print("difference $difference");
              countDownTime(r2['blockedTill'].toString());
              _startTimer();
            }
          }
        });
      });
    }
    // List a =
    //     reserveTime.where((e) => e['selected'].toString() == "true").toList();
    // print("a $a");
    // String b = reserveTimeCtrl.text.toString();
    // if (b.isNotEmpty) {
    //   // selectedMin = a[0]['mins'];
    //   double amount = double.parse(b) * reserve;
    //   bookingServices.getWalletBalance(mobile).then((r) {
    //     alertServices.hideLoading();
    //     balance = r['balance'];
    //     if (amount > balance) {
    //       alertServices.insufficientBalanceAlert(context, balance.toString());
    //     } else {
    //       if (reserveMins.isEmpty) {
    //         alertServices.errorToast("Invalid Time!!!");
    //       } else {
    //         alertServices.showLoading();
    //         Map<String, Object> params = {
    //           "contact": secureStorage.get("mobile").toString(),
    //           "vehicleId": fareDetails[0]['vehicleId'].toString(),
    //           "duration": reserveMins.toString()
    //         };
    //         print("params $params");
    //         bookingServices.blockBike(params).then((r) {
    //           alertServices.hideLoading();
    //           if (r != null) {
    //             setState(() {
    //               blockId = r['blockId'].toString();
    //               enableChasingTime = false;
    //               _start = int.parse(reserveMins.toString()) * 60;
    //               isReservedDone = true;
    //             });
    //             _startTimer();
    //           }
    //         });
    //       }
    //     }
    //   });
    // }
  }

  void _startTimer() {
    double percentage = _start * 0.20;
    print("percentage $percentage");
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_start > 0) {
          _start--;
        } else {
          _timer.cancel();
        }
        if (percentage > _start) {
          enableChasingTime = true;
        }
        print("_start $_start");
        print("enableChasingTime $enableChasingTime");
      });
    });
  }

  countDownTime(String blockedTill) {
    _cancelTimer();
    DateTime targetDateTime = DateTime.parse(blockedTill);
    print("targetDateTime $targetDateTime");
    Duration remainingTime = const Duration();
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {
        remainingTime = targetDateTime.difference(DateTime.now());
        print("remainingTime $remainingTime");
        int minutes = remainingTime.inMinutes % 60;
        int seconds = remainingTime.inSeconds % 60;
        formattedMinutes = minutes.toString().padLeft(2, '0');
        formattedSeconds = seconds.toString().padLeft(2, '0');
        print("'Time remaining: $formattedMinutes:$formattedSeconds'");
        // if (remainingTime.isNegative) {
        //   countdownTimer?.cancel();
        // }
        if ("$formattedMinutes:$formattedSeconds" == "00:00") {
          print("--- Timer Stopped ---");
          countdownTimer?.cancel();
          Navigator.pushReplacementNamed(context, "error_bike");
        }
      });
    });
  }

  void _cancelTimer() {
    if (countdownTimer != null) {
      countdownTimer!.cancel();
      countdownTimer = null;
    }
  }

  extendBlocking() {
    print("--- extendBlocking ---");
    if (reserveMins.isEmpty) {
      alertServices.errorToast("Invalid Time!!!");
    } else {
      alertServices.showLoading();
      Map<String, Object> params = {
        "blockId": blockId.toString(),
        "duration": reserveMins.toString()
      };
      print("params $params");
      bookingServices.extendBlocking(params).then((r) {
        alertServices.hideLoading();
        print("extendBlocking Response -->  $r");
        if (r != null) {
          setState(() {
            // blockId = r['blockId'].toString();
            enableChasingTime = false;
            int blockStart = int.parse(reserveMins.toString()) * 60;
            print("blockStart $blockStart");
            // _start = int.parse(reserveMins.toString()) * 60;
            _start = blockStart + _start;
            print("_start --> $_start");
            isReservedDone = true;
            // do {
            //   countdownTimer.cancel();
            // } while (countdownTimer.isActive);

            countDownTime(r['blockedTill'].toString());
          });
          do {
            _timer.cancel();
          } while (_timer.isActive);
          _startTimer();
        }
      });
    }
  }

  scanToUnlock() async {
    countdownTimer?.cancel();
    alertServices.showLoading();
    String mobile = await secureStorage.get("mobile");
    double balance = 0;
    int selectedMin = 0;
    double reserve = fareDetails[0]['offer']['blockAmountPerMin'];
    List a =
        reserveTime.where((e) => e['selected'].toString() == "true").toList();
    if (a.isNotEmpty) {
      selectedMin = a[0]['mins'];
      double amount = selectedMin * reserve;
      bookingServices.getWalletBalance(mobile).then((r) {
        balance = r['balance'];
        Map<String, Object> params = {
          "contact": secureStorage.get("mobile").toString(),
          "vehicleId": fareDetails[0]['vehicleId'].toString(),
          "duration": reserveMins.toString()
        };
        print("params $params");
        bookingServices.blockBike(params).then((r2) async {
          alertServices.hideLoading();
          if (amount > balance) {
            alertServices.insufficientBalanceAlert(context, "₹$balance",
                r2["message"], widget.stationDetails, "", []);
          } else {
            /// BALANCE AVAILABLE
            String campus = widget.stationDetails[0]['campus'].toString();
            String vehicleId = widget.stationDetails[0]['vehicleId'].toString();
            List arg = [
              {
                "campus": campus,
                "vehicleId": vehicleId,
              },
            ];
            print("arg $arg");
            Navigator.pushNamed(context, "scan_to_unlock", arguments: arg);
          }
        });
      });
    } else {
      double baseFare = fareDetails[0]['offer']['basePrice'];
      double perMinPaisa = fareDetails[0]['offer']['perMinPaisa'];
      double perKmPaisa = fareDetails[0]['offer']['perKmPaisa'];
      double amount = baseFare + perKmPaisa + perMinPaisa;
      bookingServices.getWalletBalance(mobile).then((r) {
        balance = r['balance'];
        Map<String, Object> params = {
          "contact": secureStorage.get("mobile").toString(),
          "vehicleId": fareDetails[0]['vehicleId'].toString(),
          "duration": reserveMins.toString()
        };
        print("params $params");
        bookingServices.blockBike(params).then((r2) async {
          alertServices.hideLoading();

          if (amount > balance) {
            alertServices.insufficientBalanceAlert(context, "₹$balance",
                r2["message"], widget.stationDetails, "", []);
          } else {
            /// BALANCE AVAILABLE arguments: list['campusId'].toString()
            String campus = widget.stationDetails[0]['campus'].toString();
            String vehicleId = widget.stationDetails[0]['vehicleId'].toString();
            List arg = [
              {
                "campus": campus,
                "vehicleId": vehicleId,
              },
            ];
            Navigator.pushNamed(context, "scan_to_unlock", arguments: arg);
          }
        });
      });
    }
  }
}
