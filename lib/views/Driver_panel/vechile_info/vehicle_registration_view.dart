import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sendme/utils/routes/driver_panel_routes.dart';
import 'package:sendme/utils/theme/app_colors.dart';
import 'package:sendme/utils/theme/app_text_theme.dart';
import 'package:sendme/views/Driver_panel/vechile_info/widgets/registration_form_widget.dart';
import 'package:sendme/widgets/custom_button.dart';

class VehicleRegistrationView extends StatefulWidget {
  const VehicleRegistrationView({super.key});

  @override
  State<VehicleRegistrationView> createState() => _VehicleRegistrationViewState();
}

class _VehicleRegistrationViewState extends State<VehicleRegistrationView> {
  final _vehicleRegistrationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  File? _pickedFrontSideImageFile;
  File? _pickedBackSideImageFile;

  void _saveInfo() {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState!.save();
    ScaffoldMessenger.of(context).clearSnackBars();

    if (_pickedFrontSideImageFile != null && _pickedBackSideImageFile != null) {
      _showSuccessDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xffff3333),
          content: Row(
            children: [
              const Icon(Icons.error_outline),
              const SizedBox(width: 3),
              Text(
                _pickedFrontSideImageFile == null && _pickedBackSideImageFile == null
                    ? "Please select front and back side images!"
                    : _pickedFrontSideImageFile == null
                        ? "Please select front side image!"
                        : "Please select back side image!",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontFamily: "Montserrat",
                ),
              ),
            ],
          ),
          action: SnackBarAction(
            label: "Close",
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      barrierColor: Colors.black.withOpacity(0.5),
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Congratulations",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Image.asset(
                width: 150,
                height: 150,
              "assets/images/success.png",
            ),
            const SizedBox(height: 20),
            
            const SizedBox(height: 10),
            const Text("Your verification has been \ncompleted", textAlign: TextAlign.center),
            const SizedBox(height: 20),
            CustomButton(text: "Done", onPressed: (){
              Navigator.pushReplacementNamed(context, AppDriverRoutes.rideBooking);
            },
            borderRadius: 44,)
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(bool isFrontSide) async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
      maxWidth: double.maxFinite,
    );

    if (pickedImage == null) {
      return;
    }

    setState(() {
      if (isFrontSide) {
        _pickedFrontSideImageFile = File(pickedImage.path);
      } else {
        _pickedBackSideImageFile = File(pickedImage.path);
      }
    });
  }

  @override
  void dispose() {
    _vehicleRegistrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0.0,
        backgroundColor: AppColors.backgroundDark,
        title: Text(
          "Photos of vehicle",
          style: AppTextTheme.getDarkTextTheme(context).headlineSmall,
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.backgroundLight,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: RegistrationFormWidget(
          controller: _vehicleRegistrationController,
          formKey: _formKey,
          onSave: _saveInfo,
          onPickFrontSideImage: () => _pickImage(true),
          onPickBackSideImage: () => _pickImage(false),
          pickedFrontSideImage: _pickedFrontSideImageFile,
          pickedBackSideImage: _pickedBackSideImageFile,
        ),
      ),
    );
  }
}
