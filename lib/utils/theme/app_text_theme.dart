import 'package:flutter/material.dart';
import 'package:rideapp/utils/theme/app_colors.dart';
import 'package:rideapp/utils/theme/responsive_config.dart';

class AppTextTheme {
  AppTextTheme._();

  static const String _fontName = 'Montserrat';

  // LIGHT THEME TEXT
  static TextTheme getLightTextTheme(BuildContext context) {
    return TextTheme(
      headlineLarge: TextStyle(
        fontSize: ResponsiveConfig.getFontSize(context, 32.0),
        fontWeight: FontWeight.bold,
        color: Colors.black,
        fontFamily: _fontName,
      ),
      headlineMedium: TextStyle(
        fontSize: ResponsiveConfig.getFontSize(context, 24.0),
        fontWeight: FontWeight.w600,
        color: Colors.black,
        fontFamily: _fontName,
      ),
      headlineSmall: TextStyle(
        fontSize: ResponsiveConfig.getFontSize(context, 18.0),
        fontWeight: FontWeight.w600,
        color: Colors.black,
        fontFamily: _fontName,
      ),
      titleLarge: TextStyle(
        fontSize: ResponsiveConfig.getFontSize(context, 16.0),
        fontWeight: FontWeight.w600,
        color: Colors.black,
        fontFamily: _fontName,
      ),
      titleMedium: TextStyle(
        fontSize: ResponsiveConfig.getFontSize(context, 16.0),
        fontWeight: FontWeight.w500,
        color: Colors.black,
        fontFamily: _fontName,
      ),
      titleSmall: TextStyle(
        fontSize: ResponsiveConfig.getFontSize(context, 16.0),
        fontWeight: FontWeight.w400,
        color: Colors.black,
        fontFamily: _fontName,
      ),
      bodyLarge: TextStyle(
        fontSize: ResponsiveConfig.getFontSize(context, 16.0),
        fontWeight: FontWeight.w600,
        color: Colors.black,
        fontFamily: _fontName,
      ),
      bodyMedium: TextStyle(
        fontSize: ResponsiveConfig.getFontSize(context, 16.0),
        fontWeight: FontWeight.normal,
        color: Colors.black,
        fontFamily: _fontName,
      ),
      bodySmall: TextStyle(
        fontSize: ResponsiveConfig.getFontSize(context, 14.0),
        fontWeight: FontWeight.w500,
        color: Colors.black.withOpacity(0.5),
        fontFamily: _fontName,
      ),
      labelLarge: TextStyle(
        fontSize: ResponsiveConfig.getFontSize(context, 14.0),
        fontWeight: FontWeight.bold,
        color: Colors.black,
        fontFamily: _fontName,
      ),
      labelMedium: TextStyle(
        fontSize: ResponsiveConfig.getFontSize(context, 14.0),
        fontWeight: FontWeight.normal,
        color: Colors.black.withOpacity(0.9),
        fontFamily: _fontName,
      ),
    );
  }

  // DARK THEME TEXT
  static TextTheme getDarkTextTheme(BuildContext context) {
    return TextTheme(
      headlineLarge: TextStyle(
        fontSize: ResponsiveConfig.getFontSize(context, 32.0),
        fontWeight: FontWeight.bold,
        color: Colors.white,
        fontFamily: _fontName,
      ),
      headlineMedium: TextStyle(
        fontSize: ResponsiveConfig.getFontSize(context, 24.0),
        fontWeight: FontWeight.w600,
        color: Colors.white,
        fontFamily: _fontName,
      ),
      headlineSmall: TextStyle(
        fontSize: ResponsiveConfig.getFontSize(context, 18.0),
        fontWeight: FontWeight.w600,
        color: Colors.white,
        fontFamily: _fontName,
      ),
      titleLarge: TextStyle(
        fontSize: ResponsiveConfig.getFontSize(context, 16.0),
        fontWeight: FontWeight.w600,
        color: Colors.white,
        fontFamily: _fontName,
      ),
      titleMedium: TextStyle(
        fontSize: ResponsiveConfig.getFontSize(context, 16.0),
        fontWeight: FontWeight.w500,
        color: Colors.white,
        fontFamily: _fontName,
      ),
      titleSmall: TextStyle(
        fontSize: ResponsiveConfig.getFontSize(context, 16.0),
        fontWeight: FontWeight.w400,
        color: Colors.white,
        fontFamily: _fontName,
      ),
      bodyLarge: TextStyle(
        fontSize: ResponsiveConfig.getFontSize(context, 14.0),
        fontWeight: FontWeight.w500,
        color: Colors.white,
        fontFamily: _fontName,
      ),
      bodyMedium: TextStyle(
        fontSize: ResponsiveConfig.getFontSize(context, 14.0),
        fontWeight: FontWeight.normal,
        color: Colors.white,
        fontFamily: _fontName,
      ),
      bodySmall: TextStyle(
        fontSize: ResponsiveConfig.getFontSize(context, 14.0),
        fontWeight: FontWeight.w500,
        color: Colors.white.withOpacity(0.5),
        fontFamily: _fontName,
      ),
      labelLarge: TextStyle(
        fontSize: ResponsiveConfig.getFontSize(context, 12.0),
        fontWeight: FontWeight.normal,
        color: Colors.white,
        fontFamily: _fontName,
      ),
      labelMedium: TextStyle(
        fontSize: ResponsiveConfig.getFontSize(context, 12.0),
        fontWeight: FontWeight.normal,
        color: Colors.white.withOpacity(0.5),
        fontFamily: _fontName,
      ),
    );
  }


  
  // DARK THEME TEXT
  static TextTheme getPrimaryTextTheme(BuildContext context) {
    return TextTheme(
      headlineLarge: TextStyle(
        fontSize: ResponsiveConfig.getFontSize(context, 32.0),
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
        fontFamily: _fontName,
      ),
      headlineMedium: TextStyle(
        fontSize: ResponsiveConfig.getFontSize(context, 24.0),
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
        fontFamily: _fontName,
      ),
      headlineSmall: TextStyle(
        fontSize: ResponsiveConfig.getFontSize(context, 18.0),
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
        fontFamily: _fontName,
      ),
      titleLarge: TextStyle(
        fontSize: ResponsiveConfig.getFontSize(context, 16.0),
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
        fontFamily: _fontName,
      ),
      titleMedium: TextStyle(
        fontSize: ResponsiveConfig.getFontSize(context, 16.0),
        fontWeight: FontWeight.w500,
        color: AppColors.primary,
        fontFamily: _fontName,
      ),
      titleSmall: TextStyle(
        fontSize: ResponsiveConfig.getFontSize(context, 16.0),
        fontWeight: FontWeight.w400,
        color:AppColors.primary,
        fontFamily: _fontName,
      ),
      bodyLarge: TextStyle(
        fontSize: ResponsiveConfig.getFontSize(context, 14.0),
        fontWeight: FontWeight.w500,
        color: AppColors.primary,
        fontFamily: _fontName,
      ),
      bodyMedium: TextStyle(
        fontSize: ResponsiveConfig.getFontSize(context, 14.0),
        fontWeight: FontWeight.normal,
        color: AppColors.primary,
        fontFamily: _fontName,
      ),
      bodySmall: TextStyle(
        fontSize: ResponsiveConfig.getFontSize(context, 14.0),
        fontWeight: FontWeight.w500,
        color: AppColors.primary,
        fontFamily: _fontName,
      ),
      labelLarge: TextStyle(
        fontSize: ResponsiveConfig.getFontSize(context, 12.0),
        fontWeight: FontWeight.normal,
        color: AppColors.primary,
        fontFamily: _fontName,
      ),
      labelMedium: TextStyle(
        fontSize: ResponsiveConfig.getFontSize(context, 12.0),
        fontWeight: FontWeight.normal,
        color: AppColors.primary,
        fontFamily: _fontName,
      ),
    );
  }
}
