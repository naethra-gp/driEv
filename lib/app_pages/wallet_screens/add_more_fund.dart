import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../registration_page/widget/reg_text_form_widget.dart';

class AddMoreFund extends StatefulWidget {
  const AddMoreFund({super.key});

  @override
  State<AddMoreFund> createState() => _AddMoreFundState();
}

class _AddMoreFundState extends State<AddMoreFund> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: <Widget>[
            TextFormWidget(
              title: 'Full Name',
              // controller: nameCtrl,
              required: true,
              prefixIcon: Icons.account_circle_outlined,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(
                  // RegExp('[a-z A-Z 0-9]'),
                    RegExp(r'[0-9]')
                ),
              ],
              validator: (value) {
                if (value.toString().trim().isEmpty) {
                  return "Full Name is Mandatory!";
                }
                return null;
              },
            ),

          ],
        ),
      ),
    );
  }
}
