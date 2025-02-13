import 'package:flutter/material.dart';

import '../../../utils/theme/app_colors.dart';

class CustomSnackbar {
  static SnackBar buildCustomSnackbar({required String displayText}) {
    return SnackBar(
      backgroundColor: AppColors.primary,
      content: Row(
        children: [
          const Icon(
            Icons.check,
            color: Colors.green,
          ),
          const SizedBox(
            width: 5,
          ),
          Text(displayText),
        ],
      ),
      margin: const EdgeInsets.only(bottom: 5, right: 20, left: 20),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),

      // shape: ,
    );
  }
}
