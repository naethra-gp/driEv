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
    required this.fareDetails, required this.price,
  });
  final SuperTooltipController _controller = SuperTooltipController();

  @override
  Widget build(BuildContext context) {
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
