import 'dart:io';
import 'dart:typed_data';

import 'package:driev/app_utils/app_widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
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
  final ScreenshotController screenshotController = ScreenshotController();
  Uint8List? screenShot;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
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
              : mainContent(),
        ),
      ),
    );
  }

  Widget mainContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Screenshot(
        controller: screenshotController,
        child: Column(
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
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.customGrey,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(color: Color(0xffF5F5F5), spreadRadius: 1),
                ],
              ),
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
                                style: heading(AppColors.primary),
                              ),
                              TextSpan(
                                text:
                                    "${widget.rideId[0]['planType'].toString()} ${widget.rideId[0]['vehicleId'].toString()}",
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            const SizedBox(height: 30),
                            const Text(
                              "Payment Total",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              "₹ ${widget.rideId[0]['payableAmount'].toString()}",
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
                      value: DateFormat("dd MMM yyyy").format(DateTime.parse(
                          widget.rideId[0]['endTime'].toString()))),
                  CustomTheme.defaultHeight10,
                  ListViewWidget(
                      label: "Vehicle no.",
                      value:
                          "driEV ${widget.rideId[0]['vehicleId'].toString()}"),
                  CustomTheme.defaultHeight10,
                  ListViewWidget(
                      label: "Start Time",
                      value:
                          formatTime(widget.rideId[0]['startTime'].toString())),
                  CustomTheme.defaultHeight10,
                  ListViewWidget(
                      label: "End Time",
                      value:
                      formatTime(widget.rideId[0]['endTime'].toString())),
                  CustomTheme.defaultHeight10,
                  ListViewWidget(
                      label: "Base Charge",
                      value:
                          "${widget.rideId[0]['offers'] != null ? widget.rideId[0]['offers']['basePrice'] : ''}"),
                  CustomTheme.defaultHeight10,
                  ListViewWidget(
                      label: "Ride Distance (KM)",
                      value: widget.rideId[0]['totalKm'].toString()),
                  CustomTheme.defaultHeight10,
                  ListViewWidget(
                      label: "Billable Distance (KM)",
                      value: widget.rideId[0]['billableKm'].toString()),
                  CustomTheme.defaultHeight10,
                  ListViewWidget(
                      label: "Ride Time",
                      value: widget.rideId[0]['duration'].toString()),
                  CustomTheme.defaultHeight10,
                  ListViewWidget(
                      label: "Billable Time",
                      value: widget.rideId[0]['billableTime'].toString()),
                  CustomTheme.defaultHeight10,
                  ListViewWidget(
                      label: "Total Amount (Incl.GST)",
                      value: widget.rideId[0]['payableAmount'].toString()),
                  CustomTheme.defaultHeight10,
                  ListViewWidget(
                      label: "Total Amount (excl.GST)",
                      value:
                          widget.rideId[0]['payableAmountExclGst'].toString()),
                  CustomTheme.defaultHeight10,
                ],
              ),
            ),
          ],
        ),
      ),
    );
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

  TextStyle heading(Color color) {
    return TextStyle(
      fontFamily: "Poppins-Bold",
      color: color,
      fontSize: 16,
    );
  }

  String formatTime(String dateTime) {
    print("dateTime $dateTime");
    try {
      DateTime parsedDate = DateTime.parse(dateTime).toLocal();
      print("dateTime ${DateFormat('hh:mm a').format(parsedDate)}");

      return DateFormat('hh:mm a').format(parsedDate);
    } catch (e) {
      return "Unknown Time";
    }
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
