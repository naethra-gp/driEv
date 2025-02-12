import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../app_themes/app_colors.dart';

class CampusWidget extends StatelessWidget {
  final List data;
  final String logo;
  const CampusWidget({super.key, required this.data, required this.logo});

  @override
  Widget build(BuildContext context) {
    double logoSize = 50;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.primary,
          width: 1.5,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 1),
        leading: CachedNetworkImage(
          fit: BoxFit.fill,
          imageUrl: logo,
          width: logoSize,
          height: logoSize,
          progressIndicatorBuilder: (
            BuildContext context,
            String url,
            DownloadProgress dp,
          ) =>
              CircularProgressIndicator(value: dp.progress),
          errorWidget: (context, url, error) => Image.asset(
            width: logoSize,
            height: logoSize,
            "assets/app/no-img.png",
            fit: BoxFit.fill,
          ),
        ),
        title: data.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: Text(
                  "${data[0]['sName']} Campus",
                  style: const TextStyle(
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              )
            : const Text("N/A"),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            // const SizedBox(height: 20),
            Image.asset(
              "assets/img/scooter.png",
              height: 20,
              width: 20,
            ),
            Text(
              "${data[0]['filterVehicleList']?.length.toString()} ${data[0]['filterVehicleList']?.length > 1 ? "Rides" : "Ride"} Available",
              style: const TextStyle(
                fontFamily: "Poppins",
                fontWeight: FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: SizedBox(
          height: double.infinity,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Image.asset(
                "assets/img/slider_icon.png",
                height: 20,
                width: 20,
              ),
              Text(
                data[0]['distanceText'].toString(),
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }
}
