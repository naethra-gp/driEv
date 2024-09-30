import 'dart:async';
import 'dart:ui';

import 'package:driev/app_services/index.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_tooltip/super_tooltip.dart';
import '../../app_config/app_constants.dart';
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

class _BikeFareDetailsState extends State<BikeFareDetails>
    with WidgetsBindingObserver {
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

  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isRunning = false;

  // EXTEND BLOCK
  String blockId = "";
  bool timerRunning = false;
  bool viaApi = false;
  bool viaApp = false;

  final SuperTooltipController controller = SuperTooltipController();

  @override
  void initState() {
    super.initState();
    String id = widget.stationDetails[0]['vehicleId'];
    getFareDetails(id); // GETTING BIKE FARE DETAILS
    viaApi = widget.stationDetails[0]['via'] == "api";
    viaApp = widget.stationDetails[0]['via'] == "app";
    if (viaApi) {
      isOnCounter = true;
      List block = widget.stationDetails[0]['data'];
      // print("Widget Data: ${block[0]['blockId']}");
      blockId = block[0]['blockId'].toString();
      stopCountdown();
      startCountdown(block[0]['blockedTill'].toString());
    }
    setState(() {});
  }

  /// FLOW - 1 [TIMER RUNNING]

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

  backButtonClick() async {
    await controller.hideTooltip();
    if (isOnCounter) {
      print("isOnCounter enable: $isOnCounter");
      apiBack();
    }
    if (!isOnCounter && viaApp) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    List fd = fareDetails;
    List sd = widget.stationDetails;
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        backButtonClick();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: Image.asset(Constants.backButton),
            onPressed: () {
              backButtonClick();
            },
          ),
          actions: [],
        ),
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
                  FareListWidget(fd: fd, controller: controller),
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
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(reserveTime.length, (index) {
                      return BikeFareReserveButtons(
                        onPressed: reserveTime[index]['disabled']
                            ? null
                            : () {
                                setState(() {
                                  FocusScope.of(context).unfocus();
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
                    onPressed: () async {
                      await controller.hideTooltip();
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
                  const SizedBox(height: 25),
                  blackButton("End Reservation"),
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

  Widget blackButton(title) {
    return SizedBox(
      width: double.infinity,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: () async {
          if (blockId.toString().isEmpty) {
            alertServices.errorToast("Invalid Block ID.");
          } else {
            await _showBackDialog(context);
          }
        },
        focusNode: FocusNode(skipTraversal: true),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          foregroundColor: Colors.white,
          backgroundColor: Colors.black,
          overlayColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          textStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        child: Text(
          title.toString(),
          style: const TextStyle(
            fontFamily: "Roboto",
            fontWeight: FontWeight.w600,
            fontSize: 16,
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
          setState(() {
            blockId = res2[0]['blockId'].toString();
            isOnCounter = true;
            reserveMins = "";
            enableChasingTime = false;
            isOnCounter = true;
          });
          // _onStartButtonPressed(res2[0]['blockedTill'].toString());
          startCountdown(res2[0]['blockedTill'].toString());
        } else {
          String errMsg = "Something went wrong. Please try again in a bit.";
          alertServices.errorToast(errMsg);
        }
      }
    });
  }

  extendBikeBlocking() {
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
              isOnCounter = true;
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
      remainingTime = blockedTime.difference(DateTime.now());
      int minutes = remainingTime.inMinutes % 60;
      int seconds = remainingTime.inSeconds % 60;
      formattedMinutes = minutes.toString().padLeft(2, '0');
      formattedSeconds = seconds.toString().padLeft(2, '0');
      int min = remainingTime.inMinutes * 60;
      int sec = remainingTime.inSeconds;
      int totalTime = (min + sec);
      if (int.parse(percentage.toStringAsFixed(0)) > totalTime) {
        enableChasingTime = true;
      }
      if ("$formattedMinutes:$formattedSeconds" == "00:00") {
        debugPrint("--- Timer Stopped ---");
        countdownTimer?.cancel();
        _showAlertDialog(context);
        setState(() {
          isOnCounter = false;
        });
        // Navigator.pushNamed(context, "home");
      }
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

    // List params = [
    //   {
    //     "campus": data[0]['stationName'].toString(),
    //     "distance": data[0]['distanceRange'].toString(),
    //     "vehicleId": data[0]['vehicleId'].toString(),
    //     "via": "api",
    //     "data": data
    //   }
    // ];
    // Navigator.pushNamedAndRemoveUntil(
    //   context,
    //   "bike_fare_details",
    //   arguments: {"query": params},
    //   (route) => false,
    // );

    if (isOnCounter) {}

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

  endReservation(String blockId) {
    if (blockId.toString().isEmpty) return false;
    alertServices.showLoading();
    bookingServices.releaseBlockedBike(blockId).then((res) {
      alertServices.hideLoading();
      alertServices.successToast(res['message'].toString());
      stopCountdown();
      if (viaApi) {
        Navigator.pushNamedAndRemoveUntil(context, "home", (route) => false);
      } else {
        Navigator.pop(context);
      }
    });
  }

  _showBackDialog(context) {
    return showDialog<bool>(
      barrierColor: Colors.black.withOpacity(0.5),
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          title: const Text(
            'Confirm',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: "Roboto",
            ),
          ),
          content: const Text(
            'Are you sure you want to end your reservation for the vehicle?.',
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontFamily: "Roboto-Bold",
              fontSize: 16,
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text(
                'No',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: "Roboto",
                ),
              ),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text(
                'Yes',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: "Roboto",
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                endReservation(blockId.toString());
              },
            ),
          ],
        );
      },
    );
  }

  _showAlertDialog(context) {
    return showDialog<bool>(
      barrierColor: Colors.black.withOpacity(0.5),
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          title: const Text(
            'Alert',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: "Roboto",
            ),
          ),
          content: const Text(
            'Your reservation for this vehicle has expired. You will now be returned to the home page.',
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontFamily: "Roboto-Bold",
              fontSize: 16,
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text(
                'OK',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: "Roboto",
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                if (viaApi) {
                  Navigator.pushNamed(context, "home");
                }
                if (viaApp) {
                  // TODO: CHANGE NAVIGATION IN SELECT VEHICLE
                  Navigator.pushNamed(
                    context,
                    "select_vehicle",
                    arguments: widget.stationDetails[0]['homeData'],
                  );
                }
                // Navigator.pushNamedAndRemoveUntil(
                //     context, "home", (route) => false);
              },
            ),
          ],
        );
      },
    );
  }

  loadTimer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String exp = prefs.getString('exp') ?? "";
    print("exp $exp");
    if (exp.toString().isNotEmpty) {
      String formattedDate3 =
          DateFormat('hh:mm:ss a').format(DateTime.parse(exp));
      print(formattedDate3);
      // setState(() {
      //   expireTime = formattedDate3.toString().padLeft(2, '0');
      // });
      var cd = DateTime.now();
      print("cd $cd");
      Duration difference = DateTime.parse(exp).difference(cd);
      int mins = difference.inMinutes;
      int sec = difference.inSeconds;
      print("mins $mins");
      print("sec $sec");
      setState(() {
        // timerCtrl.text = mins.toString();
        _remainingSeconds = sec;
        _isRunning = true;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
        if (_remainingSeconds > 0) {
          setState(() {
            _remainingSeconds--;
          });
          debugPrint('Remaining seconds: $_remainingSeconds');
        } else {
          timer.cancel();
          setState(() {
            _remainingSeconds = 0;
            _isRunning = false;
          });
        }
      });
    }
  }

  Future<void> _onStartButtonPressed(expTime) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isRunning = true;
      // _remainingSeconds = int.parse(timerCtrl.text) * 60;
    });

    int mins = int.parse("timerCtrl.text");
    DateTime now = DateTime.now();
    DateTime newTime = now.add(Duration(minutes: mins));
    String format = DateFormat('hh:mm:ss a').format(newTime);
    print("Format Date -> $format");
    setState(() {
      // expireTime = format.toString().padLeft(2, '0');
    });
    await prefs.setString('exp', newTime.toString());

    /// timer functions
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      debugPrint('Remaining seconds: $_remainingSeconds');
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      }
      if (_remainingSeconds.isNegative) {
        timer.cancel();
        setState(() {
          _remainingSeconds = 0;
          _isRunning = false;
        });
      }
    });
  }

  saveTimer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      // _remainingSeconds = int.parse(timerCtrl.text) * 60;
    });
    int mins = int.parse("timerCtrl.text");
    DateTime now = DateTime.now();
    DateTime newTime = now.add(Duration(minutes: mins));
    String format = DateFormat('hh:mm:ss a').format(newTime);
    print("Format Date -> $format");
    setState(() {
      // expireTime = format.toString().padLeft(2, '0');
    });
    await prefs.setString('exp', newTime.toString());
  }

  Future<void> _stopTimer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_timer!.isActive) {
      _timer?.cancel();
      await prefs.setInt('start_time', 0);
      setState(() {
        // expireTime = "";
        _remainingSeconds = 0;
        _isRunning = false;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // _stopTimer();
      // loadTimer();
      // The app is in the background or the user is leaving the app.
      print('App is paused');
    } else if (state == AppLifecycleState.resumed) {
      // The app is back in the foreground.
      print('App is resumed');
      // _stopTimer();
      // loadTimer();
      // _stopTimer();
      // loadTimer();
    } else if (state == AppLifecycleState.detached) {
      // The app is detached from the view, meaning it is about to be terminated.
      print('App is detached');
    }
  }
}
