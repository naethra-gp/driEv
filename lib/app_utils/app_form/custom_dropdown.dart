import 'package:flutter/material.dart';

import '../../app_themes/app_colors.dart';

class CustomDropdown extends StatelessWidget {
  final List<DropdownMenuEntry<dynamic>> dropdownMenuEntries;
  final ValueChanged<dynamic>? onSelected;
  final bool? search;
  final String title;

  const CustomDropdown({
    super.key,
    required this.dropdownMenuEntries,
    this.onSelected,
    required this.title,
    this.search,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 48,
          alignment: AlignmentDirectional.center,
          child: DropdownMenu(
            menuHeight: MediaQuery.of(context).size.width / 1.5,
            dropdownMenuEntries: dropdownMenuEntries,
            enabled: true,
            onSelected: onSelected,
            hintText: title,
            expandedInsets: const EdgeInsets.all(0),
            enableFilter: search ?? false,
            enableSearch: search ?? false,
            requestFocusOnTap: search ?? false,
            textStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              textBaseline: TextBaseline.alphabetic,
              fontFamily: "Roboto",
              fontSize: 12,
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: const BorderSide(
                    color: Color(0xffD2D2D2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                    color: Color(0xffD2D2D2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                    color: AppColors.primary),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                    color: Color(0xffD2D2D2)),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                const BorderSide(color: Colors.red),
              ),
              isDense: true,
            ),
            menuStyle: MenuStyle(
              backgroundColor: const WidgetStatePropertyAll(Colors.white),
              padding: const WidgetStatePropertyAll(EdgeInsets.zero),
              elevation: const WidgetStatePropertyAll(15),
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
          ),
        ),
      ],
    );
  }
}
