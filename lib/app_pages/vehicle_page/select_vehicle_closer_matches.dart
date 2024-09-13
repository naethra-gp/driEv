import 'dart:convert';

import 'package:driev/app_pages/vehicle_page/widget/campus_widget.dart';
import 'package:driev/app_services/campus_services.dart';
import 'package:driev/app_utils/app_loading/alert_services.dart';
import 'package:flutter/material.dart';

import '../../app_config/app_constants.dart';
import 'widget/dynamic_card_widget.dart';
import 'widget/error_widget.dart';

class VehicleCloserMatches extends StatefulWidget {
  final List params;
  const VehicleCloserMatches({
    super.key,
    required this.params,
  });

  @override
  State<VehicleCloserMatches> createState() => _VehicleCloserMatchesState();
}

class _VehicleCloserMatchesState extends State<VehicleCloserMatches> {
  CampusServices campusServices = CampusServices();
  AlertServices alertServices = AlertServices();

  List filterVehicleList = [];
  List data = [];
  String logoURL = "";

  @override
  void initState() {
    super.initState();
    debugPrint("--- Page Name: VEHICLE CLOSER MATCHES ---");
    setState(() {
      data = widget.params;
    });
    getAllCampus(data[0]['sId'].toString());
  }

  getAllCampus(String id) {
    campusServices.getAllCampus().then((response) async {
      alertServices.hideLoading();
      List list = response;
      List campus = list.where((e) => e['stationId'] == id).toList();

      setState(() {
        logoURL = campus[0]['logoUrl'].toString();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    List fd = data[0]['filterVehicleList'];
    List cd = data[0]['closedVehicleList'];

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        Navigator.pushNamedAndRemoveUntil(context, "home", (route) => false);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          leading: IconButton(
            icon: Image.asset(Constants.backButton),
            onPressed: () async {
              Navigator.pushNamedAndRemoveUntil(
                  context, "home", (route) => false);
            },
          ),
        ),
        body: Stack(
          children: [
            /// Filtered vehicle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  CampusWidget(data: data, logo: logoURL),
                  const SizedBox(height: 16),
                  if (fd.isNotEmpty) ...[
                    Expanded(
                      child: GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 8.0,
                          crossAxisSpacing: 8.0,
                          mainAxisExtent: 200,
                        ),
                        itemCount: fd.length,
                        itemBuilder: (context, index) {
                          return DynamicCardWidget(
                            imageUrl: fd[index]['imageUrl'].toString(),
                            plan: fd[index]["planType"].toString(),
                            distanceRange:
                                fd[index]['distanceRange'].toString(),
                            vehicleId: fd[index]['vehicleId'].toString(),
                            onTap: () {
                              cardClick(fd[index]['vehicleId'].toString());
                            },
                          );
                        },
                      ),
                    ),
                  ] else ...[
                    const NoMatches()
                  ],
                ],
              ),
            ),

            /// Closer Matches vehicle
            if (cd.isNotEmpty) ...[
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 250,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        child: Text(
                          "Closer Matches :",
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // const SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: cd.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 5,
                              ),
                              child: DynamicCardWidget(
                                imageUrl: cd[index]['imageUrl'] ?? "",
                                plan: cd[index]["planType"],
                                distanceRange: cd[index]['distanceRange'],
                                vehicleId: cd[index]['vehicleId'],
                                onTap: () {
                                  cardClick(cd[index]['vehicleId']);
                                },
                              ),
                            );
                          },
                        ),
                      ),
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

  cardClick(String vehicleId) {
    List params = [
      {
        "campus": data[0]['sName'].toString(),
        "distance": data[0]['distanceText'].toString(),
        "vehicleId": vehicleId,
        "via": "app",
        "homeData": widget.params,
      }
    ];
    print("Select Vehicle: ${jsonEncode(params)}");
    var args = {"query": params};
    Navigator.pushNamed(context, "bike_fare_details", arguments: args);
  }
}
