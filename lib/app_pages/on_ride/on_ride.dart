import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:driev/app_services/booking_services.dart';
import 'package:driev/app_storages/secure_storage.dart';
import 'package:driev/app_themes/app_colors.dart';
import 'package:driev/app_utils/app_loading/alert_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class OnRide extends StatefulWidget {
  final String rideId;
  const OnRide({super.key, required this.rideId});

  @override
  State<OnRide> createState() => _OnRideState();
}

class _OnRideState extends State<OnRide> {
  AlertServices alertServices = AlertServices();
  BookingServices bookingServices = BookingServices();
  SecureStorage secureStorage = SecureStorage();

  late GoogleMapController mapController;
  List rideDetails = [];
  LatLng? currentLocation;
  String currentDistrict = "";
  double availableBalance = 0;
  Timer? countdownTimer;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  final Set<Marker> _markers = {};

  @override
  void dispose() {
    // TODO: implement dispose
    if (countdownTimer != null) {
      countdownTimer!.cancel();
      countdownTimer = null;
    }
    super.dispose();
  }

  @override
  void initState() {
    print("Ride ID --> ${widget.rideId}");
    _getUserLocation();
    getBalance();
    // countdownTimer = Timer.periodic(const Duration(minutes: 1), (Timer t) {
    getRideDetails(widget.rideId);
    // });
    super.initState();
  }

  getRideDetails(String id) {
    bookingServices.getRideDetails(id).then((r) {
      if (r != null) {
        setState(() {
          rideDetails = [r];
        });
        if (r['status'].toString() == "On Ride") {
          countdownTimer =
              Timer.periodic(const Duration(minutes: 1), (Timer t) {
            getRideDetails(widget.rideId);
          });
        }
        print("remainingRange ${r['remainingRange']}");
      }
    });
  }

  _getUserLocation() async {
    try {
      Position position = await GeolocatorPlatform.instance.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.reduced,
        ),
      );
      BitmapDescriptor customIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/img/map_user_icon.png',
      );
      print("${position.latitude} ${position.longitude}");
      setState(() async {
        currentLocation = LatLng(position.latitude, position.longitude);
        _markers.add(
          Marker(
            markerId: const MarkerId('currentLocation'),
            position: currentLocation!,
            icon: customIcon,
          ),
        );
        List<Placemark> placeMark = await placemarkFromCoordinates(
            position.latitude, position.longitude);
        Placemark place = placeMark[0];
        currentDistrict = place.locality!;
      });
    } catch (e) {
      // alertServices.errorToast("Location Issue");
      // customerLocation = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: currentLocation == null
            ? const Center(
                child: Text("Loading Map..."),
              )
            : Stack(
                children: [
                  GoogleMap(
                    onMapCreated: _onMapCreated,
                    markers: _markers,
                    zoomControlsEnabled: true,
                    initialCameraPosition: CameraPosition(
                      target: currentLocation!,
                      zoom: 15,
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 15,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(context, "profile");
                          },
                          child: CachedNetworkImage(
                            width: 41,
                            height: 41,
                            imageUrl: "selfieUrl",
                            errorWidget: (context, url, error) => Image.asset(
                              "assets/img/profile_logo.png",
                              width: 41,
                              height: 41,
                              fit: BoxFit.cover,
                            ),
                            imageBuilder: (context, imageProvider) => Container(
                              decoration: BoxDecoration(
                                // shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Container(
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xffF5F5F5),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xffD9D9D9),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // const SizedBox(width: 20),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Current Location - $currentDistrict",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Container(
                                height: 40,
                                width: 2, // Adjust width as needed
                                color:
                                    Colors.grey[300], // Adjust color as needed
                              ),
                              const SizedBox(width: 5),
                              Image.asset(
                                "assets/img/wallet.png",
                                height: 20,
                                width: 20,
                              ),
                              const SizedBox(width: 5),
                              if (rideDetails.isNotEmpty)
                                Text(
                                  "\u{20B9}${availableBalance.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    // fontSize: width / 30,
                                    fontWeight: FontWeight.bold,
                                    color: getColor(availableBalance),
                                  ),
                                  // style: CustomTheme.termStyle1red,
                                ),
                              const SizedBox(width: 5),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (rideDetails.isNotEmpty) ...[
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(15.0),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(25),
                            topRight: Radius.circular(25),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 5.0,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Card(
                              surfaceTintColor: const Color(0xffF5F5F5),
                              color: const Color(0xffF5F5F5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        RichText(
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
                                            TextSpan(
                                              text:
                                                  "${rideDetails[0]['planType'].toString()}-${rideDetails[0]['vehicleId'].toString()}",
                                              // '${fd[0]['planType']}-${fd[0]['vehicleId']}',
                                              style: heading(Colors.black),
                                            ),
                                          ],
                                        )),
                                        // const SizedBox(height: 15),
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
                                          "${rideDetails[0]['remainingRange']} KM",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontFamily: "Poppins",
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        const Icon(
                                            LineAwesome.battery_full_solid),
                                        const Text(
                                          "100%",
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontFamily: "Poppins",
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: GestureDetector(
                                            onTap: () {
                                              needHelpAlert(context);
                                              print("ontap");
                                            },
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Container(
                                                width: 25,
                                                height: 25,
                                                decoration: const BoxDecoration(
                                                  color: Colors.green,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Center(
                                                  child: Icon(
                                                    Icons.headset_mic_outlined,
                                                    color: Colors.white,
                                                    size: 15,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: Image.asset(
                                            "assets/img/bike.png",
                                            fit: BoxFit.contain,
                                            width: 180,
                                            // height: 130,
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 25.0),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.speed_outlined,
                                          color: AppColors.primary,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          '${rideDetails[0]['totalKm']} km',
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    const Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      child: Text(
                                        'Ride Distance',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Color(0xff7E7E7E),
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.timer_outlined,
                                          color: AppColors.primary,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          "${rideDetails[0]['duration']}",
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    const Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      child: Text(
                                        'Ride Duration',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Color(0xff7E7E7E),
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Divider(),
                            const SizedBox(height: 25.0),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () {
                                  countdownTimer!.cancel();
                                  List params = [
                                    {
                                      "rideId": widget.rideId.toString(),
                                      "scanCode": rideDetails[0]['scanCode'],
                                    }
                                  ];
                                  print(params);
                                  Navigator.pushNamed(
                                    context,
                                    "scan_to_end_ride",
                                    arguments: params,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('End Ride'),
                              ),
                            ),
                            const SizedBox(height: 20.0),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.red,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'You can end your ride at the KIIT station only',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5.0),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }

  TextStyle heading(Color color) {
    return TextStyle(
      fontFamily: "Poppins",
      fontWeight: FontWeight.bold,
      color: color,
      fontSize: 18,
    );
  }

  getColor(double value) {
    if (value < 350) {
      return Colors.redAccent;
    } else {
      return AppColors.primary;
    }
  }

  needHelpAlert(BuildContext context) {
    // showModalBottomSheet(
    //   context: context,
    //   // isDismissible: true,
    //   enableDrag: true,
    //   backgroundColor: Colors.white,
    //   barrierColor: Colors.black.withOpacity(.80),
    //   shape: const RoundedRectangleBorder(
    //     borderRadius: BorderRadius.vertical(top: Radius.circular(21)),
    //   ),
    //   builder: (BuildContext context) {
    //     return Padding(
    //       padding: const EdgeInsets.symmetric(horizontal: 15),
    //       child: SizedBox(
    //         height: 380,
    //         child: Column(
    //           children: [
    //             const SizedBox(height: 50),
    //             Align(
    //               alignment: Alignment.center,
    //               child: Image.asset(
    //                 "assets/img/question_mark.png",
    //                 height: 50,
    //                 width: 50,
    //               ),
    //             ),
    //             const SizedBox(height: 10),
    //             const Text(
    //               "Need Help?",
    //               style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
    //             ),
    //             const SizedBox(height: 25),
    //             Padding(
    //               padding: const EdgeInsets.symmetric(horizontal: 50),
    //               child: Column(
    //                 children: [
    //                   ElevatedButton(
    //                       onPressed: () async {
    //                         var contact = "+919439099990";
    //                         var androidUrl =
    //                             "whatsapp://send?phone=$contact&text=Hi, I need some help";
    //                         var iosUrl =
    //                             "https://wa.me/$contact?text=${Uri.parse('Hi, I need some help')}";
    //                         try {
    //                           if (Platform.isIOS) {
    //                             await launchUrl(Uri.parse(iosUrl));
    //                           } else {
    //                             await launchUrl(Uri.parse(androidUrl));
    //                           }
    //                         } on Exception {
    //                           EasyLoading.showError(
    //                               'WhatsApp is not installed.');
    //                         }
    //                       },
    //                       style: ElevatedButton.styleFrom(
    //                         textStyle: const TextStyle(
    //                           color: Colors.black,
    //                           fontWeight: FontWeight.w500,
    //                           fontSize: 16,
    //                         ),
    //                         elevation: 0,
    //                         foregroundColor: Colors.black,
    //                         backgroundColor: Colors.white,
    //                         side: const BorderSide(
    //                             color: Color(0xffC7C7C7), width: 1),
    //                         shape: RoundedRectangleBorder(
    //                           borderRadius: BorderRadius.circular(50),
    //                         ),
    //                       ),
    //                       child: const Row(
    //                         mainAxisAlignment: MainAxisAlignment.center,
    //                         crossAxisAlignment: CrossAxisAlignment.center,
    //                         children: [
    //                           Icon(
    //                             LineAwesome.whatsapp,
    //                             color: AppColors.primary,
    //                           ),
    //                           SizedBox(width: 10),
    //                           Text(
    //                             "Whatsapp Us",
    //                             textAlign: TextAlign.center,
    //                             style: TextStyle(
    //                               fontWeight: FontWeight.normal,
    //                               color: Color(0xff626262),
    //                             ),
    //                           ),
    //                         ],
    //                       )),
    //                   const SizedBox(height: 16),
    //                   ElevatedButton(
    //                       onPressed: () async {
    //                         // var contact = "+919439099990";
    //                         // const tel= $contact;
    //                         final Uri smsLaunchUri =
    //                             Uri(scheme: 'tel', path: "+919439099990");
    //                         await launchUrl(smsLaunchUri);
    //                       },
    //                       style: ElevatedButton.styleFrom(
    //                         textStyle: const TextStyle(
    //                           color: Colors.black,
    //                           fontWeight: FontWeight.w500,
    //                           fontSize: 16,
    //                         ),
    //                         elevation: 0,
    //                         foregroundColor: Colors.black,
    //                         backgroundColor: Colors.white,
    //                         side: const BorderSide(
    //                             color: Color(0xffC7C7C7), width: 1),
    //                         shape: RoundedRectangleBorder(
    //                           borderRadius: BorderRadius.circular(50),
    //                         ),
    //                       ),
    //                       child: const Row(
    //                         mainAxisAlignment: MainAxisAlignment.center,
    //                         crossAxisAlignment: CrossAxisAlignment.center,
    //                         children: [
    //                           Icon(
    //                             Icons.phone_callback_outlined,
    //                             color: AppColors.primary,
    //                           ),
    //                           SizedBox(width: 10),
    //                           Text(
    //                             "Call Us",
    //                             textAlign: TextAlign.center,
    //                             style: TextStyle(
    //                               fontWeight: FontWeight.normal,
    //                               color: Color(0xff626262),
    //                             ),
    //                           ),
    //                         ],
    //                       )),
    //                   const SizedBox(height: 16),
    //                   ElevatedButton(
    //                       onPressed: () async {
    //                         // var url = 'mailto:info@driev.bike';
    //                         // if (await canLaunch(url)) {
    //                         //   await launch(url);
    //                         // } else {
    //                         //   throw 'Could not launch $url';
    //                         // }
    //                         final Uri smsLaunchUri =
    //                             Uri(scheme: 'mailto', path: "info@driev.bike");
    //                         await launchUrl(smsLaunchUri);
    //                       },
    //                       style: ElevatedButton.styleFrom(
    //                         textStyle: const TextStyle(
    //                           color: Colors.black,
    //                           fontWeight: FontWeight.w500,
    //                           fontSize: 16,
    //                         ),
    //                         elevation: 0,
    //                         foregroundColor: Colors.black,
    //                         backgroundColor: Colors.white,
    //                         side: const BorderSide(
    //                             color: Color(0xffC7C7C7), width: 1),
    //                         shape: RoundedRectangleBorder(
    //                           borderRadius: BorderRadius.circular(50),
    //                         ),
    //                       ),
    //                       child: const Row(
    //                         mainAxisAlignment: MainAxisAlignment.center,
    //                         crossAxisAlignment: CrossAxisAlignment.center,
    //                         children: [
    //                           Icon(
    //                             Icons.mark_email_read_outlined,
    //                             color: AppColors.primary,
    //                           ),
    //                           SizedBox(width: 10),
    //                           Text(
    //                             "Mail Us",
    //                             textAlign: TextAlign.center,
    //                             style: TextStyle(
    //                               fontWeight: FontWeight.normal,
    //                               color: Color(0xff626262),
    //                             ),
    //                           ),
    //                         ],
    //                       )),
    //                 ],
    //               ),
    //             ),
    //             const SizedBox(height: 10),
    //           ],
    //         ),
    //       ),
    //     );
    //   },
    // );
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return showModalBottomSheet(
      context: context,
      barrierColor: Colors.black87,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: false,
      builder: (context) {
        return SizedBox(
          height: height / 2,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Positioned(
                top: height / 5.5 - 100,
                child: Container(
                  height: height,
                  width: width,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: height / 6.6 - 100,
                child: Column(
                  children: <Widget>[
                    SizedBox(
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
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        right: 50,
                        left: 50,
                        top: 25,
                        bottom: 20,
                      ),
                      child: Image.asset(
                        "assets/img/question_mark.png",
                        height: 60,
                        width: 60,
                      ),
                    ),
                    const Text(
                      "Need Help?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xff2c2c2c),
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Column(
                        children: [
                          SizedBox(
                            width: 200,
                            height: 40,
                            child: ElevatedButton(
                                onPressed: () async {
                                  var contact = "+919439099990";
                                  var androidUrl =
                                      "whatsapp://send?phone=$contact&text=Hi, I need some help";
                                  var iosUrl =
                                      "https://wa.me/$contact?text=${Uri.parse('Hi, I need some help')}";
                                  try {
                                    if (Platform.isIOS) {
                                      await launchUrl(Uri.parse(iosUrl));
                                    } else {
                                      await launchUrl(Uri.parse(androidUrl));
                                    }
                                  } on Exception {
                                    EasyLoading.showError(
                                        'WhatsApp is not installed.');
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  textStyle: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                  elevation: 0,
                                  foregroundColor: Colors.black,
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(
                                      color: Color(0xffC7C7C7), width: 1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      LineAwesome.whatsapp,
                                      color: AppColors.primary,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "Whatsapp Us",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Color(0xff626262),
                                      ),
                                    ),
                                  ],
                                )),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: 200,
                            height: 40,
                            child: ElevatedButton(
                                onPressed: () async {
                                  final Uri smsLaunchUri =
                                  Uri(scheme: 'tel', path: "+919439099990");
                                  await launchUrl(smsLaunchUri);
                                },
                                style: ElevatedButton.styleFrom(
                                  textStyle: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                  elevation: 0,
                                  foregroundColor: Colors.black,
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(
                                      color: Color(0xffC7C7C7), width: 1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.phone_callback_outlined,
                                      color: AppColors.primary,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "Call Us",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Color(0xff626262),
                                      ),
                                    ),
                                  ],
                                )),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: 200,
                            height: 40,
                            child: ElevatedButton(
                                onPressed: () async {
                                  // var url = 'mailto:info@driev.bike';
                                  // if (await canLaunch(url)) {
                                  //   await launch(url);
                                  // } else {
                                  //   throw 'Could not launch $url';
                                  // }
                                  final Uri smsLaunchUri =
                                  Uri(scheme: 'mailto', path: "info@driev.bike");
                                  await launchUrl(smsLaunchUri);
                                },
                                style: ElevatedButton.styleFrom(
                                  textStyle: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                  elevation: 0,
                                  foregroundColor: Colors.black,
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(
                                      color: Color(0xffC7C7C7), width: 1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.mark_email_read_outlined,
                                      color: AppColors.primary,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "Mail Us",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Color(0xff626262),
                                      ),
                                    ),
                                  ],
                                )),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  getBalance() async {
    alertServices.showLoading();
    String mobile = await secureStorage.get("mobile");
    bookingServices.getWalletBalance(mobile).then((r) {
      alertServices.hideLoading();
      double balance = r['balance'];
      print("bal -- ${balance.toStringAsFixed(2)}");
      setState(() {
        availableBalance = balance;
      });
    });
  }
}
