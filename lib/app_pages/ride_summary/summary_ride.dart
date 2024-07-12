import 'dart:typed_data';
import 'dart:ui';

import 'package:driev/app_pages/ride_summary/widget/list_ride_summary.dart';
import 'package:driev/app_services/booking_services.dart';
import 'package:driev/app_utils/app_loading/alert_services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:io';
import '../../app_config/app_constants.dart';
import '../../app_themes/app_colors.dart';
import '../../app_themes/custom_theme.dart';

class RideSummary extends StatefulWidget {
  final String rideId;
  const RideSummary({super.key, required this.rideId});

  @override
  State<RideSummary> createState() => _RideSummaryState();
}

class _RideSummaryState extends State<RideSummary> {
  final ScreenshotController screenshotController = ScreenshotController();
  Uint8List? screenShot;
  AlertServices alertServices = AlertServices();
  BookingServices bookingServices = BookingServices();
  List rideDetails = [];

  @override
  void initState() {
    getRideDetails(widget.rideId);
    super.initState();
  }

  getRideDetails(String rideId) {
    alertServices.showLoading();
    bookingServices.getRideDetails(rideId).then((r) {
      alertServices.hideLoading();
      if (r != null) {
        setState(() {
          rideDetails = [r];
        });
      }
    });
  }

  Future<void> requestPermission() async {
    PermissionStatus status = await Permission.storage.status;
    screenShot = await screenshotController.capture();
    if (status.isGranted) {
    } else if (status.isDenied) {
      status = await Permission.storage.request();
      if (status.isGranted) {
        _captureAndSavePdf(screenShot!);
      } else {}
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
    _captureAndSavePdf(screenShot!);
  }

  @override
  Widget build(BuildContext context) {
    List rd = rideDetails;
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                title: const Text("Alert"),
                content: const Text("App will redirect to home page?"),
                actions: [
                  // TextButton(
                  //   child: const Text(
                  //     "No",
                  //     style: TextStyle(
                  //       fontWeight: FontWeight.bold,
                  //       color: Colors.redAccent,
                  //     ),
                  //   ),
                  //   onPressed: () {
                  //     Navigator.pop(context);
                  //   },
                  // ),
                  TextButton(
                    child: const Text(
                      "Yes",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () async {
                      Navigator.pushNamedAndRemoveUntil(
                          context, "home", (route) => false);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
      child: SafeArea(
          child: Scaffold(
        body: SingleChildScrollView(
          child: Center(
            child: rd.isEmpty
                ? const Text("Please wait...")
                : Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 25),
                    child: Column(
                      children: [
                        Screenshot(
                          controller: screenshotController,
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 5,
                              ),
                              const Text(
                                "Ride Summary",
                                style: TextStyle(
                                    fontSize: 24,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 5),
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
                                                      style:
                                                          heading(Colors.black),
                                                    ),
                                                    TextSpan(
                                                      text: 'EV ',
                                                      style: heading(
                                                          AppColors.primary),
                                                    ),
                                                    TextSpan(
                                                      text:
                                                          "${rd[0]['planType']} ${rd[0]['vehicleId']}",
                                                      style:
                                                          heading(Colors.black),
                                                    ),
                                                  ],
                                                ),
                                              )),
                                          Expanded(
                                            flex: 1,
                                            child: IconButton(
                                              icon: Image.asset(
                                                "assets/img/pdf.png",
                                                height: 30,
                                                width: 19,
                                              ),
                                              onPressed: () async {
                                                await requestPermission();
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
                                              children: <Widget>[
                                                const Text(
                                                  "Payment Total",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                                Text(
                                                  "₹ ${rd[0]['payableAmount']}",
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
                                              height: 110,
                                              width: 160,
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const Divider(
                                        color: Color(0XffADADAD),
                                      ),
                                      CustomTheme.defaultHeight10,
                                      ListViewWidget(
                                          label: "Date",
                                          value: DateFormat("dd MMM yyyy")
                                              .format(DateTime.parse(
                                                  rd[0]['endTime']))),
                                      // value: "${rd[0]['endTime']}"),
                                      CustomTheme.defaultHeight10,
                                      ListViewWidget(
                                          label: "driEV {vehicle No.}",
                                          value: "${rd[0]['vehicleId']}"),
                                      CustomTheme.defaultHeight10,
                                      ListViewWidget(
                                          label: "Time",
                                          value: DateFormat.jm().format(
                                              DateTime.parse(
                                                  rd[0]['endTime']))),
                                      CustomTheme.defaultHeight10,
                                      ListViewWidget(
                                          label: "Base Charge",
                                          value:
                                              "${rd[0]['offers']['basePrice'] ?? ""}"),
                                      CustomTheme.defaultHeight10,
                                      ListViewWidget(
                                          label: "Ride Distance (KM)",
                                          value: "${rd[0]['totalKm']}"),
                                      CustomTheme.defaultHeight10,
                                      ListViewWidget(
                                          label: "Billable Distance (KM)",
                                          value: "${rd[0]['billableKm']}"),
                                      CustomTheme.defaultHeight10,
                                      ListViewWidget(
                                          label: "Ride Time",
                                          value: "${rd[0]['duration']}"),
                                      CustomTheme.defaultHeight10,
                                      ListViewWidget(
                                          label: "Billable Time",
                                          value: "${rd[0]['billableTime']}"),
                                      CustomTheme.defaultHeight10,
                                      ListViewWidget(
                                          label: "Total Amount (Incl.GST)",
                                          value: "${rd[0]['payableAmount']}"),
                                      CustomTheme.defaultHeight10,
                                      ListViewWidget(
                                          label: "Total Amount (excl.GST)",
                                          value:
                                              "${rd[0]['payableAmountExclGst']}"),
                                      CustomTheme.defaultHeight10,
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),
                        SizedBox(
                          width: 150,
                          height: 42,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, "rate_this_raid",
                                  arguments: widget.rideId);
                            },
                            style: ElevatedButton.styleFrom(
                              textStyle: const TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                              foregroundColor: Colors.white,
                              backgroundColor: AppColors.primary,
                              side: const BorderSide(
                                  color: AppColors.primary, width: 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              "Rate This Ride",
                              style: TextStyle(
                                  color: AppColors.white, fontSize: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      )),
    );
  }

  TextStyle heading(Color color) {
    return TextStyle(
      fontFamily: "Poppins",
      fontWeight: FontWeight.bold,
      color: color,
      fontSize: 16,
    );
  }

  Future<void> _captureAndSavePdf(Uint8List screenShot) async {
    try {
      pw.Document pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return pw.Center(
              child: pw.Image(
                pw.MemoryImage(screenShot),
                fit: pw.BoxFit.contain,
              ),
            );
          },
        ),
      );
      final dir = await getExternalStorageDirectories();
      final cacheDir = dir!.first;
      final file = File('${cacheDir.path}/ride_summary.pdf');
      await pdf.save().then((List<int> data) async {
        await file.writeAsBytes(data); // Write data to file
        OpenFile.open(file.path);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save or open PDF: $e')),
      );
    }
  }
}
