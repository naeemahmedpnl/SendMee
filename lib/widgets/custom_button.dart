
import 'package:flutter/material.dart';
import 'package:sendme/utils/theme/app_text_theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double? widthFactor;
  final double height;
  final Color backgroundColor;
  final TextStyle? textStyle;
  final double borderRadius;
  final bool isLoading; 

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.widthFactor,
    this.height = 54,
    this.backgroundColor = const Color(0xFF86E30F),
    this.textStyle,
    this.borderRadius = 12.0,
    this.isLoading = false, 
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onPressed, 
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: isLoading ? backgroundColor.withOpacity(0.7) : backgroundColor, 
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 24, 
                  height: 24,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    strokeWidth: 2.0,
                  ),
                )
              : Text(
                  text,
                  style: textStyle ?? AppTextTheme.getLightTextTheme(context).bodyLarge,
                ),
        ),
      ),
    );
  }
}

