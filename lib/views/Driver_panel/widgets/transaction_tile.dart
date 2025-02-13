// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';

import '../../../utils/theme/app_colors.dart';

class TransactionTile extends StatelessWidget {
  final String transactionId;
  final String transactionAmount;
  const TransactionTile(
      {super.key,
      required this.transactionId,
      required this.transactionAmount});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22.5, vertical: 5),
      child: Container(
        height: screenHeight * 0.075,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transactionId,
                    style: const TextStyle(
                      color: Colors.black,
                      fontFamily: "Montserrat",
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const Text(
                    "Recieved money",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontFamily: "Montserrat",
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Text(
                transactionAmount,
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.w600,
                  fontSize: 32,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
