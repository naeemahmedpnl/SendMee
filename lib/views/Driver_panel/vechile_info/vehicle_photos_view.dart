
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rideapp/viewmodel/provider/driver_registration_provider.dart';
import '../../../utils/theme/app_colors.dart';
import '../../../utils/theme/app_text_theme.dart';
import 'package:rideapp/widgets/custom_button.dart';

class VehiclePhotosView extends StatefulWidget {
  const VehiclePhotosView({super.key});

  @override
  State<VehiclePhotosView> createState() => _VehiclePhotosViewState();
}

class _VehiclePhotosViewState extends State<VehiclePhotosView> {
  final List<File?> _pickedImageFiles = List.generate(2, (_) => null);

  @override
  void initState() {
    super.initState();
    _loadSavedImages();
  }

  void _loadSavedImages() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<DriverRegistrationProvider>(context, listen: false);
      final savedPhotos = provider.formData.motorcyclePhotos;
      
      if (savedPhotos.isNotEmpty) {
        for (int i = 0; i < savedPhotos.length && i < 2; i++) {
          final file = File(savedPhotos[i]);
          if (file.existsSync()) {
            setState(() {
              _pickedImageFiles[i] = file;
            });
          }
        }
      }
    });
  }

  Future<void> _saveInfo() async {
    if (_pickedImageFiles.every((file) => file == null)) {
      _showMessage('vehiclePhotos.errors.selectImage'.tr(), false);
      return;
    }

    try {
      final provider = Provider.of<DriverRegistrationProvider>(
        context, 
        listen: false
      );
      
      final photoPaths = _pickedImageFiles
          .where((file) => file != null)
          .map((file) => file!.path)
          .toList();

      final success = await provider.saveVehicleInfo(
        licensePlateNumber: provider.formData.motorcycleLicensePlateNumber ?? '',
        color: provider.formData.motorcycleColor ?? '',
        year: provider.formData.motorcycleYear ?? '',
        model: provider.formData.motorcycleModel ?? '',
        photos: photoPaths,
      );

      if (!mounted) return;
      
      _showMessage(
        success ? 'vehiclePhotos.success.saved'.tr() : 
        provider.error != null ? 
            'vehiclePhotos.errors.generalError'.tr(args: [provider.error!]) :
            'vehiclePhotos.errors.saveFailed'.tr(),
        success
      );
      
      if (success) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showMessage('vehiclePhotos.errors.generalError'.tr(args: [e.toString()]), false);
    }
  }

  Future<void> _pickImage(int index) async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 150,
    );

    if (pickedImage != null) {
      setState(() {
        _pickedImageFiles[index] = File(pickedImage.path);
      });
    }
  }

  void _showMessage(String message, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: success ? AppColors.primary : Colors.red,
        content: Row(
          children: [
            Icon(success ? Icons.check : Icons.error_outline),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: success ? Colors.black : Colors.white,
                  fontFamily: "Montserrat",
                ),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'vehiclePhotos.close'.tr(),
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  Widget _buildPhotoCard(int index, String titleKey) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.02),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            titleKey.tr(),
            style: AppTextTheme.getLightTextTheme(context).bodyLarge,
          ),
          const SizedBox(height: 8),
          Container(
            height: MediaQuery.of(context).size.height * 0.15,
            width: MediaQuery.of(context).size.width * 0.65,
            decoration: BoxDecoration(
              border: _pickedImageFiles[index] == null
                  ? Border.all(width: 1, color: Colors.black)
                  : Border.all(color: Colors.transparent),
              borderRadius: BorderRadius.circular(15),
            ),
            child: _pickedImageFiles[index] == null
                ? Center(
                    child: Text(
                      'vehiclePhotos.noImage'.tr(),
                      style: AppTextTheme.getLightTextTheme(context).bodyMedium,
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(
                      _pickedImageFiles[index]!,
                      fit: BoxFit.cover,
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => _pickImage(index),
            style: TextButton.styleFrom(
              side: const BorderSide(width: 1, color: Colors.yellow),
              foregroundColor: Colors.black,
            ),
            child: Text(
              'vehiclePhotos.addPhoto'.tr(),
              style: AppTextTheme.getLightTextTheme(context).bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'vehiclePhotos.title'.tr(),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildPhotoCard(0, 'vehiclePhotos.frontView'),
            const SizedBox(height: 16),
            _buildPhotoCard(1, 'vehiclePhotos.backView'),
            const SizedBox(height: 24),
            CustomButton(
              text: 'vehiclePhotos.save'.tr(),
              textStyle: AppTextTheme.getLightTextTheme(context).bodyLarge!,
              onPressed: _saveInfo,
              borderRadius: 44,
            ),
          ],
        ),
      ),
    );
  }
}