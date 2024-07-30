import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../app_themes/app_colors.dart';

class WalletListWidget extends StatelessWidget {
  final String title;
  final String subTitle;
  final String amount;
  final String transactionType;

  const WalletListWidget(
      {super.key,
      required this.title,
      required this.subTitle,
      required this.amount,
      required this.transactionType});

  @override
  Widget build(BuildContext context) {
    String symbol = transactionType == "Credit" ? "+" : "-";
    Color amountColor =
        transactionType == "Credit" ? AppColors.primary : Colors.redAccent;
    String formattedTransactionTime = _formatTransactionTime(subTitle);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontFamily: "Roboto",
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        formattedTransactionTime,
        style: const TextStyle(
          fontSize: 12,
          fontFamily: "Roboto",
          color: AppColors.fontgrey,
        ),
      ),
      trailing: Text(
        "$symbol ${amount.toString()}",
        textAlign: TextAlign.right,
        style: TextStyle(
          fontSize: 14,
          fontFamily: "Roboto",
          color: amountColor,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  String _formatTransactionTime(String timeString) {
    final DateTime time = DateTime.parse(timeString);
    final now = DateTime.now();
    if (time.year == now.year &&
        time.month == now.month &&
        time.day == now.day - 1) {
      return "Yesterday, ${DateFormat('hh:mm a').format(time)}";
    } else if (time.year == now.year &&
        time.month == now.month &&
        time.day == now.day) {
      return "Today, ${DateFormat('hh:mm a').format(time)}";
    } else {
      return DateFormat('yyyy-MM-dd, hh:mm a').format(time);
    }
  }
}
