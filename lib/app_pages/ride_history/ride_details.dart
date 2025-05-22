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
  final List<Map<String, dynamic>> rideId;
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
          child: widget.rideId.isEmpty
              ? const Text("Please wait...")
              : mainContent(),
        ),
      ),
    );
  }

  Widget mainContent() {
    final ride = widget.rideId[0];
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
                  _buildHeader(ride),
                  _buildPaymentSection(ride),
                  const Divider(
                    color: Color(0XffADADAD),
                    endIndent: 5,
                    indent: 5,
                  ),
                  CustomTheme.defaultHeight10,
                  ..._buildRideDetails(ride),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> ride) {
    return Row(
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
                  text: "${ride['planType']} ${ride['vehicleId']}",
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
            onPressed: requestPermission,
          ),
        )
      ],
    );
  }

  Widget _buildPaymentSection(Map<String, dynamic> ride) {
    return Row(
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
                "₹ ${ride['payableAmount']}",
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
    );
  }

  List<Widget> _buildRideDetails(Map<String, dynamic> ride) {
    final endTime = DateTime.parse(ride['endTime'].toString());
    final offers = ride['offers'] as Map<String, dynamic>?;
    
    return [
      ListViewWidget(
          label: "Date",
          value: DateFormat("dd MMM yyyy").format(endTime)),
      CustomTheme.defaultHeight10,
      ListViewWidget(
          label: "Vehicle no.",
          value: "driEV ${ride['vehicleId']}"),
      CustomTheme.defaultHeight10,
      ListViewWidget(
          label: "Start Time",
          value: formatTime(ride['startTime'].toString())),
      CustomTheme.defaultHeight10,
      ListViewWidget(
          label: "End Time",
          value: formatTime(ride['endTime'].toString())),
      CustomTheme.defaultHeight10,
      ListViewWidget(
          label: "Base Charge",
          value: offers?['basePrice']?.toString() ?? ''),
      CustomTheme.defaultHeight10,
      ListViewWidget(
          label: "Ride Distance (KM)",
          value: ride['totalKm'].toString()),
      CustomTheme.defaultHeight10,
      ListViewWidget(
          label: "Billable Distance (KM)",
          value: ride['billableKm'].toString()),
      CustomTheme.defaultHeight10,
      ListViewWidget(
          label: "Ride Time",
          value: ride['duration'].toString()),
      CustomTheme.defaultHeight10,
      ListViewWidget(
          label: "Billable Time",
          value: ride['billableTime']?.toString() ?? ''),
      CustomTheme.defaultHeight10,
      ListViewWidget(
          label: "Total Amount (Incl.GST)",
          value: ride['payableAmount'].toString()),
      CustomTheme.defaultHeight10,
      ListViewWidget(
          label: "Total Amount (excl.GST)",
          value: ride['payableAmountExclGst'].toString()),
      CustomTheme.defaultHeight10,
    ];
  }

  Future<void> requestPermission() async {
    final status = await Permission.storage.status;
    screenShot = await screenshotController.capture();
    
    if (status.isGranted || status.isDenied && await Permission.storage.request().isGranted) {
      _captureAndSavePdf(screenShot!);
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  TextStyle heading(Color color) {
    return TextStyle(
      fontFamily: "Poppins-Bold",
      color: color,
      fontSize: 16,
    );
  }

  String formatTime(String dateTime) {
    try {
      return DateFormat('hh:mm a').format(DateTime.parse(dateTime).toLocal());
    } catch (e) {
      return "Unknown Time";
    }
  }

  Future<void> _captureAndSavePdf(Uint8List screenShot) async {
    try {
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) => pw.Center(
            child: pw.Image(pw.MemoryImage(screenShot), fit: pw.BoxFit.contain),
          ),
        ),
      );

      final dir = Platform.isIOS
          ? await getApplicationCacheDirectory()
          : await getDownloadsDirectory();
      final file = File('${dir?.path}/Ride Summary.pdf');
      
      await file.writeAsBytes(await pdf.save());
      OpenFile.open(file.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save or open PDF: $e')),
        );
      }
    }
  }
}
