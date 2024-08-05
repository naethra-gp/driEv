import 'package:flutter/material.dart';

import '../../../app_themes/app_colors.dart';

class CampusWidget extends StatelessWidget {
  final List data;
  const CampusWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5),
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
        leading: Image.asset(
          "assets/app/no-img.png",
          height: 50,
          width: 50,
        ),
        title: data.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  "${data[0]['sName']} Campus",
                  style: const TextStyle(
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              )
            : null,
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Image.asset(
              "assets/img/scooter.png",
              height: 20,
              width: 20,
            ),
            Text(
              "${data[0]['filterVehicleList'].length} Rides Available",
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
                "${data[0]['distanceText']}",
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
