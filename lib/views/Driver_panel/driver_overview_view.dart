
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:rideapp/utils/routes/driver_panel_routes.dart';
import 'package:rideapp/utils/routes/user_panel_routes.dart';
import 'package:rideapp/utils/theme/app_colors.dart';


class DriverOverviewView extends StatelessWidget {
  const DriverOverviewView({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        SystemChannels.textInput.invokeMethod('TextInput.hide');
      },
      child: 
    Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 600;
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: constraints.maxWidth * 0.05,
                vertical: constraints.maxHeight * 0.08,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                          onPressed: () {
                         Navigator.pushReplacementNamed(context, AppRoutes.parcelScreen);
                          },
                          icon: const Icon(Icons.arrow_back_ios, color: Colors.white,)),
                    ],
                  ),
                  _buildEarnWithUsSection(constraints, isSmallScreen),
                  Padding(
                    padding: EdgeInsets.only(
                      left: constraints.maxWidth * 0.02,
                      top: constraints.maxHeight * 0.03,
                      bottom: constraints.maxHeight * 0.015,
                    ),
                    child: Text(
                      'driverOverview.services'.tr(),
                      style: TextStyle(
                        fontSize: isSmallScreen ? 18 : 22,
                        color: AppColors.backgroundLight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildServiceCard(
                    context,
                    title: 'driverOverview.serviceTypes.parcel',
                    imagePath: "assets/images/delevery.png",
                    onTap: () => Navigator.of(context).pushNamed(
                      AppDriverRoutes.driverSignupParcel,
                    ),
                    screenSize: constraints,
                  ),
                  // SizedBox(height: constraints.maxHeight * 0.04),
                  // _buildServiceCard(
                  //   context,
                  //   title: 'driverOverview.serviceTypes.bike',
                  //   imagePath: "assets/images/bike.png",
                  //   onTap: () => Navigator.of(context).pushNamed(
                  //     AppDriverRoutes.driverSignup,
                  //     arguments: "assets/images/bike.png",
                  //   ),
                  //   screenSize: constraints,
                  // ),
                ],
              ),
            ),
          );
        },
    )),
    );
  }

  Widget _buildEarnWithUsSection(
      BoxConstraints constraints, bool isSmallScreen) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: constraints.maxHeight * 0.25,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.amberAccent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: constraints.maxHeight * 0.04,
              horizontal: constraints.maxWidth * 0.05,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'driverOverview.earnWithUs.title'.tr(),
                  style: TextStyle(
                    fontSize: isSmallScreen ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.backgroundDark,
                  ),
                ),
                SizedBox(height: constraints.maxHeight * 0.015),
                _buildBulletPoint(
                    'driverOverview.earnWithUs.benefits.flexibleHours',
                    isSmallScreen),
                _buildBulletPoint(
                    'driverOverview.earnWithUs.benefits.yourPrices',
                    isSmallScreen),
                _buildBulletPoint(
                    'driverOverview.earnWithUs.benefits.lowPayments',
                    isSmallScreen),
              ],
            ),
          ),
        ),
        Positioned(
          top: -constraints.maxHeight * 0.07,
          right: -constraints.maxWidth * 0.07,
          child: Image.asset(
            "assets/images/earn_with_us.png",
            height: constraints.maxHeight * 0.25,
          ),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String textKey, bool isSmallScreen) {
    return Row(
      children: [
        Image.asset("assets/icons/right_bullet.png",
            width: isSmallScreen ? 16 : 20),
        const SizedBox(width: 5),
        Text(
          textKey.tr(),
          style: TextStyle(
            fontSize: isSmallScreen ? 12 : 14,
            color: AppColors.backgroundDark,
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCard(
    BuildContext context, {
    required String title,
    required String imagePath,
    required VoidCallback onTap,
    required BoxConstraints screenSize,
  }) {
    final isSmallScreen = screenSize.maxWidth < 600;

    return InkWell(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: screenSize.maxHeight * 0.19,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.amberAccent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: screenSize.maxHeight * 0.04,
                horizontal: screenSize.maxWidth * 0.05,
              ),
              child: Text(
                title.tr(),
                style: TextStyle(
                  fontSize: isSmallScreen ? 18 : 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.backgroundDark,
                ),
              ),
            ),
          ),
          Positioned(
            top: screenSize.maxHeight * 0.01,
            right: screenSize.maxWidth * 0.04,
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              height: screenSize.maxHeight * 0.18,
            ),
          ),
        ],
      ),
    );
  }
}

