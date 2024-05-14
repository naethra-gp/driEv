import 'package:flutter/material.dart';

class AppButtonWidget extends StatelessWidget {
  final VoidCallback? onPressed;
  final String title;

  const AppButtonWidget({super.key, this.onPressed, required this.title});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(title.toString()),
      ),
    );
  }
}
