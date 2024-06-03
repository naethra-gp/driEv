import 'package:driev/app_themes/app_colors.dart';
import 'package:driev/app_utils/app_loading/alert_services.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScanToUnlock extends StatefulWidget {
  const ScanToUnlock({super.key});

  @override
  State<ScanToUnlock> createState() => _ScanToUnlockState();
}

class _ScanToUnlockState extends State<ScanToUnlock> {
  bool isScanCompleted = false;
  TextEditingController bikeNumberCtl = TextEditingController();
  AlertServices alertServices = AlertServices();
  bool isTorchOn = true;
  MobileScannerController cameraController = MobileScannerController();
  @override
  void initState() {
    super.initState();
    cameraController.toggleTorch();
  }

  void toggleTorch() {
    setState(() {
      isTorchOn = !isTorchOn;
    });
    cameraController.toggleTorch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(10), // Adjust the radius as needed
              child: SizedBox(
                width: 250, // adjust the size as needed
                height: 250,
                child: Stack(
                  children: [
                    MobileScanner(
                      controller: cameraController,
                      onDetect: (qrcode, args) {
                        if (!isScanCompleted) {
                          if (qrcode.rawValue == null) {
                            isScanCompleted = true;
                            debugPrint('Failed to scan Barcode');
                            alertServices.errorToast("Unable to Scan QR Code!");
                          } else {
                            final String code = qrcode.rawValue!;
                            debugPrint('Qr found! $code');
                            setState(() {
                              bikeNumberCtl.text = code.toString().substring(3);
                            });
                          }
                        }
                      },
                    ),
                    Container(
                      decoration: ShapeDecoration(
                        shape: QrScannerOverlayShape(
                          borderColor: AppColors.primary,
                          borderRadius: 5,
                          borderWidth: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
                height: 20), // add some space between the box and the text
            const Text(
              "Not feeling the scan vibe? No worries!",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
                height: 10), // add some space between the box and the text
            const Text(
              "Enter bike number and ride on!",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.normal),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 190,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: TextField(
                    controller: bikeNumberCtl,
                    decoration: InputDecoration(
                      hintText: 'Enter Bike Number',
                       hintStyle: const TextStyle(
                           fontWeight: FontWeight.w400,
                           color: AppColors.fontgrey,
                           fontSize: 12),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: IconButton(
                    icon: Icon(isTorchOn ? Icons.flash_off : Icons.flash_on,
                        color: Colors.white),
                    onPressed: toggleTorch,
                  ), /* showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (context) {
                          return SizedBox(
                            height: MediaQuery.of(context).size.height / 1.6,
                            child: Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                Positioned(
                                  top:
                                      MediaQuery.of(context).size.height / 5.5 -
                                          100,
                                  child: Container(
                                    height: MediaQuery.sizeOf(context).height,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top:
                                      MediaQuery.of(context).size.height / 6.5 -
                                          100,
                                  child: Column(
                                    children: <Widget>[
                                      SizedBox(
                                        width: 50,
                                        height: 50,
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.green,
                                          ),
                                          child: IconButton(
                                            icon: const Icon(Icons.close),
                                            color: Colors.white,
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.only(top: 40),
                                        child: Text(
                                          "Please enter your OTP to \n conclude this ride.",
                                          textAlign: TextAlign.center,
                                          // style: GoogleFonts.roboto().copyWith(
                                          //     fontSize: 20,
                                          //     color: AppColors.black,
                                          //     fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      const Text(
                                        "Share this PIN with our station executive \n to end the ride",
                                        textAlign: TextAlign.center,
                                        // style: GoogleFonts.roboto().copyWith(
                                        //     fontSize: 16,
                                        //     color: AppColors.fontgrey,
                                        //     fontWeight: FontWeight.w400),
                                      ),
                                      const SizedBox(height: 25),
                                      const Text(
                                        "678965",
                                        textAlign: TextAlign.center,
                                        // style: GoogleFonts.roboto().copyWith(
                                        //     fontSize: 28,
                                        //     color: AppColors.black,
                                        //     fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      );*/
                ),
                const SizedBox(
                  height: 15,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
