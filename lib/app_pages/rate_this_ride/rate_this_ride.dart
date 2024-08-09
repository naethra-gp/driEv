import 'dart:convert';

import 'package:driev/app_services/feedback_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app_themes/app_colors.dart';
import '../../app_utils/app_loading/alert_services.dart';

class RateThisRide extends StatefulWidget {
  final String rideId;
  const RateThisRide({super.key, required this.rideId});

  @override
  State<RateThisRide> createState() => _RateThisRideState();
}

class _RateThisRideState extends State<RateThisRide> {
  final _ratingController = TextEditingController();
  double? _rating;
  AlertServices alertServices = AlertServices();
  FeedbackServices feedbackServices = FeedbackServices();

  final List<String> lowRatingItems = [
    "Battery issue",
    "Employees misbehaving",
    "Payment issue",
    "Booking issue",
    "Short range",
    "Others"
  ];
  final List<String> midRatingItems = [
    "Increase Vehicles",
    "More driEV Stations",
    "Smoother App",
    "Quick Support",
    "Vehicle Quality",
    "Others"
  ];
  List<String> selectedItem1 = [];
  List<String> selectedItem2 = [];

  TextEditingController commentCtl = TextEditingController();

  List<String> get items {
    if (_rating == 3.0 || _rating == 4.0) {
      return midRatingItems;
    }
    return lowRatingItems;
  }

  @override
  void initState() {
    super.initState();
    _ratingController.text = "0";
    _rating = 0.0;
    print(_rating);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 80),
                  child: Image.asset(
                    "assets/img/animm.png",
                    width: 102,
                    height: 106,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  "Thank you for riding with us!",
                  style: TextStyle(
                    fontSize: 20,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  "Your feedback is greately appreciated",
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.fontgrey,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                if (_rating == 0) ...[
                  const Text(
                    "How was your experience with us?",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.black,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (_rating == 1.0 || _rating == 2.0) ...[
                  const Text(
                    "What went Wrong?",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.black,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (_rating == 3.0 || _rating == 4.0) ...[
                  const Text(
                    "How can we improve our service?",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.black,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (_rating == 5.0) ...[
                  const Text(
                    "Thanks for the 5 star ratings",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.black,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 15),
                RatingBar.builder(
                  initialRating: _rating!,
                  minRating: 1,
                  direction: Axis.horizontal,
                  itemCount: 5,
                  itemSize: 30.0,
                  unratedColor: Colors.black,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 10.0),
                  itemBuilder: (context, index) {
                    return Icon(
                      index < _rating!
                          ? Icons.star_rate_rounded
                          : Icons.star_outline_rounded,
                      color: index < _rating! ? Colors.yellow : Colors.black,
                    );
                  },
                  onRatingUpdate: (rating) {
                    setState(() {
                      _rating = rating;
                    });
                  },
                ),
                const SizedBox(height: 20),
                if (_rating == 1.0 ||
                    _rating == 2.0 ||
                    _rating == 3.0 ||
                    _rating == 4.0) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Wrap(
                      spacing: 30.0,
                      runSpacing: 2.0,
                      children: items
                          .map(
                            (e) => FilterChip(
                              elevation: 2,
                              backgroundColor: Colors.white,
                              showCheckmark: false,
                              selectedColor: Colors.white,
                              selectedShadowColor: AppColors.primary,
                              avatar: const Icon(
                                Icons.check,
                                color: AppColors.chipText,
                              ),
                              labelPadding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              label: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 0),
                                child: Text(
                                  e.toString(),
                                  style: const TextStyle(
                                    fontFamily: "Roboto",
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                              labelStyle: const TextStyle(
                                fontSize: 13,
                                color: AppColors.chipText,
                                fontWeight: FontWeight.w400,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(7), // rounded corners
                                side: BorderSide(
                                  color: selectedItem1.contains(e) ||
                                          selectedItem2.contains(e)
                                      ? AppColors.primary
                                      : AppColors.commentColor, // grey border
                                ),
                              ),
                              selected: selectedItem1.contains(e) ||
                                  selectedItem2.contains(e),
                              onSelected: (bool value) {
                                setState(
                                  () {
                                    if (selectedItem1.contains(e) ||
                                        selectedItem2.contains(e)) {
                                      if (_rating! <= 2.0) {
                                        selectedItem1.remove(e);
                                      } else if (_rating! > 2.0 &&
                                          _rating! <= 4.0) {
                                        selectedItem2.remove(e);
                                      }
                                    } else {
                                      if (_rating! <= 2.0) {
                                        selectedItem1.add(e);
                                      } else if (_rating! > 2.0 &&
                                          _rating! <= 4.0) {
                                        selectedItem2.add(e);
                                      }
                                    }
                                  },
                                );
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
                if (_rating == 1.0 ||
                    _rating == 2.0 ||
                    _rating == 3.0 ||
                    _rating == 4.0 ||
                    _rating == 5.0) ...[
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(width: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: TextFormField(
                          textAlignVertical: TextAlignVertical.center,
                          maxLines: 3,
                          minLines: 3,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Comments..",
                            hintStyle: TextStyle(
                              fontSize: 12,
                              color: AppColors.commentColor,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          controller: commentCtl,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        submitRideFeedback();
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text("Submit"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void submitRideFeedback() {
    alertServices.showLoading();
    print('selected item $selectedItem1 , $selectedItem2');
    var params = {
      "rideId": widget.rideId,
      "feedBacks": _rating! <= 2.0 ? selectedItem1 : selectedItem2,
      "comments": commentCtl.text.toString(),
      "rating": _rating,
    };
    print("params ---> ${jsonEncode(params)}");
    feedbackServices.rideFeedBack(params).then((response) {
      alertServices.hideLoading();
      if (response != null) {
        // alertServices.successToast(response['messageEndStatus'].toString());
        Navigator.pushNamedAndRemoveUntil(context, "home", (r) => false);
      }
    });
  }
}
