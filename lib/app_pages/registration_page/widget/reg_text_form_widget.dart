import 'package:driev/app_themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFormWidget extends StatelessWidget {
  final String title;
  final String? hintText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final IconData? prefixIcon;
  final Color? iconColor;
  final TextEditingController? controller;
  final FormFieldValidator? validator;
  final FormFieldSetter? onSaved;
  final ValueChanged<String>? onFieldSubmitted;
  final bool required;
  final bool? readOnly;
  final bool? autofocus;
  final GestureTapCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final bool? suffixIconTrue;
  final IconData? suffixIcon;
  final String? suffixText;
  final VoidCallback? suffixIconOnPressed;
  final String? helperText;
  final String? errorText;
  final TextStyle? helperStyle;
  final bool? obscureText;
  final bool? enabled;
  final String? obscuringCharacter;
  final String? counterText;
  final int? errorMaxLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final String? initialValue;
  final TextCapitalization? textCapitalization;
  final int? maxLines;
  final InputDecoration? decoration;
  const TextFormWidget({
    super.key,
    required this.title,
    this.hintText,
    this.keyboardType,
    this.textInputAction,
    this.prefixIcon,
    this.iconColor,
    this.controller,
    this.validator,
    this.onSaved,
    this.onFieldSubmitted,
    required this.required,
    this.readOnly,
    this.autofocus,
    this.onTap,
    this.inputFormatters,
    this.suffixIconTrue,
    this.suffixIcon,
    this.suffixText,
    this.suffixIconOnPressed,
    this.helperText,
    this.errorText,
    this.helperStyle,
    this.obscureText,
    this.enabled,
    this.obscuringCharacter,
    this.counterText,
    this.errorMaxLines,
    this.maxLength,
    this.onChanged,
    this.focusNode,
    this.initialValue,
    this.textCapitalization,
    this.maxLines,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // required
        //     ? RichText(
        //         text: TextSpan(
        //           text: title,
        //           style: CustomTheme.formLabelStyle,
        //           children: const [
        //             TextSpan(
        //               text: ' *',
        //               style: TextStyle(
        //                 color: Colors.redAccent,
        //               ),
        //             )
        //           ],
        //         ),
        //       )
        //     : RichText(
        //         text: TextSpan(
        //           text: title,
        //           style: CustomTheme.formLabelStyle,
        //         ),
        //       ),
        const SizedBox(
          height: 5,
        ),
        TextFormField(
          initialValue: initialValue,
          controller: controller,
          keyboardType: keyboardType ?? TextInputType.text,
          textInputAction: textInputAction ?? TextInputAction.next,
          maxLength: maxLength,
          obscureText: obscureText ?? false,
          obscuringCharacter: obscuringCharacter ?? '*',
          autofocus: autofocus ?? false,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: validator,
          textCapitalization: textCapitalization ?? TextCapitalization.none,
          readOnly: readOnly ?? false,
          enabled: enabled,
          onSaved: onSaved,
          onTap: onTap,
          onChanged: onChanged,
          inputFormatters: inputFormatters,
          onFieldSubmitted: onFieldSubmitted,
          focusNode: focusNode,
          maxLines: maxLines,
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.normal, color: Colors.black),
          decoration: decoration ??
              InputDecoration(
                hintText: hintText ?? title,
                counterText: counterText ?? '',
                errorMaxLines: errorMaxLines ?? 2,
                helperText: helperText,
                filled: readOnly,
                fillColor: Colors.grey[200],
                errorStyle: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
                helperStyle: helperStyle,
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
                  borderSide: const BorderSide(color: AppColors.primary),
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
                contentPadding: const EdgeInsets.only(left: 15),
                isDense: false,
                // prefixIcon: prefixIcon != null
                //     ? Icon(
                //         prefixIcon,
                //         color: iconColor ?? themeColor,
                //         size: 26,
                //       )
                //     : null,
              ),
        )
      ],
    );
  }
}
