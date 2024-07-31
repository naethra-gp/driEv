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
    "battery issue",
    "Employees misbehaving",
    "payment issue",
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
  List<String> selectedItem = [];
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
                const SizedBox(
                  height: 15,
                ),
                const Text(
                  "Thank you for riding with us!",
                  style: TextStyle(
                    fontSize: 20,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  "Your feedback is greately appreciated",
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.fontgrey,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 30,
                ),
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
                const SizedBox(
                  height: 15,
                ),
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
                    print(_rating);
                  },
                ),
                const SizedBox(height: 20),
                if (_rating == 1.0 ||
                    _rating == 2.0 ||
                    _rating == 3.0 ||
                    _rating == 4.0) ...[
                  Wrap(
                    spacing: 10.0, // horizontal spacing between chips
                    runSpacing: 5.0, // vertical spacing between rows
                    children: items
                        .map(
                          (e) => FilterChip(
                            elevation: 5,
                            backgroundColor: Colors.white,
                            showCheckmark: false,
                            avatar: const Icon(
                              Icons.check,
                              color: AppColors.chipText,
                            ),
                            label: Text(e),
                            labelStyle: const TextStyle(
                              fontSize: 12,
                              color: AppColors.chipText,
                              fontWeight: FontWeight.w400,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(7.0), // rounded corners
                              side: const BorderSide(
                                color: AppColors.commentColor, // grey border
                              ),
                            ),
                            selected: selectedItem.contains(e),
                            onSelected: (bool value) {
                              setState(
                                () {
                                  if (selectedItem.contains(e)) {
                                    selectedItem.remove(e);
                                  } else {
                                    selectedItem.add(e);
                                  }
                                },
                              );
                              print(selectedItem);
                            },
                          ),
                        )
                        .toList(),
                  ),
                ],
                if (_rating == 1.0 ||
                    _rating == 2.0 ||
                    _rating == 3.0 ||
                    _rating == 4.0 ||
                    _rating == 5.0) ...[
                  const SizedBox(
                    height: 25,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    // Add your desired horizontal padding
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(width: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        // Add your desired horizontal padding
                        child: TextFormField(
                          textAlignVertical: TextAlignVertical.center,
                          maxLines: 3,
                          minLines: 3,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "  Comments..",
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              10), // Adjust the radius as needed
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

  whatsApp() async {
    try {
      await launchUrl(
        Uri.parse('whatsapp://send?phone=9600901981'),
      );
    } catch (e) {
      print("Error launching WhatsApp: $e");
      // Handle the error gracefully
    }
  }

  _makingPhoneCall() async {
    var url = "tel:+9600901981"; // Correct format for making a phone call
    try {
      await launchUrl(
        Uri.parse(url),
      );
    } catch (e) {
      print("Error launching WhatsApp: $e");
      // Handle the error gracefully
    }
  }

  void _launchmail() async {
    const url = 'mailto:aasima@maintwiz.com';
    try {
      await launchUrl(
        Uri.parse(url),
      );
    } catch (e) {
      print("Error launching WhatsApp: $e");
      // Handle the error gracefully
    }
  }

  void submitRideFeedback() {
    alertServices.showLoading();
    var params = {
      "rideId": widget.rideId,
      "feedBacks": selectedItem,
      "comments": commentCtl.text.toString(),
      "rating": _rating,
    };
    print("params ${jsonEncode(params)}");
    feedbackServices.rideFeedBack(params).then((response) {
      alertServices.hideLoading();
      if (response != null) {
        Navigator.pushNamed(context, "home");
      }
    });
  }
}
