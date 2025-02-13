

// Updated ProofOfAddress.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:sendme/utils/theme/app_text_theme.dart';
import 'package:sendme/viewmodel/provider/driver_registration_provider.dart';
import 'package:sendme/widgets/custom_button.dart';
import '../../../utils/theme/app_colors.dart';

class ProofOfAddress extends StatefulWidget {
  const ProofOfAddress({super.key});

  @override
  State<ProofOfAddress> createState() => _ProofOfAddressState();
}

class _ProofOfAddressState extends State<ProofOfAddress> {
  File? _pickedImageFile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<DriverRegistrationProvider>(context, listen: false);
      if (provider.formData.proofOfAddress != null) {
        setState(() {
          _pickedImageFile = File(provider.formData.proofOfAddress!);
        });
      }
    });
  }

  void _showMessage(String messageKey, bool isError) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? Colors.red : AppColors.buttonColor,
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                messageKey.tr(),
                style: AppTextTheme.getLightTextTheme(context).bodyMedium?.copyWith(
                  color: Colors.white,
                  fontFamily: "Montserrat",
                ),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'proofOfAddress.close'.tr(),
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 150,
    );

    if (pickedImage == null) return;

    setState(() {
      _pickedImageFile = File(pickedImage.path);
    });
  }

  void _saveInfo() async {
    if (_pickedImageFile == null) {
      _showMessage('proofOfAddress.errors.selectImage', true);
      return;
    }

    final success = await Provider.of<DriverRegistrationProvider>(
      context,
      listen: false,
    ).saveProofOfAddress(_pickedImageFile!.path);

    _showMessage(
      success ? 'proofOfAddress.success.saved' : 'proofOfAddress.errors.saveFailed',
      !success,
    );

    if (success) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'proofOfAddress.title'.tr(),
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
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.045,
          vertical: screenHeight * 0.01,
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 20),
              height: screenHeight * 0.6,
              decoration: BoxDecoration(
                // ignore: prefer_const_constructors
                color: Color(0xFFEEEEEE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Container(
                      height: screenHeight * 0.2,
                      width: 320,
                      decoration: BoxDecoration(
                        border: _pickedImageFile == null
                            ? Border.all(width: 1, color: Colors.black)
                            : Border.all(color: Colors.transparent),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Consumer<DriverRegistrationProvider>(
                        builder: (context, provider, child) {
                          final savedImage = provider.formData.proofOfAddress;
                          final imageToShow = _pickedImageFile ??
                              (savedImage != null ? File(savedImage) : null);

                          return imageToShow == null
                              ? Center(
                                  child: Text(
                                    'proofOfAddress.noImage'.tr(),
                                    style: AppTextTheme.getLightTextTheme(context)
                                        .bodyMedium,
                                  ),
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.file(
                                    imageToShow,
                                    fit: BoxFit.fill,
                                  ),
                                );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.001),
                  TextButton(
                    onPressed: _pickImage,
                    style: TextButton.styleFrom(
                      side: const BorderSide(width: 1, color: Colors.yellow),
                      foregroundColor: Colors.black,
                      fixedSize: const Size(165, 30),
                    ),
                    child: Text(
                      'proofOfAddress.addPhoto'.tr(),
                      style: AppTextTheme.getLightTextTheme(context).bodyMedium,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(screenHeight * 0.025),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'proofOfAddress.guidelines.faceAndLicense'.tr(),
                          style: AppTextTheme.getLightTextTheme(context).titleMedium,
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Text(
                          'proofOfAddress.guidelines.quality'.tr(),
                          style: AppTextTheme.getLightTextTheme(context).titleMedium,
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Text(
                          'proofOfAddress.guidelines.sunglasses'.tr(),
                          style: AppTextTheme.getLightTextTheme(context).titleMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 35),
            CustomButton(
              text: 'proofOfAddress.save'.tr(),
              textStyle: AppTextTheme.getLightTextTheme(context).bodyLarge!,
              onPressed: _saveInfo,
              borderRadius: 45,
            ),
          ],
        ),
      ),
    );
  }
}