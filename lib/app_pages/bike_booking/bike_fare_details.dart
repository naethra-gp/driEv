import 'package:driev/app_utils/app_widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:super_tooltip/super_tooltip.dart';
import '../../app_config/app_constants.dart';
import '../../app_storages/secure_storage.dart';
import '../../app_themes/app_colors.dart';
import '../../app_utils/app_loading/alert_services.dart';
import 'package:driev/app_services/booking_services.dart';

class BikeFareDetails extends StatefulWidget {
  final List stationDetails;

  const BikeFareDetails({super.key, required this.stationDetails});

  @override
  State<BikeFareDetails> createState() => _BikeFareDetailsState();
}

class _BikeFareDetailsState extends State<BikeFareDetails> {
  AlertServices alertServices = AlertServices();
  SecureStorage secureStorage = SecureStorage();
  BookingServices bookingServices = BookingServices();
  String notes =
      "Battery swap after the given range might be chargeable and depends on the availability of assets & resources";
  final SuperTooltipController _controller = SuperTooltipController();
  List fareDetails = [];

  @override
  void initState() {
    String id = widget.stationDetails[0]['vehicleId'];
    getFareDetails(id);
    print("stationDetails ${widget.stationDetails}");
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  getFareDetails(String id) {
    alertServices.showLoading();
    bookingServices.getFare(id).then((response) async {
      alertServices.hideLoading();
      setState(() {
        fareDetails = [response];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    List fd = fareDetails;
    List sd = widget.stationDetails;
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Image.asset(Constants.backButton),
          onPressed: () async {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              const SizedBox(height: 16),
              if (fd.isNotEmpty) ...[
                Card(
                  surfaceTintColor: const Color(0xffF5F5F5),
                  color: const Color(0xffF5F5F5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
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
                                          '${fd[0]['planType']}-${fd[0]['vehicleId']}',
                                      style: heading(Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            Row(
                              children: [
                                Image.asset(
                                  "assets/img/slider_icon.png",
                                  height: 21,
                                  width: 16,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  "${sd[0]['campus']} (${sd[0]['distance']})",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "Estimated Range",
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: "Poppins",
                                color: Color(0xff626262),
                              ),
                            ),
                            Text(
                              fd[0]['estimatedRange'] ?? "0",
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: "Poppins",
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Icon(LineAwesome.battery_full_solid),
                            const Text(
                              "100%",
                              style: TextStyle(
                                fontSize: 10,
                                fontFamily: "Poppins",
                              ),
                            ),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const SizedBox(height: 40),
                            fd[0]['imageUrl'] != null
                                ? Image.network(
                                    fd[0]['imageUrl']
                                        .toString(), // Replace with your image URL
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    "assets/img/bike.png",
                                    fit: BoxFit.fitWidth,
                                    width: 185,
                                    // height: 130,
                                  ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 5),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: <TextSpan>[
                    const TextSpan(
                      text: "* ",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 13,
                      ),
                    ),
                    TextSpan(
                      text: notes,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xff7E7E7E),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Fare Details",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.15,
                  ),
                ),
              ),
              if (fd.isNotEmpty) ...[
                const SizedBox(height: 16),
                _baseFare(
                    "Base fare", true, fd[0]['offer']['basePrice'].toString()),
                const SizedBox(height: 5),
                _baseFare("Ride charge per minute", false,
                    fd[0]['offer']['perMinPaisa'].toString()),
                const SizedBox(height: 5),
                _baseFare("Ride charge per km", false,
                    fd[0]['offer']['perKmPaisa'].toString()),
                const SizedBox(height: 25),
                AppButtonWidget(
                  title:
                      "Reserve Your Bike (₹${fd[0]['offer']['blockAmountPerMin'].toString()} per min)",
                  onPressed: () {},
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white,
                      side:
                          const BorderSide(color: AppColors.primary, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: const Text("Scan to Unlock"),
                  ),
                )
              ],
            ],
          ),
        ),
      ),
    );
  }

  TextStyle heading(Color color) {
    return TextStyle(
      fontFamily: "Poppins",
      fontWeight: FontWeight.bold,
      color: color,
      fontSize: 18,
    );
  }

  _baseFare(String title, bool info, String price) {
    return Card(
      surfaceTintColor: const Color(0xffF5F5F5),
      color: const Color(0xffF5F5F5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        minVerticalPadding: 0,
        title: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xff020B01),
                fontSize: 16,
              ),
            ),
            if (info)
              SuperTooltip(
                showBarrier: true,
                controller: _controller,
                popupDirection: TooltipDirection.up,
                content: Text(
                  "Receive a complimentary ${fareDetails[0]['offer']['discountMin']} minute ride spanning ${fareDetails[0]['offer']['discountKm']} kilometers",
                  softWrap: true,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                ),
                child: IconButton(
                  onPressed: () async {
                    await _controller.showTooltip();
                  },
                  icon: const Icon(
                    Icons.info,
                    color: Color(0xff7D7D7D),
                  ),
                ),
              ),
          ],
        ),
        trailing: Text(
          "₹$price",
          style: const TextStyle(color: Color(0xff020B01), fontSize: 16),
        ),
      ),
    );
  }
}
