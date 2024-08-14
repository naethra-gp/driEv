import 'package:driev/app_services/index.dart';
import 'package:driev/app_themes/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../app_config/app_constants.dart';
import '../../app_storages/secure_storage.dart';
import '../../app_utils/app_loading/alert_services.dart';

class SelectVehiclePage extends StatefulWidget {
  final List stationDetails;
  const SelectVehiclePage({
    super.key,
    required this.stationDetails,
  });

  @override
  State<SelectVehiclePage> createState() => _SelectVehicleState();
}

class _SelectVehicleState extends State<SelectVehiclePage> {
  AlertServices alertServices = AlertServices();
  SecureStorage secureStorage = SecureStorage();
  VehicleService vehicleService = VehicleService();

  List vehicleList = [];
  List filterVehicleList = [];
  String stationName = '';
  String distance = '';
  String distanceText = '';
  String plan = "";
  @override
  void initState() {
    String sId = widget.stationDetails[0]['sId'];
    plan = widget.stationDetails[0]['plan'];
    setState(() {
      stationName = widget.stationDetails[0]['sName'];
      distance = widget.stationDetails[0]['distance'];
      distanceText = widget.stationDetails[0]['distanceText'];
    });
    getVehiclesByPlan(sId, plan);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  getVehiclesByPlan(String sId, String plan) async {
    alertServices.showLoading();
    vehicleService.getVehiclesByPlan(sId, plan).then((response) async {
      print(response);
      alertServices.hideLoading();
      vehicleList = response.where((i) => i['distanceRange'] != null).toList();
      for (int i = 0; i < vehicleList.length; i++) {
        List dis = vehicleList[i]['distanceRange'].toString().split("-");
        if (dis.length == 2) {
          int minDistance = int.parse(dis[0]);
          int maxDistance = int.parse(dis[1]);
          int userDistance = int.parse(distance);
          int lowerBound = userDistance - 20;
          int upperBound = userDistance + 20;
          if ((minDistance >= lowerBound && minDistance <= upperBound) ||
              (maxDistance >= lowerBound && maxDistance <= upperBound) ||
              (minDistance <= lowerBound && maxDistance >= upperBound)) {
            print("Adding vehicle: ${vehicleList[i]}");
            setState(() {
              filterVehicleList.add(vehicleList[i]);
            });
          }
        }
      }
      if (filterVehicleList.isEmpty) {
        Navigator.pushNamed(context, "error_bike");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: const Color(0xffF5F5F5),
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
                title: stationName.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          "$stationName Campus",
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
                    Image.asset("assets/img/scooter.png",
                        height: 20, width: 20),
                    Text(
                      "${filterVehicleList.length} Rides Available",
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
                        distanceText.toString(),
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (filterVehicleList.isEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height / 3),
                    const Text(
                      'No DriEV Bike\'s found',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              )
            ],
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8.0,
                  crossAxisSpacing: 8.0,
                  mainAxisExtent: 190,
                ),
                itemCount: filterVehicleList.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      List params = [
                        {
                          "campus": stationName.toString(),
                          "distance": distanceText.toString(),
                          "vehicleId":
                              filterVehicleList[index]['vehicleId'].toString(),
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
                                            '$plan ${filterVehicleList[index]['vehicleId'].toString()}',
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
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
                                          filterVehicleList[index]
                                                      ['distanceRange'] ==
                                                  null
                                              ? "-"
                                              : "${filterVehicleList[index]['distanceRange'].toString()} KM",
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
        ),
      ),
    );
  }
}
