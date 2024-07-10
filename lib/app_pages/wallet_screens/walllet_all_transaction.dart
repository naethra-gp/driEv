import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../app_config/app_constants.dart';
import '../../app_themes/app_colors.dart';

class AllTransaction extends StatefulWidget {
  final List allTransaction;
  const AllTransaction({super.key, required this.allTransaction});

  @override
  State<AllTransaction> createState() => _AllTransactionState();
}

class _AllTransactionState extends State<AllTransaction> {
  List transactionDetails = [];
  String walletBalance = "";
  @override
  void initState() {
    transactionDetails = widget.allTransaction;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // Removes the shadow below the AppBar
        forceMaterialTransparency: true,
        leading: IconButton(
          icon: Image.asset(Constants.backButton),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                "Wallet History",
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.green,
                    fontWeight: FontWeight.w500),
              )),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              "Your log of all Transaction",
              style: TextStyle(
                  fontSize: 14,
                  color: AppColors.referColor,
                  fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.walletColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: ListView.builder(
                      itemCount: transactionDetails.length,
                      itemBuilder: (context, index) {
                        final transaction = transactionDetails[index];
                        return Column(
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            WalletSummaryList(
                              title: transaction['description'],
                              subTitle: transaction['transactionTime'],
                              amount: transaction['transactionAmount']
                                  .toStringAsFixed(2),
                              transactionType: transaction['transactionType'],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Divider(
                              color: AppColors.centerAlign,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WalletSummaryList extends StatelessWidget {
  final String title;
  final String subTitle;
  final String amount;
  final String transactionType;

  const WalletSummaryList({
    super.key,
    required this.title,
    required this.subTitle,
    required this.amount,
    required this.transactionType,
  });

  @override
  Widget build(BuildContext context) {
    String symbol = transactionType == "Credit" ? "+" : "-";
    Color amountColor = transactionType == "Credit" ? Colors.green : Colors.red;
    String formattedTransactionTime = _formatTransactionTime(subTitle);

    return Row(
      children: <Widget>[
        Expanded(
          flex: 5,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                    fontWeight: FontWeight.w400),
              ),
              Text(
                formattedTransactionTime,
                style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.fontgrey,
                    fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            "$symbol ${amount.toString()}",
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14,
              color: amountColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        )
      ],
    );
  }

  String _formatTransactionTime(String timeString) {
    final DateTime time = DateTime.parse(timeString);
    final now = DateTime.now();
    if (time.year == now.year &&
        time.month == now.month &&
        time.day == now.day - 1) {
      return "Yesterday, ${DateFormat('HH:mm').format(time)}";
    } else {
      return DateFormat('yyyy-MM-dd, HH:mm').format(time);
    }
  }
}
