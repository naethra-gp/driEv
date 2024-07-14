import 'package:driev/app_utils/app_widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../app_config/app_constants.dart';
import '../../app_themes/app_colors.dart';
import 'widgets/wallet_list_widget.dart';

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
      appBar: const AppBarWidget(),
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
                fontFamily: "Poppins",
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              "Your log of all Transaction",
              style: TextStyle(
                fontSize: 14,
                fontFamily: "Poppins",
                color: AppColors.referColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: const BoxDecoration(
                color: AppColors.walletColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: ListView.separated(
                      itemCount: transactionDetails.length,
                      itemBuilder: (context, index) {
                        final td = transactionDetails[index];
                        return WalletListWidget(
                          title: td['description'],
                          subTitle: td['transactionTime'],
                          amount: td['transactionAmount'].toStringAsFixed(2),
                          transactionType: td['transactionType'],
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const Divider();
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
