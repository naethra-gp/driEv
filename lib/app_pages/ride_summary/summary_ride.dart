import 'dart:typed_data';

import 'package:driev/app_pages/ride_summary/widget/list_ride_summary.dart';
import 'package:flutter/material.dart';
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
import '../../app_utils/app_widgets/app_button.dart';

class RideSummary extends StatefulWidget {
  const RideSummary({super.key});

  @override
  State<RideSummary> createState() => _RideSummaryState();
}

class _RideSummaryState extends State<RideSummary> {
  final ScreenshotController screenshotController = ScreenshotController();
  Uint8List? screenShot;
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

  @override
  void initState() {
    super.initState();
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
    return SafeArea(
        child: Scaffold(
          body: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
                child: Column(
                  children: [
                    Screenshot(
                      controller: screenshotController,
                      child: Column(
                        children: [
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
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: AppColors.customGrey,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: 'dri',
                                              style: heading(Colors.black),
                                            ),
                                            TextSpan(
                                              text: 'EV ',
                                              style: heading(AppColors.primary),
                                            ),
                                            TextSpan(
                                              text: "Speed - 637",
                                              style: heading(Colors.black),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: Image.asset(Constants.pdf),
                                        onPressed: () async {
                                          await requestPermission();
                                        },
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    children: <Widget>[
                                      const Expanded(
                                        flex: 2,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              "Payment Total",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            Text(
                                              "₹ 1200",
                                              style: TextStyle(
                                                  fontSize: 34,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Image.asset(Constants.bike,
                                            height: 110, width: 150),
                                      )
                                    ],
                                  ),
                                  CustomTheme.defaultHeight10,
                                  const Divider(
                                    color: Color(0XffADADAD),
                                  ),
                                  CustomTheme.defaultHeight10,
                                  const ListViewWidget(
                                      label: "Date", value: "17 jan 2022"),
                                  CustomTheme.defaultHeight10,
                                  const ListViewWidget(
                                      label: "Vehicle No.", value: "drieV 269"),
                                  CustomTheme.defaultHeight10,
                                  const ListViewWidget(
                                      label: "Time", value: "10:30 am"),
                                  CustomTheme.defaultHeight10,
                                  const ListViewWidget(
                                      label: "Base Charge", value: "15"),
                                  CustomTheme.defaultHeight10,
                                  const ListViewWidget(
                                      label: "Maintenance Charge", value: "1"),
                                  CustomTheme.defaultHeight10,
                                  const ListViewWidget(
                                      label: "Ride Distance (KM)", value: "28.34"),
                                  CustomTheme.defaultHeight10,
                                  const ListViewWidget(
                                      label: "Billable Distance (KM)",
                                      value: "24.098"),
                                  CustomTheme.defaultHeight10,
                                  const ListViewWidget(
                                      label: "Ride Time", value: "88m 36s"),
                                  CustomTheme.defaultHeight10,
                                  const ListViewWidget(
                                      label: "Billable Time", value: "80m 40s"),
                                  CustomTheme.defaultHeight10,
                                  const ListViewWidget(
                                      label: "Billable Amount (Incl.GST)",
                                      value: "58.34"),
                                  CustomTheme.defaultHeight10,
                                  const ListViewWidget(
                                      label: "Total Amount (Incl.GST)",
                                      value: "35.00"),
                                  CustomTheme.defaultHeight10,
                                  const ListViewWidget(
                                      label: "Total Amount (excl.GST)",
                                      value: "75.09"),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 90),
                      child: AppButtonWidget(
                        title: "Rate this Ride",
                        onPressed: () {
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  TextStyle heading(Color color) {
    return TextStyle(
      fontFamily: "Poppins",
      fontWeight: FontWeight.bold,
      color: color,
      fontSize: 18,
    );
  }
}
