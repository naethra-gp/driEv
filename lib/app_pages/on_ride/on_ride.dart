import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:driev/app_themes/app_colors.dart';
import 'package:driev/app_utils/app_loading/alert_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class OnRide extends StatefulWidget {
  const OnRide({super.key});

  @override
  State<OnRide> createState() => _OnRideState();
}

class _OnRideState extends State<OnRide> {
  AlertServices alertServices = AlertServices();

  late GoogleMapController mapController;

  final LatLng _center =
      const LatLng(37.7749, -122.4194); // San Francisco coordinates
  LatLng? currentLocation;

  String currentDistrict = "Dindigul";
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  final Set<Marker> _markers = {};

  @override
  void initState() {
    // TODO: implement initState
    _getUserLocation();
    super.initState();
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
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
        _markers.add(
          Marker(
            markerId: const MarkerId('currentLocation'),
            position: currentLocation!,
            icon: customIcon,
          ),
        );
      });
    } catch (e) {
      alertServices.errorToast("Location Issue");
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
                      zoom: 18,
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
                              const SizedBox(width: 20),
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  "Current Location - $currentDistrict",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal,
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
                              const SizedBox(width: 10),
                              Image.asset(
                                "assets/img/wallet.png",
                                height: 20,
                                width: 20,
                              ),
                              const SizedBox(width: 10),
                              // if (customer.isNotEmpty)
                              //   Text(
                              //     "\u{20B9}${customer[0]['walletBalance']}",
                              //     style: TextStyle(
                              //       // fontSize: 14,
                              //       fontSize: width / 30,
                              //       fontWeight: FontWeight.bold,
                              //       color: getColor(customer[0]['walletBalance']),
                              //     ),
                              //     // style: CustomTheme.termStyle1red,
                              //   ),
                              const SizedBox(width: 20),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
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
                                    mainAxisAlignment: MainAxisAlignment.start,
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
                                            text: "Speed-44",
                                            // '${fd[0]['planType']}-${fd[0]['vehicleId']}',
                                            style: heading(Colors.black),
                                          ),
                                        ],
                                      )),
                                      // const SizedBox(height: 15),
                                      const SizedBox(height: 50),
                                      const Text(
                                        "Estimated Range",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontFamily: "Poppins",
                                          color: Color(0xff626262),
                                        ),
                                      ),
                                      const Text(
                                        "0",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontFamily: "Poppins",
                                        ),
                                      ),
                                      const SizedBox(height: 25),
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
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      GestureDetector(
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
                                      const SizedBox(height: 40),
                                      Image.asset(
                                        "assets/img/bike.png",
                                        fit: BoxFit.fitWidth,
                                        width: 180,
                                        // height: 130,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 15.0),
                          const Divider(),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.speed_outlined,
                                        color: AppColors.primary,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        '12.5 km',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Padding(
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
                                      Icon(
                                        Icons.timer_outlined,
                                        color: AppColors.primary,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        '00:00:00',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Padding(
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
                          const SizedBox(height: 15.0),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, "end_ride_scanner");
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text('End Ride'),
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.red,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'You can end your ride at the KIIT station only',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
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

  getColor(value) {
    if (value < 350) {
      return Colors.redAccent;
    } else {
      return AppColors.primary;
    }
  }

  needHelpAlert(BuildContext context) {
    showModalBottomSheet(
      context: context,
      // isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.white,
      barrierColor: Colors.black.withOpacity(.80),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(21)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: SizedBox(
            height: 400,
            child: Column(
              children: [
                const SizedBox(height: 50),
                Align(
                  alignment: Alignment.center,
                  child: Image.asset(
                    "assets/img/question_mark.png",
                    height: 75,
                    width: 75,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Need Help?",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Column(
                    children: [
                      ElevatedButton(
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
                      const SizedBox(height: 16),
                      ElevatedButton(
                          onPressed: () async {
                            // var contact = "+919439099990";
                            // const tel= $contact;
                            final Uri smsLaunchUri = Uri(
                                scheme: 'tel',
                                path: "+919439099990"
                            );
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
                      const SizedBox(height: 16),
                      ElevatedButton(
                          onPressed: () async {
                            var url = 'mailto:info@driev.bike';
                            if (await canLaunch(url)) {
                            await launch(url);
                            } else {
                            throw 'Could not launch $url';
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
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }
}