import 'package:flutter/material.dart';
import 'package:super_tooltip/super_tooltip.dart';

class FareDetailsWidget extends StatelessWidget {
  final String title;
  final String price;
  final bool info;
  final List fareDetails;

  FareDetailsWidget({
    super.key,
    required this.title,
    required this.info,
    required this.fareDetails,
    required this.price,
  });
  final SuperTooltipController _controller = SuperTooltipController();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      decoration: BoxDecoration(
        color: const Color(0xffF5F5F5),
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(
          color: const Color(0xFFE1E1E1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12.0),
              ),
              if (info)
                SuperTooltip(
                  showBarrier: true,
                  controller: _controller,
                  popupDirection: TooltipDirection.up,
                  content: Text(
                    "Receive a complimentary ${fareDetails[0]['offer']['discountMin'].toStringAsFixed(0)} minute ride spanning ${fareDetails[0]['offer']['discountKm'].toStringAsFixed(0)} kilometers",
                    softWrap: true,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  child: GestureDetector(
                    onTap: () async {
                      await _controller.showTooltip();
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(left: 4.0),
                      child: Icon(
                        Icons.info,
                        size: 15.0,
                        color: Color(0xff7D7D7D),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Text(
            "₹$price",
            style: const TextStyle(fontSize: 12.0),
          ),
        ],
      ),
    );
  }
}
