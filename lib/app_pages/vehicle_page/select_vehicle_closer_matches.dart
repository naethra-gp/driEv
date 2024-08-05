import 'dart:convert';

import 'package:driev/app_pages/vehicle_page/widget/campus_widget.dart';
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
  List filterVehicleList = [];
  List data = [];

  @override
  void initState() {
    super.initState();
    debugPrint("--- Page Name: VEHICLE CLOSER MATCHES ---");
    print("Params: ${jsonEncode(widget.params)}");
    setState(() {
      data = widget.params;
    });
  }

  @override
  Widget build(BuildContext context) {
    List fd = data[0]['filterVehicleList'];
    List cd = data[0]['closedVehicleList'];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: Image.asset(Constants.backButton),
          onPressed: () async {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CampusWidget(data: data),
            const SizedBox(height: 16),
            if (fd.isNotEmpty) ...[
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8.0,
                    crossAxisSpacing: 8.0,
                    mainAxisExtent: 190,
                  ),
                  itemCount: fd.length,
                  itemBuilder: (context, index) {
                    return DynamicCardWidget(
                      imageUrl: fd[index]['imageUrl'].toString(),
                      plan: fd[index]["planType"].toString(),
                      distanceRange: fd[index]['distanceRange'].toString(),
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
            if (cd.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Closer Matches:",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8.0,
                    crossAxisSpacing: 8.0,
                    mainAxisExtent: 190,
                  ),
                  itemCount: cd.length,
                  itemBuilder: (context, index) {
                    return DynamicCardWidget(
                      imageUrl: cd[index]['imageUrl'].toString(),
                      plan: cd[index]["planType"].toString(),
                      distanceRange: cd[index]['distanceRange'].toString(),
                      vehicleId: cd[index]['vehicleId'].toString(),
                      onTap: () {
                        cardClick(cd[index]['vehicleId'].toString());
                      },
                    );
                  },
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
        "via": "app"
      }
    ];
    var args = {"query": params};
    Navigator.pushNamed(context, "bike_fare_details", arguments: args);
  }
}
