import 'package:flutter/material.dart';

class ListViewWidget extends StatelessWidget {
  final String label;
  final String value;
  const ListViewWidget({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label.toString(),
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            maxLines: 10,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            value.toString() == "" ? "-" : value.toString(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
