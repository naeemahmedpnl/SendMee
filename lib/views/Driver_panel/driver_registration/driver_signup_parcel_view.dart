import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rideapp/models/driver_registration_model.dart';
import 'package:rideapp/utils/routes/user_panel_routes.dart';
import 'package:rideapp/utils/theme/app_colors.dart';
import 'package:rideapp/viewmodel/provider/auth_provider/auth_provider.dart';
import 'package:rideapp/viewmodel/provider/driver_registration_provider.dart';
import 'package:rideapp/views/Driver_panel/widgets/option_tile.dart';
import 'package:rideapp/widgets/custom_button.dart';

import '../../../utils/routes/driver_panel_routes.dart';
import '../../../utils/theme/app_text_theme.dart';

class DriverSignupParcelView extends StatefulWidget {
  const DriverSignupParcelView({super.key});

  @override
  State<DriverSignupParcelView> createState() => _DriverSignupParcelViewState();
}

class _DriverSignupParcelViewState extends State<DriverSignupParcelView> {
  bool _isSubmitting = false;

  Future<void> _submitRegistration() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final provider =
          Provider.of<DriverRegistrationProvider>(context, listen: false);

      final formData = provider.formData;
      if (!_validateFormData(formData)) {
        _showMessage('driverSignupParcel.errors.incompleteRegistration'.tr(), false);
        return;
      }

      final success = await provider.submitRegistration();

      if (!mounted) return;

      if (success) {
        _showSuccessDialog();
      } else {
        _showMessage(
          provider.error ?? 'driverSignupParcel.errors.registrationFailed'.tr(),
          false,
        );
      }
    } catch (e) {
      _showMessage('driverSignupParcel.errors.genericError'.tr(), false);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

 void _showSuccessDialog() {
  showDialog(
    barrierColor: Colors.white.withOpacity(0.5),
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: const  Color(0xFFEEEEEE),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.all(20),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'driverSignupParcel.congratulations'.tr(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Image.asset(
            "assets/images/success.png",
            width: 150,
            height: 150,
          ),
          const SizedBox(height: 20),
          Text(
            'driverSignupParcel.verificationCompleted'.tr(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          CustomButton(
            text: 'driverSignupParcel.actions.done'.tr(),
            onPressed: () async {
              try {
                // Show loading
                Navigator.pop(context); 
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  ),
                );

                // Get fresh user data
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                await authProvider.fetchUserData();

                // Navigate after getting fresh data
                if (context.mounted) {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, AppRoutes.parcelScreen);
                }
              } catch (e) {
                log("❌ Error fetching user data: $e");
                if (context.mounted) {
                  Navigator.pop(context); 
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('error.fetch_user_data'.tr())),
                  );
                  // Navigate anyway after error
                  Navigator.pushReplacementNamed(context, AppRoutes.parcelScreen);
                }
              }
            },
            borderRadius: 44,
          )
        ],
      ),
    ),
  );
}

  bool _validateFormData(DriverRegistrationModel formData) {
    return formData.username != null &&
        formData.address != null &&
        formData.dob != null &&
        formData.phone != null &&
        formData.profilePicture != null &&
        formData.driverLicense != null &&
        formData.voterID != null &&
        formData.proofOfAddress != null &&
        formData.motorcycleLicensePlateNumber != null &&
        formData.motorcycleColor != null &&
        formData.motorcycleYear != null &&
        formData.motorcycleModel != null &&
        (formData.motorcyclePhotos.isNotEmpty);
  }

  void _showMessage(String message, bool success) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: success ? AppColors.primary : Colors.red,
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle : Icons.error_outline,
              color: Colors.black,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: "Montserrat",
                ),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'driverSignupParcel.actions.close'.tr(),
          textColor: Colors.black,
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('driverSignupParcel.registration'.tr()),
        centerTitle: true,
        backgroundColor: AppColors.backgroundLight,
      ),  
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Image.asset(
                      "assets/images/deliverybox.png",
                      height: screenHeight * 0.40,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                Expanded(
                  flex: 8,
                  child: Container(
                    height: screenHeight,
                    width: screenWidth,
                    decoration: const BoxDecoration(
                      color: AppColors.backgroundLight,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: screenWidth * 0.050,
                        right: screenWidth * 0.050,
                        top: screenHeight * 0.025,
                      ),
                      child: Column(
                        children: [
                          Text(
                            'driverSignupParcel.registration'.tr(),
                            style: AppTextTheme.getLightTextTheme(context).headlineLarge,
                          ),
                          SizedBox(height: screenHeight * 0.020),
                          Container(
                            height: screenHeight * 0.49,
                            width: screenWidth * 0.88,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                OptionTile(
                                  title: 'driverSignupParcel.basicIntro'.tr(),
                                  onTap: () => Navigator.of(context)
                                      .pushNamed(AppDriverRoutes.basicInfo),
                                ),
                                OptionTile(
                                  title: 'driverSignupParcel.driverLicense'.tr(),
                                  onTap: () => Navigator.of(context)
                                      .pushNamed(AppDriverRoutes.driverLicense),
                                ),
                                OptionTile(
                                  title: 'driverSignupParcel.proofOfAddress'.tr(),
                                  onTap: () => Navigator.of(context)
                                      .pushNamed(AppDriverRoutes.idInfo),
                                ),
                                OptionTile(
                                  title: 'driverSignupParcel.idConfirmation'.tr(),
                                  onTap: () => Navigator.of(context)
                                      .pushNamed(AppDriverRoutes.cnicInfo),
                                ),
                                OptionTile(
                                  title: 'driverSignupParcel.vehicleInfo'.tr(),
                                  onTap: () => Navigator.of(context)
                                      .pushNamed(AppDriverRoutes.vehicleInfo),
                                  showDivider: false,
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: CustomButton(
                              text: _isSubmitting
                                  ? 'driverSignupParcel.submitting'.tr()
                                  : 'driverSignupParcel.done'.tr(),
                              textStyle: AppTextTheme.getLightTextTheme(context).bodyLarge!,
                              onPressed: _submitRegistration,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
           
          ],
        ),
      ),
    );
  }
}