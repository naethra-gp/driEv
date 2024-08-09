import 'package:flutter/material.dart';

import '../../../app_themes/app_colors.dart';
import '../../app_common/need_help_widget.dart';

class BikeCardWidget extends StatelessWidget {
  final List data;
  const BikeCardWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: const Color(0xffF5F5F5),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
        child: Column(
          children: [
            Row(
              children: [
                RichText(
                    text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'dri',
                      style: heading(Colors.black),
                    ),
                    TextSpan(
                      text: 'EV ',
                      style: heading(AppColors.primary),
                    ),
                    TextSpan(
                      text:
                          "${data[0]['planType'].toString()} ${data[0]['vehicleId'].toString()}",
                      style: heading(Colors.black),
                    ),
                  ],
                )),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    needHelpAlert(context);
                  },
                  icon: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: 25,
                      height: 25,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.headset_mic_outlined,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      "Estimated Range",
                      style: TextStyle(
                        color: Color(0xff626262),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "${data[0]['estimatedRange']}",
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  // mainAxisSize: MainAxisSize.max,
                  // mainAxisAlignment: MainAxisAlignment.end,
                  // crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Image.asset(
                      "assets/img/bike2.png",
                      height: 120,
                      width: 160,
                      fit: BoxFit.fill,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TextStyle heading(Color color) {
    return TextStyle(
      fontFamily: "Poppins",
      fontWeight: FontWeight.bold,
      color: color,
      fontSize: 18,
    );
  }

  needHelpAlert(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      barrierColor: Colors.black87,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: false,
      builder: (context) {
        return const NeedHelpWidget();
      },
    );
  }
}
