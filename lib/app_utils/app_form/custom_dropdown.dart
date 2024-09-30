import 'package:flutter/material.dart';

class CustomDropdown extends FormField<String> {
  CustomDropdown(
      {Key? key,
      required List<DropdownMenuEntry<dynamic>> dropdownMenuEntries,
      required String title,
      String? errorText,
      bool? search,
      ValueChanged<String?>? onSelected,
      FormFieldValidator<String>? validator,
      String? initialValue,
      bool enabled = true,
      InputDecoration? decoration})
      : super(
          key: key,
          validator: validator,
          initialValue: initialValue,
          builder: (FormFieldState<String> state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color:
                          state.hasError ? Colors.red : const Color(0xffD2D2D2),
                    ),
                  ),
                  height: 48,
                  alignment: AlignmentDirectional.center,
                  child: DropdownMenu(
                    menuHeight: MediaQuery.of(state.context).size.width / 1.5,
                    dropdownMenuEntries: dropdownMenuEntries,
                    enabled: enabled,
                    onSelected: (value) {
                      state.didChange(value);
                      state.validate();
                      if (onSelected != null) {
                        onSelected(value);
                      }
                    },
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
                    errorText: null,
                    inputDecorationTheme: InputDecorationTheme(
                      border: InputBorder.none,
                      errorStyle: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xffD2D2D2)),
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.only(left: 15),
                    ),
                    menuStyle: MenuStyle(
                      backgroundColor:
                          const WidgetStatePropertyAll(Colors.white),
                      padding: const WidgetStatePropertyAll(EdgeInsets.zero),
                      elevation: const WidgetStatePropertyAll(15),
                      visualDensity: VisualDensity.adaptivePlatformDensity,
                    ),
                  ),
                ),
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.only(left: 12, top: 4),
                    child: Text(
                      state.errorText ?? '',
                      style: const TextStyle(
                        color: Colors.red,
                        fontFamily: "Roboto-Regular",
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            );
          },
        );
}
