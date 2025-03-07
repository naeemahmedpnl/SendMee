
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:sendme/viewmodel/provider/driver_registration_provider.dart';
import '../../../utils/theme/app_colors.dart';
import '../../../utils/theme/app_text_theme.dart';
import 'package:sendme/widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class BrandDetailsView extends StatefulWidget {
  const BrandDetailsView({super.key});

  @override
  State<BrandDetailsView> createState() => _BrandDetailsViewState();
}

class _BrandDetailsViewState extends State<BrandDetailsView> {
  final _brandNameController = TextEditingController();
  final _yearController = TextEditingController();
  final _colorController = TextEditingController();
  final _plateNumberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _loadSavedData();
      _isInitialized = true;
    }
  }

  void _loadSavedData() {
    final provider = Provider.of<DriverRegistrationProvider>(context, listen: false);
    setState(() {
      _brandNameController.text = provider.formData.motorcycleModel ?? '';
      _yearController.text = provider.formData.motorcycleYear ?? '';
      _colorController.text = provider.formData.motorcycleColor ?? '';
      _plateNumberController.text = provider.formData.motorcycleLicensePlateNumber ?? '';
    });
  }

  Future<void> _saveInfo() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    try {
      final provider = Provider.of<DriverRegistrationProvider>(
        context, 
        listen: false
      );

      final success = await provider.saveVehicleInfo(
        licensePlateNumber: _plateNumberController.text.trim(),
        color: _colorController.text.trim(),
        model: _brandNameController.text.trim(),
        year: _yearController.text.trim(),
        photos: provider.formData.motorcyclePhotos,
      );

      if (!mounted) return;

      _showMessage(
        success: success,
        successMessage: 'brandDetails.success.saved'.tr(),
        errorMessage: success ? '' : 
            provider.error != null ? 
            'brandDetails.errors.general'.tr(args: [provider.error!]) :
            'brandDetails.errors.saveFailed'.tr()
      );

      if (success) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showMessage(
        success: false,
        errorMessage: 'brandDetails.errors.general'.tr(args: [e.toString()])
      );
    }
  }

  void _showMessage({
    required bool success,
    String successMessage = "",
    String errorMessage = ""
  }) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: success ? AppColors.buttonColor : Colors.red,
        content: Row(
          children: [
            Icon(
              success ? Icons.check : Icons.error_outline,
              color: success ? Colors.black : Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                success ? successMessage : errorMessage,
                style: TextStyle(
                  color: success ? Colors.black : Colors.white,
                  fontFamily: "Montserrat",
                ),
              ),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        action: SnackBarAction(
          label: 'brandDetails.close'.tr(),
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  void dispose() {
    _brandNameController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    _plateNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'brandDetails.title'.tr(),
          style: AppTextTheme.getLightTextTheme(context).headlineSmall,
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.backgroundDark,
          ),
        ),
      ),
      body: Consumer<DriverRegistrationProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.04
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand Name Field
                    Text(
                      'brandDetails.brandName'.tr(),
                      style: AppTextTheme.getLightTextTheme(context).bodyLarge,
                    ),
                    SizedBox(height: screenHeight * 0.0075),
                    CustomTextFormField(
                      icon: Icons.directions_bike,
                      hintText: 'brandDetails.inputs.brandNameHint'.tr(),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'brandDetails.validation.brandNameRequired'.tr();
                        }
                        return null;
                      },
                      controller: _brandNameController,
                      onSaved: (value) {},
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // Year Field
                    Text(
                      'brandDetails.year'.tr(),
                      style: AppTextTheme.getLightTextTheme(context).bodyLarge,
                    ),
                    SizedBox(height: screenHeight * 0.0075),
                    CustomTextFormField(
                      icon: Icons.calendar_today,
                      hintText: 'brandDetails.inputs.yearHint'.tr(),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'brandDetails.validation.yearRequired'.tr();
                        }
                        // Additional year validation
                        final year = int.tryParse(value.trim());
                        if (year == null) {
                          return 'brandDetails.validation.yearInvalid'.tr();
                        }
                        final currentYear = DateTime.now().year;
                        if (year < 1900 || year > currentYear) {
                          return 'brandDetails.validation.yearRange'.tr();
                        }
                        return null;
                      },
                      controller: _yearController,
                      isNumber: true,
                      // keyboardType: TextInputType.number,
                      onSaved: (value) {},
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // Color Field
                    Text(
                      'brandDetails.color'.tr(),
                      style: AppTextTheme.getLightTextTheme(context).bodyLarge,
                    ),
                    SizedBox(height: screenHeight * 0.0075),
                    CustomTextFormField(
                      icon: Icons.color_lens,
                      hintText: 'brandDetails.inputs.colorHint'.tr(),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'brandDetails.validation.colorRequired'.tr();
                        }
                        return null;
                      },
                      controller: _colorController,
                      onSaved: (value) {},
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // Plate Number Field
                    Text(
                      'brandDetails.plateNumber'.tr(),
                      style: AppTextTheme.getLightTextTheme(context).bodyLarge,
                    ),
                    SizedBox(height: screenHeight * 0.0075),
                    CustomTextFormField(
                      icon: Icons.numbers,
                      hintText: 'brandDetails.inputs.plateNumberHint'.tr(),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'brandDetails.validation.plateNumberRequired'.tr();
                        }
                        return null;
                      },
                      controller: _plateNumberController,
                      onSaved: (value) {},
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    // Save Button
                    CustomButton(
                      text: 'brandDetails.save'.tr(),
                      textStyle: AppTextTheme.getLightTextTheme(context).bodyLarge!,
                      onPressed: _saveInfo,
                      borderRadius: 44,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}