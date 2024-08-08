import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../registration_page/widget/reg_text_form_widget.dart';

class BikeFareTextWidget extends StatelessWidget {
  final TextEditingController controller;
  final Function onChanged;
  const BikeFareTextWidget(
      {super.key, required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextFormWidget(
      validator: (value) {
        if (value.toString().isNotEmpty) {
          if (int.parse(value) > 60) {
            return "Only allowed 60 Mins.";
          }
          if (int.parse(value) == 0) {
            return "Invalid Time";
          }
        }
        return null;
      },
      onChanged: (String value) {
        onChanged(value);
      },
      title: 'Enter Manually',
      controller: controller,
      required: true,
      maxLength: 2,
      // readOnly: isInputDisabled,
      prefixIcon: Icons.account_circle_outlined,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.done,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(
          RegExp('[0-9]'),
        ),
      ],
      decoration: InputDecoration(
        hintText: "Enter Manually",
        fillColor: Colors.grey[200],
        counterText: "",
        errorStyle: const TextStyle(
          color: Colors.redAccent,
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
        hintStyle: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xffD2D2D2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xffD2D2D2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xffD2D2D2)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xffD2D2D2)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        contentPadding: const EdgeInsets.only(left: 20),
        isDense: false,
      ),
    );
  }
}
