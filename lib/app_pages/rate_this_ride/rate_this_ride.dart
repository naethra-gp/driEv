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

  final items = [
    "battery issue",
    "Employees misbehaving",
    "payment issue",
    "Booking issue",
    "Short range",
    "Others"
  ];
  List<String> selectedItem = [];
  TextEditingController commentCtl = TextEditingController();

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
                  "Give us the scoop!",
                   style: TextStyle(
                     fontSize: 20,
                     color: AppColors.primary,
                     fontWeight: FontWeight.w500,
                   ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  "We are all ears to hear from you",
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
                    "Rate your last ride with us",
                    style: TextStyle(
                       fontSize: 14,
                       color: AppColors.black,
                       fontWeight: FontWeight.w500,
                     ),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (_rating == 1.0 || _rating == 2.0) ...[
                  const Text(
                    "What could be made better?",
                     style: TextStyle(
                       fontSize: 14,
                       color: AppColors.black,
                       fontWeight: FontWeight.w500,
                     ),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (_rating == 3.0 || _rating == 4.0) ...[
                  const Text(
                    "What services do you think could be improved?",
                     style: TextStyle(
                       fontSize: 14,
                       color: AppColors.black,
                       fontWeight: FontWeight.w500,
                     ),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (_rating == 5.0) ...[
                  const Text(
                    "Thank you for rating us the best!",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.black,
                      fontWeight: FontWeight.w500,
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
                  unratedColor: Colors.grey,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 10.0),
                  itemBuilder: (context, _) => const ImageIcon(
                    AssetImage("assets/img/feedback_star.png"),
                    color: Colors.yellow,
                  ),
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
                    height: 15,
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
                        ),
                      ),
                    ),
                  ),

                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  //   child: SizedBox(
                  //     height: 48,
                  //     width: double.infinity,
                  //     child: ElevatedButton(
                  //       style: ElevatedButton.styleFrom(
                  //         backgroundColor: Colors.green,
                  //         side: const BorderSide(color: Colors.green),
                  //         shape: RoundedRectangleBorder(
                  //           borderRadius: BorderRadius.circular(8.0),
                  //         ),
                  //       ),
                  //       onPressed: () {
                  //         showModalBottomSheet(
                  //           context: context,
                  //           backgroundColor: Colors.transparent,
                  //           builder: (context) {
                  //             return SizedBox(
                  //               width: double.infinity,
                  //               height:
                  //               MediaQuery
                  //                   .of(context)
                  //                   .size
                  //                   .height / 2.3,
                  //               child: Stack(
                  //                 alignment: Alignment.center,
                  //                 children: <Widget>[
                  //                   Positioned(
                  //                     top: MediaQuery
                  //                         .of(context)
                  //                         .size
                  //                         .height /
                  //                         5.5 -
                  //                         100,
                  //                     child: Container(
                  //                       height:
                  //                       MediaQuery
                  //                           .sizeOf(context)
                  //                           .height,
                  //                       width:
                  //                       MediaQuery
                  //                           .of(context)
                  //                           .size
                  //                           .width,
                  //                       decoration: const BoxDecoration(
                  //                         color: Colors.white,
                  //                         borderRadius: BorderRadius.vertical(
                  //                             top: Radius.circular(20)),
                  //                       ),
                  //                     ),
                  //                   ),
                  //                   Positioned(
                  //                     top: MediaQuery
                  //                         .of(context)
                  //                         .size
                  //                         .height /
                  //                         6.5 -
                  //                         100,
                  //                     child: SizedBox(
                  //                       width: 50,
                  //                       height: 50,
                  //                       child: Container(
                  //                         decoration: const BoxDecoration(
                  //                           shape: BoxShape.circle,
                  //                           color: Colors.green,
                  //                         ),
                  //                         child: IconButton(
                  //                           icon: const Icon(Icons.close),
                  //                           color: Colors.white,
                  //                           onPressed: () {
                  //                             Navigator.pop(context);
                  //                           },
                  //                         ),
                  //                       ),
                  //                     ),
                  //                   ),
                  //                   Column(
                  //                     mainAxisAlignment:
                  //                     MainAxisAlignment.start,
                  //                     children: <Widget>[
                  //                       const SizedBox(
                  //                         height: 80,
                  //                       ),
                  //                       Image.asset(
                  //                         Constants.ques,
                  //                         height: 42,
                  //                         width: 36,
                  //                       ),
                  //                       Text(
                  //                         "Need Help?",
                  //                         textAlign: TextAlign.center,
                  //                         style: GoogleFonts.roboto().copyWith(
                  //                             fontSize: 24,
                  //                             color: AppColors.black,
                  //                             fontWeight: FontWeight.w500),
                  //                       ),
                  //                       const SizedBox(height: 10),
                  //                       SizedBox(
                  //                         width:
                  //                         200,
                  //                         child: OutlinedButton.icon(
                  //                           onPressed: () {
                  //                             whatsApp();
                  //                           },
                  //                           icon: Image.asset(Constants
                  //                               .watsap),
                  //                           label: const Text('Whatsapp Us'),
                  //                           style: OutlinedButton.styleFrom(
                  //                             foregroundColor:
                  //                             AppColors.faqColor,
                  //                             side: const BorderSide(
                  //                                 color: AppColors
                  //                                     .faqColor),
                  //                           ),
                  //                         ),
                  //                       ),
                  //                       SizedBox(
                  //                         width:
                  //                         200,
                  //                         child: OutlinedButton.icon(
                  //                           onPressed: () {
                  //                             _makingPhoneCall();
                  //                           },
                  //                           icon: Image.asset(Constants
                  //                               .call),
                  //                           label: const Text('call us'),
                  //                           style: OutlinedButton.styleFrom(
                  //                             foregroundColor:
                  //                             AppColors.faqColor,
                  //                             side: const BorderSide(
                  //                                 color: AppColors
                  //                                     .faqColor),
                  //                           ),
                  //                         ),
                  //                       ),
                  //                       SizedBox(
                  //                         width:
                  //                         200,
                  //                         child: OutlinedButton.icon(
                  //                           onPressed: () {
                  //                             _launchmail();
                  //                           },
                  //                           icon: Image.asset(Constants
                  //                               .watsap),
                  //                           label: const Text('Mail Us'),
                  //                           style: OutlinedButton.styleFrom(
                  //                             foregroundColor:
                  //                             faqColor,
                  //                             side: const BorderSide(
                  //                                 color: faqColor),
                  //                           ),
                  //                         ),
                  //                       ),
                  //                     ],
                  //                   ),
                  //                 ],
                  //               ),
                  //             );
                  //           },
                  //         );
                  //       },
                  //       child: Text(
                  //         'Submit',
                  //         // style: CustomTheme.headingStyleWhite,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        submitRideFeedback();
                      },
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
