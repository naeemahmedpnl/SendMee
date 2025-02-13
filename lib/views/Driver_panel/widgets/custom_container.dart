import 'package:flutter/material.dart';

import '../../../utils/theme/app_colors.dart';

class CustomContainer extends StatelessWidget {
  final String imagePath;
  final double imageHeight;
  const CustomContainer(
      {super.key, required this.imagePath, required this.imageHeight});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none, // Ensure overflow is visible
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.amberAccent,
            borderRadius: BorderRadius.circular(20),
          ),
          // ignore: prefer_const_constructors
          child: Padding(
            padding: const EdgeInsets.only(top: 30, bottom: 40, left: 20),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Earn with us',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.backgroundDark,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'This is a custom container',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.backgroundDark,
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top:
              -90, // Adjust to bring the top part of the image above the container
          right: 15,
          // bottom: -0.95,
          child: Align(
            child: Image.asset(
              imagePath, // Adjust the path as per your actual asset location
              fit: BoxFit.cover,
              height: imageHeight, // Exact height of the image
            ),
          ),
        ),
      ],
    );
  }
}
