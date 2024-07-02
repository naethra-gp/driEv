import 'package:driev/app_themes/app_colors.dart';
import 'package:driev/app_utils/app_widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../app_utils/app_provider/location_service.dart';

class ExtendBikeTimer extends StatefulWidget {
  const ExtendBikeTimer({super.key});

  @override
  State<ExtendBikeTimer> createState() => _ExtendBikeTimerState();
}

class _ExtendBikeTimerState extends State<ExtendBikeTimer> {
  final LocationService _locationService = LocationService();
  late GoogleMapController mapController;

  @override
  void initState() {
    debugPrint("--- Extend  ---");
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            GoogleMap(
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: true,
              compassEnabled: false,
              mapType: MapType.normal,
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
              // polylines: _polyLines,
              initialCameraPosition: const CameraPosition(
                target: LatLng(10.381433, 77.971011),
                zoom: 15.0,
              ),
              // markers: {
              //   Marker(
              //     markerId: const MarkerId('1'),
              //     position: _currentPosition!,
              //     icon: customerMarker ?? BitmapDescriptor.defaultMarker,
              //   ),
              //   Marker(
              //     markerId: const MarkerId('2'),
              //     position: stationLocation!,
              //     icon: stationMarker ?? BitmapDescriptor.defaultMarker,
              //   ),
              // },
            ),
            const SizedBox(height: 16),
            Positioned(
              top: 10,
              left: 15,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // GestureDetector(
                  //   onTap: () {
                  //     Navigator.pushReplacementNamed(context, "profile");
                  //   },
                  //   child: CachedNetworkImage(
                  //     width: 41,
                  //     height: 41,
                  //     imageUrl: selfieUrl,
                  //     errorWidget: (context, url, error) => Image.asset(
                  //       "assets/img/profile_logo.png",
                  //       width: 41,
                  //       height: 41,
                  //       fit: BoxFit.cover,
                  //     ),
                  //     imageBuilder: (context, imageProvider) => Container(
                  //       decoration: BoxDecoration(
                  //         image: DecorationImage(
                  //           image: imageProvider,
                  //           fit: BoxFit.cover,
                  //         ),
                  //         borderRadius: BorderRadius.circular(50),
                  //         border: Border.all(
                  //           color: Colors.white,
                  //           width: 1.5,
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(width: 5),
                  Container(
                    width: 260,
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Row(
                          children: [
                            SizedBox(width: 10),
                            Icon(Icons.location_on_outlined),
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                "currentDistrict",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, "wallet_summary");
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                height: 40,
                                width: 2,
                                color: const Color(0xffDEDEDE),
                              ),
                              const SizedBox(width: 10),
                              Image.asset(
                                "assets/img/wallet.png",
                                height: 25,
                                width: 25,
                              ),
                              const SizedBox(width: 10),
                              // if (customer.isNotEmpty)
                              //   Text(
                              //     "\u{20B9}${customer[0]['walletBalance']}",
                              //     style: TextStyle(
                              //       fontSize: width / 30,
                              //       fontWeight: FontWeight.bold,
                              //       color:
                              //       getColor(customer[0]['walletBalance']),
                              //     ),
                              //   ),
                              // const SizedBox(width: 10),
                            ],
                          ),
                        ),
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
              top: height / 2.5,
              // top: 550,
              child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(25),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(15, 40, 15, 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          elevation: 0,
                          color: const Color(0xffF5F5F5),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                            child: Column(
                              children: [
                                Row(
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
                                          text: " Speed 123",
                                          // "${rideDetails[0]['planType'].toString()}-${rideDetails[0]['vehicleId'].toString()}",
                                          // '${fd[0]['planType']}-${fd[0]['vehicleId']}',
                                          style: heading(Colors.black),
                                        ),
                                      ],
                                    )),
                                    const Spacer(),
                                    IconButton(
                                      color: AppColors.primary,
                                      onPressed: () {},
                                      icon: const Icon(Icons.add),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Column(
                                      children: <Widget>[
                                        Text(
                                          "Estimated Range",
                                          style: TextStyle(
                                            color: Color(0xff626262),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          "45~34 KM",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppColors.black,
                                          ),
                                        ),
                                      ],
                                    ),

                                    // const Spacer(),
                                    Image.asset(
                                      "assets/img/bike2.png",
                                      height: 150,
                                      width: 230,
                                      fit: BoxFit.contain,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Divider(
                          indent: 5,
                          endIndent: 5,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 50,
                          child: AppButtonWidget(
                            title: "16.20 Minute to Ride Time!",
                            onPressed: null,
                          ),
                        ),
                        const SizedBox(height: 25),
                        SizedBox(
                          height: 50,
                          child: AppButtonWidget(
                            title: "More",
                            onPressed: () {},
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Align(
                          alignment: Alignment.center,
                          child: Text(
                            "You can end your ride at the KIIT station only.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
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
}
