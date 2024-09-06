import 'package:flutter/material.dart';
import 'package:super_tooltip/super_tooltip.dart';

import 'fare_details_widget.dart';

class FareListWidget extends StatelessWidget {
  final List fd;
  final SuperTooltipController? controller;
  const FareListWidget({super.key, required this.fd, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8.0),
        FareDetailsWidget(
          controller: controller,
          title: "Base fare",
          info: true,
          fareDetails: fd,
          price: fd[0]['offer']['basePrice'].toString(),
        ),
        const SizedBox(height: 8),
        FareDetailsWidget(
          title: "Ride charge per minute",
          info: false,
          fareDetails: fd,
          price: (fd[0]['offer']['perMinPaisa'] / 100).toString(),
        ),
        const SizedBox(height: 8),
        FareDetailsWidget(
          title: "Ride charge per km",
          info: false,
          fareDetails: fd,
          price: (fd[0]['offer']['perKmPaisa'] / 100).toString(),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
