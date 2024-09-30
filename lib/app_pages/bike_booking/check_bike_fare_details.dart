import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_tooltip/super_tooltip.dart';

import '../../app_config/app_constants.dart';
import '../../app_config/app_strings.dart';
import '../../app_services/index.dart';
import '../../app_storages/secure_storage.dart';
import '../../app_themes/app_colors.dart';
import '../../app_utils/app_loading/alert_services.dart';
import '../../app_utils/app_widgets/app_button.dart';
import '../../app_utils/app_widgets/app_outline_button.dart';
import 'widget/bike_fare_reserve_buttons.dart';
import 'widget/bike_fare_text_widget.dart';
import 'widget/fare_list_widget.dart';
import 'widget/main_card_widget.dart';

class CheckBikeFareDetails extends StatefulWidget {
  final List data;
  const CheckBikeFareDetails({super.key, required this.data});

  @override
  State<CheckBikeFareDetails> createState() => _CheckBikeFareDetailsState();
}

class _CheckBikeFareDetailsState extends State<CheckBikeFareDetails>
    with WidgetsBindingObserver {
  AlertServices alertServices = AlertServices();
  SecureStorage secureStorage = SecureStorage();
  BookingServices bookingServices = BookingServices();
  VehicleService vehicleService = VehicleService();
  TextEditingController reserveTimeCtrl = TextEditingController();

  static SizedBox defaultHeight = const SizedBox(height: 25);
  double buttonHeight = 45;
  List fareDetails = [];

  // RESERVE VARIABLES
  List reserveTime = [
    {"mins": 5, "selected": false, "disabled": false},
    {"mins": 10, "selected": false, "disabled": false},
    {"mins": 15, "selected": false, "disabled": false},
  ];
  String reserveMins = "";

  // BUTTON CONDITIONS
  bool isReserveClick = false;
  bool isOnCounter = false;
  bool enableChasingTime = false;

  // TIMER VARIABLES
  String formattedMinutes = "00";
  String formattedSeconds = "00";
  Timer? countdownTimer;

  int _remainingSeconds = 0;

  // EXTEND BLOCK
  String blockId = "";
  bool timerRunning = false;
  bool viaApi = false; // DATA FETCH FROM BLOCK BIKE IN HOME SCREEN
  bool viaApp = false; // NORMAL APP FLOW
  final SuperTooltipController controller = SuperTooltipController();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    List data = widget.data;
    String id = data[0]['vehicleId']; // GET VEHICLE ID
    getFareDetails(id); // BIKE FARE DETAILS FUNCTION
    viaApi = data[0]['via'] == "api";
    viaApp = data[0]['via'] == "app";
    if (viaApi) {
      isOnCounter = true;
      List block = widget.data[0]['data'];
      blockId = block[0]['blockId'].toString();
      _stopTimer();
      startCountdown();
    }
    setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    reserveTimeCtrl.dispose();
    countdownTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      log('App is paused');
      _stopTimer();
      startCountdown();
    } else if (state == AppLifecycleState.resumed) {
      log('App is resumed');
      _stopTimer();
      startCountdown();
    } else if (state == AppLifecycleState.detached) {
      log('App is detached');
      _stopTimer();
      startCountdown();
    }
  }

  // GET BIKE FARE DETAILS - FETCH FROM API CALL
  getFareDetails(String id) {
    alertServices.showLoading();
    bookingServices.getFare(id).then((response) async {
      fareDetails = [response];
      alertServices.hideLoading();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    List fd = fareDetails;
    List sd = widget.data;
    int minutes = _remainingSeconds ~/ 60;
    int seconds = _remainingSeconds % 60;
    // buttonHeight = MediaQuery.of(context).size.height * 0.055;
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
          actions: const [],
        ),
        body: SingleChildScrollView(
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
                if (fd.isNotEmpty) ...[
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
                ],
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
                    for (var i in reserveTime) {
                      i['selected'] = false;
                    }
                    reserveMins = value.toString();
                    if (value.toString().length == 2) {
                      FocusScope.of(context).unfocus();
                    }
                    setState(() {});
                  },
                ),
                defaultHeight,
                OutlineButtonWidget(
                  height: buttonHeight,
                  foregroundColor: AppColors.primary,
                  onPressed: () {
                    log("Reserved Mins $reserveMins");
                    FocusScope.of(context).unfocus();
                    checkCondition();
                  },
                  title: AppStrings.proceedButtonLabel,
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
                    child: getTimeCount(minutes, seconds),
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
                  if (fd.isNotEmpty)
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
    );
  }

  /// FUNCTIONALITY AND API CALLS
  checkCondition() async {
    if (reserveMins.isEmpty) {
      alertServices.errorToast(AppStrings.validMinsError);
      return;
    }
    blockBikeApiCall();
  }

  /// BIKE BLOCKING API CALL
  blockBikeApiCall() {
    Map<String, Object> params = {
      "contact": secureStorage.get("mobile").toString(),
      "vehicleId": fareDetails[0]['vehicleId'].toString(),
      "duration": reserveMins.toString(),
    };
    alertServices.showLoading();
    debugPrint(" --- Bike Block API Calling --- ");
    bookingServices.blockBike(params).then((r2) async {
      alertServices.hideLoading();
      debugPrint(" --- Bike Block API Response --- ");
      List res2 = [r2];
      debugPrint(" ------------------------------- ");
      debugPrint('Bike Block API Response -> ${jsonEncode(res2)}');
      debugPrint(" ------------------------------- ");
      responseConditions(res2);
    });
  }

  responseConditions(List res2) async {
    debugPrint(" --- Response Conditions --- ");
    String key = res2[0]['key'].toString();
    String msg = res2[0]['message'].toString();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (key.contains("WALLET_ISSUE")) {
      alertServices.balanceAlert(context, msg, widget.data, "", []);
    } else if (key != "null" && msg != "null") {
      alertServices.vehicleAlert(context, msg);
    } else {
      debugPrint("BLOCK TILL TIME ---> ${res2[0]['blockedTill'].toString()}");
      var blockedTill = res2[0]['blockedTill'];
      var blockedOn = res2[0]['blockedOn'];
      String id = res2[0]['blockId'].toString();
      if (blockedTill != null) {
        blockId = id.toString();
        isOnCounter = true;
        reserveMins = "";
        enableChasingTime = false;
        prefs.setString(Constants.blockedTill, blockedTill.toString());
        prefs.setString(Constants.blockedOn, blockedOn.toString());
        prefs.setString(Constants.blockId, blockId);
        setState(() {});
        startCountdown();
      } else {
        String errMsg = "Something went wrong. Please try again in a bit.";
        alertServices.errorToast(errMsg);
      }
    }
  }

  startCountdown() async {
    log("--- START TIMER ---");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String blockTime = prefs.getString(Constants.blockedTill) ?? "";
    String blockedOn = prefs.getString(Constants.blockedOn) ?? "";
    if (blockTime.toString().isEmpty) return;
    // DATE PARSE AND CONVERT STRING TO TIME
    DateTime blockedTime = DateTime.parse(blockTime);
    // GET CURRENT TIME
    DateTime currentTime = DateTime.now();
    Duration difference = blockedTime.difference(currentTime);
    int sec = difference.inSeconds;
    setState(() {
      _remainingSeconds = sec;
      isOnCounter = true;
    });

    /// CALCULATING PERCENTAGE
    DateTime bo = DateTime.parse(blockedOn);
    Duration diff = blockedTime.difference(bo);
    double percentage = diff.inSeconds * 0.25;

    countdownTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
        if (int.parse(percentage.toStringAsFixed(0)) > _remainingSeconds) {
          enableChasingTime = true;
        }
      } else {
        countdownTimer?.cancel();
        prefs.setString(Constants.blockedTill, "");
        setState(() {
          reserveMins = "";
          _remainingSeconds = 0;
          isOnCounter = false;
          enableChasingTime = false;
        });
        _showAlertDialog(context);
      }
    });
  }

  _showAlertDialog(context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              title: const Text(
                'Alert',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: "Roboto-Bold",
                ),
              ),
              content: const Text(
                'The timer has stopped. The app will now redirect to the Home Page.',
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontFamily: "Roboto-Bold",
                  fontSize: 14,
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
                    // if (viaApi) {
                    //   Navigator.pushNamed(context, "home");
                    // }
                    // if (viaApp) {
                    //   // TODO: CHANGE NAVIGATION IN SELECT VEHICLE
                    //   Navigator.pushNamed(
                    //     context,
                    //     "select_vehicle",
                    //     arguments: widget.data[0]['homeData'],
                    //   );
                    // }
                    Navigator.pushNamedAndRemoveUntil(
                        context, "home", (route) => false);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _stopTimer() async {
    // if (countdownTimer!.isActive) {
    countdownTimer?.cancel();
    setState(() {
      _remainingSeconds = 0;
      isOnCounter = false;
      enableChasingTime = false;
    });
    debugPrint("--- TIMER STOPPED ---");
    // }
  }

  /// EXTEND BIKE BLOCKING
  extendBikeBlocking() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int remain = _remainingSeconds;
    if (reserveMins.isEmpty) {
      alertServices.errorToast("Please select a valid chasing time!");
    } else if ((remain + int.parse(reserveMins) * 60) > 3600) {
      alertServices.errorToast(AppStrings.bikeBlockMaxError);
    } else {
      if (blockId.toString() == "") {
        alertServices.errorToast("Invalid Block ID");
        return;
      }
      alertServices.showLoading();
      Map<String, Object> params = {
        "blockId": blockId.toString(),
        "duration": reserveMins.toString(),
      };
      bookingServices.extendBlocking(params).then((res) {
        alertServices.hideLoading();
        debugPrint("Extend Blocking API Response --> $res");
        List res2 = [res];
        String key = res2[0]['key'].toString();
        String msg = res2[0]['message'].toString();
        if (key.contains("WALLET_ISSUE")) {
          alertServices.balanceAlert(context, msg, widget.data, "", []);
        } else if (key != "null" && msg != "null") {
          alertServices.vehicleAlert(context, msg);
        } else {
          var blockedTill = res2[0]['blockedTill'];
          var blockedOn = res2[0]['blockedOn'];
          if (blockedTill != null) {
            setState(() {
              enableChasingTime = false;
              reserveMins = "";
              reserveTimeCtrl.text = "";
              isOnCounter = false;
            });
            prefs.setString(Constants.blockedTill, blockedTill.toString());
            prefs.setString(Constants.blockedOn, blockedOn.toString());
            _stopTimer();
            startCountdown();
          }
        }
      });
    }
  }

  /// END RESERVATION FUNCTIONS
  Widget blackButton(title) {
    return SizedBox(
      width: double.infinity,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: () async {
          if (blockId.toString().isEmpty) {
            alertServices.errorToast(AppStrings.invalidBlockId);
          } else {
            await _showEndReserveConfirm(context);
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

  _showEndReserveConfirm(context) {
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
            'Are you to end your reservation for the vehicle?',
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
                  color: Colors.redAccent,
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
                _endReservation(blockId.toString());
              },
            ),
          ],
        );
      },
    );
  }

  _endReservation(String blockId) {
    if (blockId.toString().isEmpty) return false;
    alertServices.showLoading();
    bookingServices.releaseBlockedBike(blockId).then((res) async {
      alertServices.hideLoading();
      alertServices.successToast(res['message'].toString());
      _stopTimer();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(Constants.blockedTill, "");
      if (viaApi) {
        Navigator.pushNamedAndRemoveUntil(context, "home", (route) => false);
      } else {
        Navigator.pop(context);
      }
    });
  }

  /// SCAN TO UNLOCK BIKE
  scanToUnlock() async {
    if (isOnCounter) {
      var mobile = await secureStorage.get("mobile");
      getBlockRides(mobile);
      return;
    }
    String campus = widget.data[0]['campus'].toString();
    String vehicleId = widget.data[0]['vehicleId'].toString();
    // widget.data[0]['via'] = isOnCounter ? "api" : "app";
    List arg = [
      {
        "campus": campus,
        "vehicleId": vehicleId,
        "data": widget.data,
      }
    ];
    //TODO: uncomment;
    _stopTimer();
    Navigator.pushNamed(context, "scan_to_unlock", arguments: arg);
  }

  getBlockRides(String mobile) {
    alertServices.showLoading("get block details");
    String campus = widget.data[0]['campus'].toString();
    String vehicleId = widget.data[0]['vehicleId'].toString();
    widget.data[0]['via'] = "api";
    vehicleService.getBlockedRides(mobile).then((r) {
      alertServices.hideLoading();
      // {
      //   "campus": data[0]['stationName'].toString(),
      // "distance": data[0]['distanceRange'].toString(),
      // "vehicleId": data[0]['vehicleId'].toString(),
      // "via": "api",
      // "data": data
      // }
      List params = [
        {
          "campus": widget.data[0]['campus'].toString(),
          "distance": r[0]['distanceRange'].toString(),
          "vehicleId": widget.data[0]['vehicleId'].toString(),
          "via": "api",
          "data": r
        }
      ];
      if (r != null) {
        if (r.isNotEmpty) {
          List arg = [
            {
              "campus": campus,
              "vehicleId": vehicleId,
              "data": params,
            }
          ];
          //TODO: uncomment;
          _stopTimer();
          Navigator.pushNamed(context, "scan_to_unlock", arguments: arg);
        }
      }
    });
  }

  getTimeCount(minutes, seconds) {
    String mins = minutes.toString().padLeft(2, '0');
    String secs = seconds.toString().padLeft(2, '0');

    if (mins != "00") {
      return Text(
        "$mins:$secs Minutes to Ride Time!",
        style: TextStyle(
          color: enableChasingTime ? Colors.white : AppColors.primary,
          fontSize: 14,
        ),
      );
    } else {
      return Text(
        "$mins:$secs Seconds to Ride Time!",
        style: TextStyle(
          color: enableChasingTime ? Colors.white : AppColors.primary,
          fontSize: 14,
        ),
      );
    }
  }

  backButtonClick() async {
    await controller.hideTooltip();
    if (isOnCounter) {
      apiBack();
    }
    if (!isOnCounter && viaApp) {
      Navigator.pushReplacementNamed(context, "select_vehicle",
          arguments: widget.data[0]['homeData']);
    }
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
                "The timer is running...\nThe app will redirect to the home page."),
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
}
