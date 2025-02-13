

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sendme/utils/theme/app_colors.dart';
import 'package:sendme/utils/theme/app_text_theme.dart';

class CustomTextFormField extends StatefulWidget {
  final IconData? icon;
  final String hintText;
  final bool isPassword;
  final TextEditingController controller;
  final bool isPhone;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final bool showError;
   final bool hasError;
  final bool readOnly;

  const CustomTextFormField({
    Key? key,
    this.icon,
    required this.hintText,
    this.isPassword = false,
    required this.controller,
    this.isPhone = false,
    this.validator,
    this.onSaved,
     this.hasError = false,
    this.showError = false,
    this.readOnly = false,
  }) : super(key: key);

  @override
  _CustomTextFormFieldState createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Container(
      margin: EdgeInsets.symmetric(vertical: size.height * 0.01),
      child: TextFormField(
        readOnly: widget.readOnly,
        controller: widget.controller,
        obscureText: widget.isPassword && !_isPasswordVisible,
        keyboardType: widget.isPhone ? TextInputType.phone : TextInputType.text,
        inputFormatters: widget.isPhone
            ? <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly]
            : null,
        style: AppTextTheme.getLightTextTheme(context).titleMedium?.copyWith(
          fontSize: size.width * 0.04 * textScaleFactor,
        ),
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            fontSize: size.width * 0.04 * textScaleFactor,
            color: Colors.black54,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: widget.icon != null
              ? Icon(
                  widget.icon,
                  color: Colors.black54,
                  size: size.width * 0.06,
                )
              : null,
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: AppColors.backgroundDark,
                    size: size.width * 0.06,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                )
              : null,
          contentPadding: EdgeInsets.symmetric(
            vertical: size.height * 0.02,
            horizontal: size.width * 0.04,
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.red,
              width: size.width * 0.002,
            ),
            borderRadius: BorderRadius.circular(size.width * 0.04),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.red,
              width: size.width * 0.004,
            ),
            borderRadius: BorderRadius.circular(size.width * 0.04),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.black,
              width: size.width * 0.002,
            ),
            borderRadius: BorderRadius.circular(size.width * 0.04),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Color.fromARGB(255, 248, 209, 109),
              width: size.width * 0.002,
            ),
            borderRadius: BorderRadius.circular(size.width * 0.04),
          ),
        ),
        validator: widget.validator,
        onSaved: widget.onSaved,
      ),
    );
  }
}