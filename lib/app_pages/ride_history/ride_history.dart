import 'package:driev/app_services/feedback_services.dart';
import 'package:driev/app_storages/secure_storage.dart';
import 'package:driev/app_utils/app_loading/alert_services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../app_config/app_constants.dart';
import '../../app_themes/app_colors.dart';

class RideHistory extends StatefulWidget {
  const RideHistory({super.key});

  @override
  State<RideHistory> createState() => _RideHistoryState();
}

class _RideHistoryState extends State<RideHistory> {
  AlertServices alertServices = AlertServices();
  SecureStorage secureStorage = SecureStorage();
  FeedbackServices feedbackServices = FeedbackServices();
  List<Map<String, dynamic>> rideHistoryDetails = [];

  @override
  void initState() {
    super.initState();
    getRideHistory();
  }

  void getRideHistory() async {
    alertServices.showLoading();
    String mobile = secureStorage.get("mobile") ?? "";
    feedbackServices.getRideHistory(mobile).then((response) {
      rideHistoryDetails = List<Map<String,dynamic>>.from(response);
      alertServices.hideLoading();
      setState(() {});
    }).catchError((error) {
      alertServices.hideLoading();
    });
  }

  String formatDateTime(String dateTime) {
    try {
      DateTime parsedDate = DateTime.parse(dateTime);
      return DateFormat('dd MMM yyyy').format(parsedDate);
    } catch (e) {
      return "Unknown Date";
    }
  }

  String formatTime(String dateTime) {
    try {
      DateTime parsedDate = DateTime.parse(dateTime);
      return DateFormat('hh:mm ').format(parsedDate);
    } catch (e) {
      return "Unknown Time";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Image.asset(Constants.backButton),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            const Text(
              "Ride History",
              style: TextStyle(
                  fontSize: 20,
                  color: AppColors.black,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text("Take a peek at your ride history \n with us.",
                style: TextStyle(
                    fontSize: 18,
                    color: AppColors.referColor,
                    fontWeight: FontWeight.w400),
                textAlign: TextAlign.center),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: ListView.builder(
                physics: const ScrollPhysics(),
                padding: const EdgeInsets.all(5),
                shrinkWrap: true,
                itemCount: rideHistoryDetails.length,
                itemBuilder: (BuildContext ctx, int index) {
                  final ride = rideHistoryDetails[index];
                  return GestureDetector(
                    /* onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                RatingBarScreen())), */
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: Card(
                        color: Colors.white,
                        surfaceTintColor: Colors.white,
                        elevation: 7,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(10), // if you need this
                        ),
                        child: Row(
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.all(7),
                              child: Container(
                                width: 51,
                                height: 51,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                      color: AppColors.customGrey, width: 1),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: Image.asset(
                                    "assets/img/ridebike.png",
                                    height: 30,
                                    width: 49,
                                  ),
                                ),
                              ),
                            ), // Icon widget
                            Expanded(
                              flex: 5,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    formatDateTime(ride["createdDate"] ?? ""),
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    formatTime(ride["startTime"] ?? ""),
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                "₹${ride["payableAmount"].toString()}" ?? "",
                                style: const TextStyle(
                                    fontSize: 22,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700),
                              ),
                            )
                          ],
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
