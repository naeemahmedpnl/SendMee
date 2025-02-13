
import 'package:flutter/material.dart';
import 'package:sendme/utils/theme/app_text_theme.dart';

class WCustomTextFormField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final bool isNumber;
  final bool isLoading;
  final Function()? onTap;
  final Function(String)? onChanged;

  const WCustomTextFormField({
    super.key,
    required this.hintText,
    required this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.isNumber = false,
    this.isLoading = false,
    this.onTap, 
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        TextFormField(
          style: AppTextTheme.getLightTextTheme(context).bodyLarge,
          controller: controller,
          obscureText: isPassword,
          keyboardType: isNumber ? TextInputType.number : keyboardType,
          onTap: onTap, 
          onChanged: onChanged, 
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTextTheme.getLightTextTheme(context).bodyLarge,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        if (isLoading)
          const Padding(
            padding: EdgeInsets.only(right: 10),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                color: Colors.black54,
              ),
            ),
          ),
      ],
    );
  }
}
