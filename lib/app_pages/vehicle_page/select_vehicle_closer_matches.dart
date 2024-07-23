import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../app_config/app_constants.dart';
import '../../app_themes/app_colors.dart';

class SelectVehicleCloserMatches extends StatefulWidget {
  final List params;
  const SelectVehicleCloserMatches({
    super.key,
    required this.params,
  });

  @override
  State<SelectVehicleCloserMatches> createState() =>
      _SelectVehicleCloserMatchesState();
}

class _SelectVehicleCloserMatchesState
    extends State<SelectVehicleCloserMatches> {
  List filterVehicleList = [];
  List data = [];

  @override
  void initState() {
    super.initState();
    debugPrint("--- Page Name: SELECT VEHICLE CLOSER MATCHES ---");
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 1),
                leading: Image.asset(
                  "assets/app/no-img.png",
                  height: 50,
                  width: 50,
                ),
                title: data.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          "${data[0]['sName']} Campus",
                          style: const TextStyle(
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : null,
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Image.asset(
                      "assets/img/scooter.png",
                      height: 20,
                      width: 20,
                    ),
                    Text(
                      "${fd.length} Rides Available",
                      style: const TextStyle(
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                trailing: SizedBox(
                  height: double.infinity,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Image.asset(
                        "assets/img/slider_icon.png",
                        height: 20,
                        width: 20,
                      ),
                      Text(
                        "${data[0]['distanceText']} km",
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                ),
              ),
            ),
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
                    return GestureDetector(
                      onTap: () {
                        List params = [
                          {
                            "campus": data[0]['sName'].toString(),
                            "distance": data[0]['distanceText'].toString(),
                            "vehicleId": fd[index]['vehicleId'].toString(),
                            "via": "app",
                            "data": [],
                          }
                        ];
                        Navigator.pushNamed(context, "bike_fare_details",
                            arguments: {"query": params});
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(0),
                        child: Card(
                          elevation: 0,
                          surfaceTintColor: const Color(0xffF5F5F5),
                          color: const Color(0xffF5F5F5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          clipBehavior: Clip.none,
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(height: 5),
                                Image.asset(
                                  width: 135,
                                  height: 90,
                                  "assets/img/bike2.png",
                                  fit: BoxFit.fill,
                                ),
                                const SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.center,
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        const TextSpan(
                                          text: 'dri',
                                          style: TextStyle(
                                            fontFamily: "Poppins",
                                            fontWeight: FontWeight.bold,
                                            color: CupertinoColors.black,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const TextSpan(
                                          text: 'EV ',
                                          style: TextStyle(
                                            fontFamily: "Poppins",
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                            fontSize: 12,
                                          ),
                                        ),
                                        TextSpan(
                                          text:
                                              '${data[0]["plan"]} ${fd[index]['vehicleId']}',
                                          style: const TextStyle(
                                            fontFamily: "Poppins",
                                            fontWeight: FontWeight.bold,
                                            color: CupertinoColors.black,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              "Estimated Range",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 8,
                                                color: Color(0xff626262),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            fd[index]['distanceRange'] == null
                                                ? "-"
                                                : "${fd[index]['distanceRange']} KM",
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontFamily: "Poppins",
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ] else ...[
              const SizedBox(height: 25),
              const Text(
                "Oh Snap!",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Text(
                  "No EVs available for the selected\npreference at the moment!",
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 25),
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
                    return GestureDetector(
                      onTap: () {
                        List params = [
                          {
                            "campus": data[0]['sName'].toString(),
                            "distance": data[0]['distanceText'].toString(),
                            "vehicleId": cd[index]['vehicleId'].toString(),
                            "via": "app",
                          }
                        ];
                        Navigator.pushNamed(context, "bike_fare_details",
                            arguments: {"query": params});
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(0),
                        child: Card(
                          elevation: 0,
                          surfaceTintColor: const Color(0xffF5F5F5),
                          color: const Color(0xffF5F5F5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          clipBehavior: Clip.none,
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(height: 5),
                                Image.asset(
                                  width: 135,
                                  height: 90,
                                  "assets/img/bike2.png",
                                  fit: BoxFit.fill,
                                ),
                                const SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.center,
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        const TextSpan(
                                          text: 'dri',
                                          style: TextStyle(
                                            fontFamily: "Poppins",
                                            fontWeight: FontWeight.bold,
                                            color: CupertinoColors.black,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const TextSpan(
                                          text: 'EV ',
                                          style: TextStyle(
                                            fontFamily: "Poppins",
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                            fontSize: 12,
                                          ),
                                        ),
                                        TextSpan(
                                          text:
                                              '${data[0]["plan"]} ${cd[index]['vehicleId']}',
                                          style: const TextStyle(
                                            fontFamily: "Poppins",
                                            fontWeight: FontWeight.bold,
                                            color: CupertinoColors.black,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              "Estimated Range",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 8,
                                                color: Color(0xff626262),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            cd[index]['distanceRange'] == null
                                                ? "-"
                                                : "${cd[index]['distanceRange']} KM",
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontFamily: "Poppins",
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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
}
