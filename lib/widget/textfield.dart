import 'package:flutter/material.dart';

class TextFieldWidget{
  static base({
    required ValueChanged<String> onChanged,
    TextEditingController? controller,
    TextStyle? style,
    TextInputType? textInputType,
    TextInputAction? textInputAction,

    String? hintText,
    String? label,
    String? errorText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool? obscureText,
    bool? readOnly,
    EdgeInsetsGeometry? edgeInsetsGeometry,
  }){
    return TextField(
      onChanged: onChanged,
      controller: controller,
      readOnly: readOnly ?? false,
      style: const TextStyle(fontSize: 16),
      keyboardType: textInputType,
      textInputAction: textInputAction,
      obscureText: obscureText ?? false,
      decoration: InputDecoration(
        enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue)
        ),
        contentPadding: edgeInsetsGeometry,
        filled: true,
        fillColor: Colors.white,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: const OutlineInputBorder(),
        hintText: hintText,
        errorText: errorText),
    );

  }

}