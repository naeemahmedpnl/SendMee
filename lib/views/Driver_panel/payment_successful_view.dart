
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:sendme/utils/routes/driver_panel_routes.dart';
import 'package:sendme/utils/theme/app_colors.dart';
import 'package:sendme/widgets/custom_button.dart';

class PaymentSuccessfulView extends StatelessWidget {
  const PaymentSuccessfulView({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.065),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/payment.png"),
            SizedBox(height: screenHeight * 0.06),
            Text(
              'paymentSuccessful.message'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.kGreyColor,
                fontSize: 20,
                fontFamily: "Montserrat",
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: screenHeight * 0.050),
            CustomButton(
              text: 'paymentSuccessful.close'.tr(),
              onPressed: () {
                Navigator.pushReplacementNamed(context, AppDriverRoutes.driverreview);
              },
              borderRadius: 12,
              textStyle: const TextStyle(
                fontFamily: "Montserrat",
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}