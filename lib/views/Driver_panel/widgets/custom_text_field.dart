// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFormField extends StatelessWidget {
  final IconData? icon;
  final Widget? prefixIcon;
  final TextStyle? style;
  final String hintText;
  final TextStyle? hintStyle;
  final bool isPassword;
  final TextEditingController? controller;
  final bool isNumber;
  final bool isEmail;
  final Function(String?)? onSaved;
  String? Function(String?)? validator;
  bool readOnly;
  final Color? fillColor;
  final bool? filled;

  CustomTextFormField({
    super.key,
    this.icon,
    this.prefixIcon,
    this.style,
    required this.hintText,
    this.hintStyle,
    this.isPassword = false,
    this.controller,
    this.isNumber = false,
    this.isEmail = true,
    this.onSaved,
    this.validator,
    this.readOnly = false,
    this.fillColor,
    this.filled,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      inputFormatters: isNumber
          ? <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly]
          : null,
      style: style ?? const TextStyle(color: Colors.black), 
      readOnly: readOnly,
      decoration: InputDecoration(
        filled: filled ?? true, 
        fillColor: fillColor ?? Colors.white, 
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        hintText: hintText,
        hintStyle: hintStyle ??
            const TextStyle(color: Colors.black54), 
        prefixIcon: prefixIcon,
        enabledBorder: OutlineInputBorder(
          borderSide:
              const BorderSide(color: Colors.black38, width: 2), 
          borderRadius: BorderRadius.circular(16),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
              color: Color.fromARGB(255, 248, 209, 109), width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      onSaved: onSaved,
      validator: validator,
    );
  }
}
