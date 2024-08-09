import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import '../../../app_themes/app_colors.dart';

class RideDoneAlert extends StatelessWidget {
  final dynamic result;
  final String rideId;

  const RideDoneAlert({
    super.key,
    required this.result,
    required this.rideId,
  });

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double rideDistance = result[0]['totalRideDistance'];
    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    return SizedBox(
      width: double.infinity,
      height: mediaQueryData.size.height / 2.2,
      child: Padding(
        padding: EdgeInsets.only(bottom: mediaQueryData.viewInsets.bottom),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.only(
                    right: 50,
                    left: 50,
                    top: 10,
                    bottom: 5,
                  ),
                  child: Image.asset(
                    "assets/img/ride_end.png",
                    height: 40,
                    width: 40,
                  ),
                ),
                const Text(
                  "Ride done!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xff2c2c2c),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                RichText(
                  text: TextSpan(
                    text: 'Great job on your ',
                    style: DefaultTextStyle.of(context).style,
                    children: <TextSpan>[
                      const TextSpan(
                          text: 'last trip covering',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(
                          text: ' ${result[0]['lastRideDistance']} kilometers!',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: sliderWidget(rideDistance),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: width / 2.2,
                      height: 40,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.green,
                          side: const BorderSide(color: Colors.green),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                              context,
                              "ride_summary",
                              arguments: rideId,
                              (route) => false);
                        },
                        child: const Text("View Ride Summary",
                            style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: width / 2.2,
                      height: 40,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.green,
                          side: const BorderSide(color: Colors.green),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, "rate_this_raid",
                              arguments: rideId);
                        },
                        child: const Text(
                          "Rate This Ride",
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  sliderWidget(rideDistance) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.center,
          child: Text(
            'Total Ride Distance: $rideDistance KM',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: "Roboto",
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        Stack(
          alignment: Alignment.centerRight,
          children: [
            SfSliderTheme(
              data: const SfSliderThemeData(
                tooltipBackgroundColor: AppColors.primary,
                thumbColor: Colors.transparent,
                thumbRadius: 12,
                activeDividerColor: Color(0xff3DB54A),
                inactiveDividerStrokeColor: Color(0xff3DB54A),
                activeTrackHeight: 12,
                inactiveTrackHeight: 12,
                inactiveDividerColor: Colors.transparent,
                inactiveTickColor: Colors.transparent,
                activeTrackColor: Color(0xff3DB54A),
                trackCornerRadius: 20,
              ),
              child: SfSlider(
                min: 0.0,
                max: roundToNearest500(rideDistance),
                interval: 10,
                shouldAlwaysShowTooltip: false,
                stepSize: 10,
                thumbIcon: Container(
                  decoration: BoxDecoration(
                    color: Colors.green,
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Image.asset("assets/img/scooter.png"),
                ),
                value: rideDistance,
                labelPlacement: LabelPlacement.onTicks,
                thumbShape: const SfThumbShape(),
                semanticFormatterCallback: (dynamic value) {
                  return '$value km';
                },
                enableTooltip: true,
                showLabels: false,
                showDividers: true,
                showTicks: false,
                tooltipTextFormatterCallback: (av, ft) {
                  return "$ft km";
                },
                onChanged: (dynamic newValue) {},
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black87,
                ),
                padding: const EdgeInsets.all(5), // Adjust padding as needed
                child: Image.asset(
                  "assets/img/gift_box_ride.png",
                  width: 10,
                  height: 10,
                ),
                // child: SvgPicture.asset(
                //   'assets/img/giftbox 1.svg',
                //   height: 10,
                //   width: 10,
                // ),
              ),
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '0',
                style: TextStyle(
                    color: Color(0xff7B7B7B),
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
              ),
              // SizedBox(width: 5),

              Text(
                '${roundToNearest500(rideDistance).toStringAsFixed(0)} km',
                style: const TextStyle(
                    color: Color(0xff7B7B7B),
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  double roundToNearest500(double number) {
    return (number / 500).ceil() * 500;
  }
}
