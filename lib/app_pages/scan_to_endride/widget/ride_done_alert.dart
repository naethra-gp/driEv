import 'package:flutter/material.dart';
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
    // List result = result;
    double rideDistance = result[0]['totalRideDistance'];
    return SizedBox(
      height: height / 1.5,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            top: height / 5.5 - 100,
            child: Container(
              height: height,
              width: width,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
            ),
          ),
          Positioned(
            top: height / 6.6 - 100,
            left: 0,
            right: 0,
            bottom: 10,
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
                Padding(
                  padding: const EdgeInsets.only(
                    right: 50,
                    left: 50,
                    top: 20,
                    bottom: 20,
                  ),
                  child: Image.asset(
                    "assets/img/ride_end.png",
                    height: 60,
                    width: 60,
                  ),
                ),
                const Text(
                  "Ride done!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Color(0xff2c2c2c),
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: sliderWidget(rideDistance),
                ),
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        // width: width / 2,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                                context,
                                "ride_summary",
                                arguments: rideId,
                                (route) => false);
                          },
                          child: const Text("View Ride Summary"),
                        ),
                      ),
                      const SizedBox(width: 25),
                      SizedBox(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, "rate_this_raid",
                                arguments: rideId);
                          },
                          child: const Text("Rate This Ride"),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  sliderWidget(rideDistance) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          alignment: Alignment.centerRight,
          children: [
            SfSliderTheme(
              data: const SfSliderThemeData(
                tooltipBackgroundColor: AppColors.primary,
                thumbColor: Colors.transparent,
                thumbRadius: 20,
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
                min: 10.0,
                max: roundToNearest500(rideDistance),
                interval: 10,
                shouldAlwaysShowTooltip: true,
                stepSize: 10,
                thumbIcon: Container(
                  decoration: BoxDecoration(
                    color: Colors.green, // Background color
                    border: Border.all(color: Colors.white, width: 3), // White border
                    borderRadius: BorderRadius.circular(25), // Adjust border radius as needed
                  ),
                  child: Image.asset(
                    "assets/img/scooter_2.png",
                    width: 13,
                    height: 13,
                  ),
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
                onChanged: (dynamic newValue) {
                  // distance = newValue;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child:
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                ),
                padding: const EdgeInsets.all(5), // Adjust padding as needed
                child: Image.asset(
                  "assets/img/giftbox.png",
                  width: 10,
                  height: 10,
                ),     ),)],
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
                ),
              ),
              Text(
                '${roundToNearest500(rideDistance).toStringAsFixed(0)} km',
                style: const TextStyle(
                  color: Color(0xff7B7B7B),
                  fontWeight: FontWeight.bold,
                ),
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
