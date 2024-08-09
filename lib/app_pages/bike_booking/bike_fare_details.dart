import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:driev/app_services/index.dart';
import 'package:driev/app_utils/app_widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import '../../app_storages/secure_storage.dart';
import '../../app_themes/app_colors.dart';
import '../../app_utils/app_loading/alert_services.dart';

import '../../app_utils/app_widgets/app_button.dart';
import '../../app_utils/app_widgets/app_outline_button.dart';
import 'widget/bike_fare_reserve_buttons.dart';
import 'widget/bike_fare_text_widget.dart';
import 'widget/fare_list_widget.dart';
import 'widget/main_card_widget.dart';

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
  VehicleService vehicleService = VehicleService();
  TextEditingController reserveTimeCtrl = TextEditingController();

  static SizedBox defaultHeight = const SizedBox(height: 25);
  double buttonHeight = 45;
  // VARIABLES
  List fareDetails = [];

  // BUTTON CONDITIONS
  bool isReserveClick = false;
  bool isOnCounter = false;
  bool enableChasingTime = false;

  // RESERVE VARIABLES
  List reserveTime = [
    {"mins": 5, "selected": false, "disabled": false},
    {"mins": 10, "selected": false, "disabled": false},
    {"mins": 15, "selected": false, "disabled": false},
  ];
  String reserveMins = "";

  // TIMER VARIABLES
  String formattedMinutes = "00";
  String formattedSeconds = "00";
  Timer? countdownTimer;

  // EXTEND BLOCK
  String blockId = "";
  @override
  void initState() {
    super.initState();
    String id = widget.stationDetails[0]['vehicleId'];
    getFareDetails(id); // GETTING BIKE FARE DETAILS
  }

  @override
  void dispose() {
    super.dispose();
    reserveTimeCtrl.dispose();
    stopCountdown();
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
    return PopScope(
      // canPop: false,
      // onPopInvoked: (didPop) {
      //   if (didPop) {
      //     return;
      //   }
      // },
      child: Scaffold(
        appBar: const AppBarWidget(),
        body: SingleChildScrollView(
          physics: const ScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
            child: Column(
              children: [
                if (fd.isNotEmpty) MainCardWidget(fd: fd, sd: sd),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Fare Details",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (fd.isNotEmpty) ...[
                  FareListWidget(fd: fd),
                ],
                const SizedBox(height: 16),

                /// BUTTON FUNCTIONS - BEFORE RESERVE
                if (!isOnCounter && !isReserveClick) ...[
                  defaultHeight,
                  if (fd.isNotEmpty)
                    AppButtonWidget(
                      height: buttonHeight,
                      title:
                          "Reserve Your Bike (₹ ${fd[0]['offer']['blockAmountPerMin']} per min)",
                      onPressed: () {
                        setState(() {
                          isReserveClick = true;
                        });
                      },
                    ),
                  defaultHeight,
                  OutlineButtonWidget(
                    height: buttonHeight,
                    onPressed: () {
                      scanToUnlock();
                    },
                    title: 'Scan to Unlock',
                  ),
                  const SizedBox(height: 10),
                ],

                /// BUTTON FUNCTIONS - AFTER RESERVE
                if (isReserveClick && !isOnCounter) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    // TODO: To change text to rich text
                    child: Text(
                      "Reserve Your Bike (₹${fd[0]['offer']['blockAmountPerMin'].toString()} per min)",
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontFamily: "Roboto",
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(reserveTime.length, (index) {
                      return BikeFareReserveButtons(
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
                        selected: reserveTime[index]['selected'],
                        title: '${reserveTime[index]['mins']}',
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  BikeFareTextWidget(
                    controller: reserveTimeCtrl,
                    onChanged: (value) {
                      setState(() {
                        for (var i in reserveTime) {
                          i['selected'] = false;
                        }
                        reserveMins = value.toString();
                        if (value.toString().length == 2) {
                          FocusScope.of(context).unfocus();
                        }
                        // reserveTimeCtrl.text = reserveMins;
                      });
                    },
                  ),
                  defaultHeight,
                  OutlineButtonWidget(
                    height: buttonHeight,
                    foregroundColor: AppColors.primary,
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      print("User Selected or entered Mins: $reserveMins");
                      checkCondition();
                      // setState(() {
                      //   isOnCounter = true;
                      // });
                    },
                    title: 'Proceed to reserve your bike',
                  ),
                  defaultHeight,
                  AppButtonWidget(
                    height: buttonHeight,
                    title: "Scan to Unlock",
                    onPressed: () {
                      scanToUnlock();
                    },
                  ),
                  const SizedBox(height: 10),
                ],

                /// BUTTON FUNCTIONS - ON COUNTER
                if (isOnCounter) ...[
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
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
                          color: Color(0xffE1FFE6),
                          width: 0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: Text(
                        "$formattedMinutes: $formattedSeconds Minute to Ride Time!",
                        style: TextStyle(
                          color: enableChasingTime
                              ? Colors.white
                              : AppColors.primary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  if (enableChasingTime) ...[
                    const Text("Chasing time?", style: TextStyle(fontSize: 18)),
                    const Text("Give your adventure a stylish extension!",
                        style: TextStyle(fontSize: 16)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      }
                                      reserveMins =
                                          reserveTime[index]['mins'].toString();
                                      reserveTimeCtrl.text = "";
                                      reserveTime[index]['selected'] = true;
                                    });
                                  },
                            style: ElevatedButton.styleFrom(
                              side: BorderSide(
                                color: reserveTime[index]['selected']
                                    ? AppColors.primary
                                    : const Color(0xffE1E1E1),
                                width: 1,
                              ),
                              backgroundColor: reserveTime[index]['selected']
                                  ? Colors.white
                                  : const Color(0xffF5F5F5),
                              foregroundColor: Colors.black,
                              textStyle: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 12),
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
                    OutlineButtonWidget(
                      foregroundColor: AppColors.primary,
                      height: buttonHeight,
                      onPressed: () {
                        setState(() {
                          for (var i in reserveTime) {
                            i['selected'] = false;
                          }
                        });

                        /// --- Extend Blocking
                        extendBikeBlocking();
                      },
                      title: 'Extend to reserve your bike',
                    ),
                  ],
                  const SizedBox(height: 16),
                  AppButtonWidget(
                    height: buttonHeight,
                    title: "Scan to Unlock",
                    onPressed: () {
                      scanToUnlock();
                    },
                  ),
                  const SizedBox(height: 10),
                ],
                const SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }

  apiBack() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: AlertDialog(
            backgroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: const Text("Confirm"),
            content: const Text(
                "Timer is Running...\nApp will redirect to home page?"),
            actions: [
              TextButton(
                child: const Text(
                  "No",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: const Text(
                  "Yes",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () async {
                  var mobile = await secureStorage.get("mobile");
                  alertServices.showLoading();
                  vehicleService.getBlockedRides(mobile).then((r) {
                    alertServices.hideLoading();
                    if (r != null) {
                      Navigator.pop(context);
                      if (r.isNotEmpty) {
                        Navigator.pushNamed(context, "extend_bike",
                            arguments: r);
                      } else {
                        Navigator.pushNamedAndRemoveUntil(
                            context, "home", (route) => false);
                      }
                    }
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// FUNCTIONALITY AND API CALLS
  checkCondition() async {
    if (reserveMins.isEmpty) {
      alertServices.errorToast("Please select/enter valid mins!");
    } else if (double.parse(reserveMins) > 60) {
      alertServices.errorToast("Please select/enter valid mins!");
    } else {
      bikeBlock();
    }
  }

  bikeBlock() {
    /// BLOCK BIKE API CALL
    Map<String, Object> params = {
      "contact": secureStorage.get("mobile").toString(),
      "vehicleId": fareDetails[0]['vehicleId'].toString(),
      "duration": reserveMins.toString()
    };
    alertServices.showLoading();
    bookingServices.blockBike(params).then((r2) async {
      alertServices.hideLoading();
      List res2 = [r2];
      if (res2[0]['key'].toString().contains("WALLET_ISSUE")) {
        alertServices.balanceAlert(context, res2[0]['message'].toString(),
            widget.stationDetails, "", []);
      } else if (res2[0]['key'].toString() != "null" &&
          res2[0]['message'].toString() != "null") {
        alertServices.vehicleAlert(context, res2[0]['message'].toString());
      } else {
        if (res2[0]['blockedTill'] != null) {
          debugPrint(" --- Bike Blocked --- ");
          print("blockBike Response ${jsonEncode(r2)}");
          setState(() {
            blockId = res2[0]['blockId'].toString();
            isOnCounter = true;
            reserveMins = "";
            enableChasingTime = false;
          });
          startCountdown(res2[0]['blockedTill'].toString());
        } else {
          String errMsg = "Something went wrong. Please try again in a bit.";
          alertServices.errorToast(errMsg);
        }
      }
    });
  }

  extendBikeBlocking() {
    print("reserveMins $reserveMins");
    if (reserveMins.isEmpty) {
      alertServices.errorToast("Please select mins!");
    } else {
      alertServices.showLoading();
      Map<String, Object> params = {
        "blockId": blockId.toString(),
        "duration": reserveMins.toString()
      };
      bookingServices.extendBlocking(params).then((res) {
        alertServices.hideLoading();
        print("extendBlocking Response -->  $res");
        List res2 = [res];
        if (res2[0]['key'].toString() == "WALLET_ISSUE") {
          alertServices.balanceAlert(context, res2[0]['message'].toString(),
              widget.stationDetails, "", []);
        } else if (res2[0]['key'].toString() == "VEHICLE_ISSUE") {
          alertServices.vehicleAlert(context, res2[0]['message'].toString());
        } else {
          if (res2[0]['blockedTill'] != null) {
            setState(() {
              enableChasingTime = false;
              reserveMins = "";
              reserveTimeCtrl.text = "";
            });
            stopCountdown();
            startCountdown(res2[0]['blockedTill'].toString());
          }
        }
      });
    }
  }

  startCountdown(String blockedTill) {
    DateTime blockedTime = DateTime.parse(blockedTill);
    Duration remainingTime = const Duration();
    Duration rt = const Duration();
    rt = blockedTime.difference(DateTime.now());
    int min = rt.inMinutes * 60;
    int sec = rt.inSeconds;
    int time = (min + sec);
    double percentage = time * 0.25;
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      // setState(() {
      remainingTime = blockedTime.difference(DateTime.now());
      int minutes = remainingTime.inMinutes % 60;
      int seconds = remainingTime.inSeconds % 60;
      formattedMinutes = minutes.toString().padLeft(2, '0');
      formattedSeconds = seconds.toString().padLeft(2, '0');
      print("Time Remaining: $formattedMinutes:$formattedSeconds");
      // ENABLE CHASING TIME
      int min = remainingTime.inMinutes * 60;
      int sec = remainingTime.inSeconds;
      int totalTime = (min + sec);
      if (int.parse(percentage.toStringAsFixed(0)) > totalTime) {
        enableChasingTime = true;
      }
      if ("$formattedMinutes:$formattedSeconds" == "00:00") {
        debugPrint("--- Timer Stopped ---");
        countdownTimer?.cancel();
        setState(() {
          isOnCounter = false;
        });
        // TODO: CHANGE NAVIGATION IN SELECT VEHICLE
        Navigator.pushNamed(context, "select_vehicle",
            arguments: widget.stationDetails[0]['homeData']);
      }
      // });

      setState(() {});
    });
  }

  stopCountdown() {
    if (countdownTimer?.isActive ?? false) {
      countdownTimer?.cancel();
    }
  }

  /// SCAN TO UNLOCK BIKE
  scanToUnlock() async {
    String campus = widget.stationDetails[0]['campus'].toString();
    String vehicleId = widget.stationDetails[0]['vehicleId'].toString();
    List arg = [
      {"campus": campus, "vehicleId": vehicleId}
    ];
    stopCountdown();
    Navigator.pushNamed(context, "scan_to_unlock", arguments: arg);
    // double balance = 0;
    // int selectedMin = 0;
    // double reserve = fareDetails[0]['offer']['blockAmountPerMin'];
    // List a =
    //     reserveTime.where((e) => e['selected'].toString() == "true").toList();
    // if (a.isNotEmpty) {
    //   selectedMin = a[0]['mins'];
    //   double amount = selectedMin * reserve;
    //   alertServices.showLoading();
    //   bookingServices.getWalletBalance(mobile).then((r) {
    //     balance = r['balance'];
    //     Map<String, Object> params = {
    //       "contact": secureStorage.get("mobile").toString(),
    //       "vehicleId": fareDetails[0]['vehicleId'].toString(),
    //       "duration": reserveMins.toString()
    //     };
    //     print("params $params");
    //     bookingServices.blockBike(params).then((r2) async {
    //       alertServices.hideLoading();
    //       if (amount > balance) {
    //         alertServices.insufficientBalanceAlert(context, "₹$balance",
    //             r2["message"], widget.stationDetails, "", []);
    //       } else {
    //         /// BALANCE AVAILABLE
    //         print("Block Response: ${jsonEncode(r2)}");
    //         String campus = widget.stationDetails[0]['campus'].toString();
    //         String vehicleId = widget.stationDetails[0]['vehicleId'].toString();
    //         List arg = [
    //           {
    //             "campus": campus,
    //             "vehicleId": vehicleId,
    //             // "stationDetails": r2,
    //           },
    //         ];
    //         Navigator.pushNamed(context, "scan_to_unlock", arguments: arg);
    //       }
    //     });
    //   });
    // } else {
    //   // double baseFare = fareDetails[0]['offer']['basePrice'];
    //   // double perMinPaisa = fareDetails[0]['offer']['perMinPaisa'];
    //   // double perKmPaisa = fareDetails[0]['offer']['perKmPaisa'];
    //   // double amount = baseFare + perKmPaisa + perMinPaisa;
    //   /// BALANCE AVAILABLE arguments: list['campusId'].toString()
    //   String campus = widget.stationDetails[0]['campus'].toString();
    //   String vehicleId = widget.stationDetails[0]['vehicleId'].toString();
    //   List arg = [
    //     {"campus": campus, "vehicleId": vehicleId}
    //   ];
    //   Navigator.pushNamed(context, "scan_to_unlock", arguments: arg);
    // }
  }
}
