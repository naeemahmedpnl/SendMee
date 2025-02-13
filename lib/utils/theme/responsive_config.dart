import 'package:flutter/material.dart';

class ResponsiveConfig {
  static double getFontSize(BuildContext context, double baseSize) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 600) {
      return baseSize * 1.2;
    } else {
      return baseSize;
    }
  }
}