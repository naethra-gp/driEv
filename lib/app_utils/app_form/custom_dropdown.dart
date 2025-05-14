import 'package:flutter/material.dart';

/// A custom dropdown form field that extends [FormField] with enhanced styling and functionality.
class CustomDropdown extends FormField<String> {
  static const double _borderRadius = 10.0;
  static const double _height = 48.0;
  static const double _fontSize = 12.0;
  static const double _elevation = 15.0;
  static const Color _borderColor = Color(0xffD2D2D2);
  static const EdgeInsets _contentPadding = EdgeInsets.only(left: 15);
  static const EdgeInsets _errorPadding = EdgeInsets.only(left: 12, top: 4);

  static const TextStyle _textStyle = TextStyle(
    fontWeight: FontWeight.normal,
    textBaseline: TextBaseline.alphabetic,
    fontFamily: "Roboto",
    fontSize: _fontSize,
  );

  static const TextStyle _errorStyle = TextStyle(
    color: Colors.redAccent,
    fontSize: _fontSize,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle _errorTextStyle = TextStyle(
    color: Colors.red,
    fontFamily: "Roboto-Regular",
    fontSize: _fontSize,
  );

  static const _inputDecorationTheme = InputDecorationTheme(
    border: InputBorder.none,
    errorStyle: _errorStyle,
    isDense: true,
    contentPadding: _contentPadding,
  );

  final List<DropdownMenuEntry<dynamic>> _dropdownMenuEntries;
  final String _title;
  final bool? _search;
  final bool _enabled;
  final ValueChanged<String?>? _onSelected;

  CustomDropdown({
    super.key,
    required List<DropdownMenuEntry<dynamic>> dropdownMenuEntries,
    required String title,
    String? errorText,
    bool? search,
    ValueChanged<String?>? onSelected,
    super.validator,
    super.initialValue,
    bool enabled = true,
    InputDecoration? decoration,
  })  : _dropdownMenuEntries = dropdownMenuEntries,
        _title = title,
        _search = search,
        _enabled = enabled,
        _onSelected = onSelected,
        super(builder: (state) => _buildFormField(state));

  static Widget _buildFormField(FormFieldState<String> state) {
    final dropdown = state.widget as CustomDropdown;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdownContainer(state, dropdown),
        if (state.hasError) _buildErrorText(state),
      ],
    );
  }

  static Widget _buildDropdownContainer(
      FormFieldState<String> state, CustomDropdown dropdown) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_borderRadius),
        border: Border.all(
          color: state.hasError ? Colors.red : _borderColor,
        ),
      ),
      height: _height,
      alignment: AlignmentDirectional.center,
      child: DropdownMenu(
        menuHeight: MediaQuery.of(state.context).size.width / 1.5,
        dropdownMenuEntries: dropdown._dropdownMenuEntries,
        enabled: dropdown._enabled,
        onSelected: (value) {
          state.didChange(value);
          state.validate();
          dropdown._onSelected?.call(value);
        },
        hintText: dropdown._title,
        expandedInsets: EdgeInsets.zero,
        enableFilter: dropdown._search ?? false,
        enableSearch: dropdown._search ?? false,
        requestFocusOnTap: dropdown._search ?? false,
        textStyle: _textStyle,
        errorText: null,
        inputDecorationTheme: _inputDecorationTheme,
        menuStyle: MenuStyle(
          backgroundColor: WidgetStateProperty.all(Colors.white),
          padding: WidgetStateProperty.all(EdgeInsets.zero),
          elevation: WidgetStateProperty.all(_elevation),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
      ),
    );
  }

  static Widget _buildErrorText(FormFieldState<String> state) {
    return Padding(
      padding: _errorPadding,
      child: Text(state.errorText ?? '', style: _errorTextStyle),
    );
  }
}
