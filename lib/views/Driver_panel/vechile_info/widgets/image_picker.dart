import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rideapp/utils/theme/app_text_theme.dart';

class ImagePickerWidget extends StatelessWidget {
  final File? imageFile;
  final String label;
  final Function() onPickImage;
  final BuildContext context;

  const ImagePickerWidget({
    required this.context,
    this.imageFile,
    required this.label,
    required this.onPickImage,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      margin: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
      height: screenHeight * 0.280,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
        child: Column(
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextTheme.getLightTextTheme(context).bodySmall,
            ),
            SizedBox(height: screenHeight * 0.008),
            Container(
              height: screenHeight * 0.14,
              width: screenWidth * 0.65,
              decoration: BoxDecoration(
                border: imageFile == null
                    ? Border.all(width: 1, color: Colors.black)
                    : Border.all(color: Colors.transparent),
                borderRadius: BorderRadius.circular(15),
              ),
              child: imageFile == null
                  ? Center(
                      child: Text(
                        "No image selected!",
                        style: AppTextTheme.getLightTextTheme(context).bodyMedium,
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.file(
                        imageFile!,
                        fit: BoxFit.fill,
                      ),
                    ),
            ),
            SizedBox(height: screenHeight * 0.015),
            TextButton(
              onPressed: onPickImage,
              style: TextButton.styleFrom(
                side: const BorderSide(width: 1, color: Colors.yellow),
                foregroundColor: Colors.black,
                fixedSize: const Size(165, 30),
              ),
              child: Text(
                "Add a photo",
                style: AppTextTheme.getLightTextTheme(context).bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
