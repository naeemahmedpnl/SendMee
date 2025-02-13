

import 'dart:developer';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:sendme/utils/theme/app_colors.dart';
import 'package:sendme/utils/theme/app_text_theme.dart';
import 'package:sendme/viewmodel/provider/driver_registration_provider.dart';
import 'package:sendme/widgets/custom_button.dart';

class DriverLicenseService {
  final _imagePicker = ImagePicker();

  Future<File?> pickImage() async {
    final pickedImage = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
      maxWidth: double.maxFinite,
    );

    if (pickedImage == null) return null;
    return File(pickedImage.path);
  }
}

class DriverLicenseView extends StatefulWidget {
  const DriverLicenseView({super.key});

  @override
  State<DriverLicenseView> createState() => _DriverLicenseViewState();
}

class _DriverLicenseViewState extends State<DriverLicenseView> {
  final _formKey = GlobalKey<FormState>();
  final _licenseService = DriverLicenseService();
  late DriverRegistrationProvider _registrationProvider;
  File? _pickedImageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _registrationProvider = context.read<DriverRegistrationProvider>();
    _loadSavedImage();
    log('DriverLicenseView initialized');
  }

  void _loadSavedImage() {
    try {
      final savedPath = _registrationProvider.formData.driverLicense;
      if (savedPath != null) {
        setState(() {
          _pickedImageFile = File(savedPath);
        });
        log('Loaded saved driver license image from: $savedPath');
      }
    } catch (e) {
      log('Error loading saved image: $e');
    }
  }

  void _showMessage(String messageKey, bool isError, {List<String>? args}) {
    log('${isError ? 'Error' : 'Success'} message shown: $messageKey');
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? Colors.red : AppColors.buttonColor,
        content: Row(
          children: [
            Icon(isError ? Icons.error_outline : Icons.check, color: Colors.white),
            const SizedBox(width: 3),
            Expanded(
              child: Text(
                messageKey.tr(args: args),
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: "Montserrat",
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'driverLicense.close'.tr(),
          textColor: Colors.white,
          onPressed: () {
            log('Snackbar dismissed');
          },
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      setState(() => _isLoading = true);
      log('Starting image picker');
      
      final imageFile = await _licenseService.pickImage();
      
      if (imageFile != null) {
        setState(() {
          _pickedImageFile = imageFile;
          _isLoading = false;
        });
        log('Image picked successfully: ${imageFile.path}');
        log('Image size: ${(imageFile.lengthSync() / 1024).toStringAsFixed(2)} KB');
      } else {
        setState(() => _isLoading = false);
        log('No image selected');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      log('Error picking image: $e');
      _showMessage('driverLicense.errors.generalError', true, args: [e.toString()]);
    }
  }

  void _saveInfo() async {
    try {
      if (!_formKey.currentState!.validate()) {
        log('Form validation failed');
        return;
      }
      
      _formKey.currentState!.save();
      
      if (_pickedImageFile == null) {
        log('No image selected');
        _showMessage('driverLicense.errors.selectImage', true);
        return;
      }

      setState(() => _isLoading = true);
      log('Saving driver license image: ${_pickedImageFile!.path}');
      
      final success = await _registrationProvider.saveDriverLicense(_pickedImageFile!.path);
      
      if (success) {
        log('Driver license saved successfully');
        _showMessage('driverLicense.success.saved', false);
        Navigator.pop(context);
      } else {
        log('Error saving driver license: ${_registrationProvider.error}');
        _showMessage('driverLicense.errors.savingError', true, 
          args: [_registrationProvider.error?.toString() ?? '']);
      }
    } catch (e) {
      log('Error in save operation: $e');
      _showMessage('driverLicense.errors.generalError', true, args: [e.toString()]);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.06,
                  vertical: size.height * 0.02
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    _buildImageSection(context, size),
                    SizedBox(height: size.height * 0.03),
                    _buildSaveButton(context),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        'driverLicense.title'.tr(),
        style: AppTextTheme.getLightTextTheme(context).headlineSmall,
      ),
      centerTitle: true,
      leading: IconButton(
        onPressed: () {
          log('Navigating back');
          Navigator.of(context).pop();
        },
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: AppColors.backgroundDark,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'driverLicense.licenseNumber'.tr(),
          style: AppTextTheme.getDarkTextTheme(context).bodyLarge,
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildImageSection(BuildContext context, Size size) {
    return Container(
      height: size.height * 0.45,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(height: size.height * 0.02),
          Text(
            'driverLicense.frontLicense'.tr(),
            style: AppTextTheme.getLightTextTheme(context).bodyLarge,
          ),
          SizedBox(height: size.height * 0.01),
          _buildImagePreview(context, size),
          SizedBox(height: size.height * 0.02),
          _buildAddPhotoButton(context, size),
          if (_pickedImageFile != null) ...[
            const SizedBox(height: 8),
            Text(
              'driverLicense.imageSize'.tr(
                args: [(_pickedImageFile!.lengthSync() / 1024).toStringAsFixed(2)]
              ),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImagePreview(BuildContext context, Size size) {
    return Container(
      height: size.height * 0.2,
      width: size.width * 0.7,
      decoration: BoxDecoration(
        border: _pickedImageFile == null
            ? Border.all(width: 1, color: Colors.black)
            : Border.all(color: Colors.transparent),
        borderRadius: BorderRadius.circular(15),
      ),
      child: _pickedImageFile == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.image_outlined, 
                       size: 40, 
                       color:  Colors.black54),
                  const SizedBox(height: 8),
                  Text(
                    'driverLicense.noImage'.tr(),
                    style: AppTextTheme.getLightTextTheme(context).bodyMedium,
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.file(
                    _pickedImageFile!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _pickedImageFile = null;
                      });
                      log('Image removed');
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 20,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildAddPhotoButton(BuildContext context, Size size) {
    return TextButton(
      onPressed: _isLoading ? null : _pickImage,
      style: TextButton.styleFrom(
        side: BorderSide(
          width: 1, 
          color: _isLoading ? Colors.grey : Colors.yellow
        ),
        foregroundColor: _isLoading ? Colors.grey : Colors.black,
        fixedSize: Size(size.width * 0.4, size.height * 0.025),
      ),
      child: Text(
        _isLoading ? 'driverLicense.loading'.tr() : 'driverLicense.addPhoto'.tr(),
        style: AppTextTheme.getLightTextTheme(context).bodyMedium?.copyWith(
          color: _isLoading ? Colors.grey : null,
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return CustomButton(
      text: _isLoading ? 'driverLicense.saving'.tr() : 'driverLicense.save'.tr(),
      textStyle: AppTextTheme.getLightTextTheme(context).bodyLarge!,
      onPressed: _saveInfo,
      borderRadius: 44,
    );
  }
}