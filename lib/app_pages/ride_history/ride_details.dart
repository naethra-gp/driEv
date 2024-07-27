import 'package:driev/app_utils/app_widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:screenshot/screenshot.dart';

import '../../app_config/app_constants.dart';
import '../../app_themes/app_colors.dart';
import '../../app_themes/custom_theme.dart';
import '../ride_summary/widget/list_ride_summary.dart';

class RideDetails extends StatefulWidget {
  final List rideId;
  const RideDetails({super.key, required this.rideId});

  @override
  State<RideDetails> createState() => _RideDetailsState();
}

class _RideDetailsState extends State<RideDetails> {
  // final ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    // TODO: implement initState
    print(widget.rideId);
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(),
      body: SingleChildScrollView(
        child: Center(
          child: widget.rideId == null || widget.rideId.isEmpty
              ? const Text("Please wait...")
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    children: [
                      Column(
                        children: [
                          const SizedBox(height: 5),
                          const Text(
                            "Ride Summary",
                            style: TextStyle(
                              fontSize: 22,
                              fontFamily: "Poppins",
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: AppColors.customGrey,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0xffF5F5F5),
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 8,
                                        child: RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: 'dri',
                                                style: heading(Colors.black),
                                              ),
                                              TextSpan(
                                                text: 'EV ',
                                                style:
                                                    heading(AppColors.primary),
                                              ),
                                              TextSpan(
                                                text:
                                                    "${widget.rideId[0]['planType']} ${widget.rideId[0]['vehicleId']}",
                                                style: heading(Colors.black),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: IconButton(
                                          icon: Image.asset(
                                            "assets/img/pdf.png",
                                            height: 30,
                                            width: 19,
                                          ),
                                          onPressed: () async {
                                            // await requestPermission();
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: <Widget>[
                                            SizedBox(height: 30),
                                            const Text(
                                              "Payment Total",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            Text(
                                              "₹ ${widget.rideId[0]['payableAmount']}",
                                              style: const TextStyle(
                                                fontSize: 34,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Image.asset(
                                          Constants.bike,
                                          fit: BoxFit.contain,
                                        ),
                                      )
                                    ],
                                  ),
                                  const Divider(
                                    color: Color(0XffADADAD),
                                    endIndent: 5,
                                    indent: 5,
                                  ),
                                  CustomTheme.defaultHeight10,
                                  ListViewWidget(
                                      label: "Date",
                                      value: DateFormat("dd MMM yyyy").format(
                                          DateTime.parse(
                                              widget.rideId[0]['endTime']))),
                                  CustomTheme.defaultHeight10,
                                  ListViewWidget(
                                      label: "Vehicle no.",
                                      value:
                                          "driEV ${widget.rideId[0]['vehicleId']}"),
                                  CustomTheme.defaultHeight10,
                                  ListViewWidget(
                                      label: "Time",
                                      value: DateFormat.jm().format(
                                          DateTime.parse(
                                              widget.rideId[0]['endTime']))),
                                  CustomTheme.defaultHeight10,
                                  ListViewWidget(
                                      label: "Base Charge",
                                      value:
                                          "${widget.rideId[0]['offers'] != null ? widget.rideId[0]['offers']['basePrice'] : ''}"),
                                  CustomTheme.defaultHeight10,
                                  ListViewWidget(
                                      label: "Ride Distance (KM)",
                                      value: "${widget.rideId[0]['totalKm']}"),
                                  CustomTheme.defaultHeight10,
                                  ListViewWidget(
                                      label: "Billable Distance (KM)",
                                      value:
                                          "${widget.rideId[0]['billableKm']}"),
                                  CustomTheme.defaultHeight10,
                                  ListViewWidget(
                                      label: "Ride Time",
                                      value: "${widget.rideId[0]['duration']}"),
                                  CustomTheme.defaultHeight10,
                                  ListViewWidget(
                                      label: "Billable Time",
                                      value:
                                          "${widget.rideId[0]['billableTime']}"),
                                  CustomTheme.defaultHeight10,
                                  ListViewWidget(
                                      label: "Total Amount (Incl.GST)",
                                      value:
                                          "${widget.rideId[0]['payableAmount']}"),
                                  CustomTheme.defaultHeight10,
                                  ListViewWidget(
                                      label: "Total Amount (excl.GST)",
                                      value:
                                          "${widget.rideId[0]['payableAmountExclGst']}"),
                                  CustomTheme.defaultHeight10,
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

TextStyle heading(Color color) {
  return TextStyle(
    fontFamily: "Poppins-Bold",
    color: color,
    fontSize: 16,
  );
}
