
// Updated VehicleInfoView.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:rideapp/utils/theme/app_text_theme.dart';
import 'package:rideapp/views/Driver_panel/widgets/option_tile.dart';
import 'package:rideapp/widgets/custom_button.dart';

import '../../../utils/routes/driver_panel_routes.dart';
import '../../../utils/theme/app_colors.dart';

class VehicleInfoView extends StatefulWidget {
  const VehicleInfoView({super.key});

  @override
  State<VehicleInfoView> createState() => _VehicleInfoViewState();
}

class _VehicleInfoViewState extends State<VehicleInfoView> {
  final _formKey = GlobalKey<FormState>();

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primary,
        content: Row(
          children: [
            const Icon(Icons.check),
            const SizedBox(width: 5),
            Text('vehicleInfo.success.saved'.tr()),
          ],
        ),
        margin: const EdgeInsets.only(bottom: 5, right: 20, left: 20),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _saveNumberPlateNumber() {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState!.save();
    Navigator.of(context).pop();
    _showSuccessMessage();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'vehicleInfo.title'.tr(),
          style: AppTextTheme.getLightTextTheme(context).headlineSmall,
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.backgroundDark,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: screenHeight * 0.001),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 10,
                ),
                child: Container(
                  height: screenHeight * 0.25,
                  width: screenWidth * 0.875,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OptionTile(
                        title: 'vehicleInfo.selectBrand'.tr(),
                        onTap: () => Navigator.of(context)
                            .pushNamed(AppDriverRoutes.brandDetails),
                      ),
                      OptionTile(
                        title: 'vehicleInfo.vehiclePhotos'.tr(),
                        onTap: () => Navigator.of(context)
                            .pushNamed(AppDriverRoutes.vehiclePhotos),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.001),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: CustomButton(
                  text: 'vehicleInfo.save'.tr(),
                  textStyle: AppTextTheme.getLightTextTheme(context).bodyLarge!,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  borderRadius: 44,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

