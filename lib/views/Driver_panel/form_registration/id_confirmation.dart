import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:sendme/utils/theme/app_text_theme.dart';
import 'package:sendme/widgets/custom_button.dart';
import 'package:sendme/viewmodel/provider/driver_registration_provider.dart';
import '../../../utils/theme/app_colors.dart';

class IdConfirmation extends StatefulWidget {
  const IdConfirmation({super.key});

  @override
  State<IdConfirmation> createState() => _IdConfirmationState();
}

class _IdConfirmationState extends State<IdConfirmation> {
  final _cnicController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  File? _pickedFrontSideImageFile;
  File? _pickedBackSideImageFile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<DriverRegistrationProvider>(context, listen: false);
      if (provider.formData.voterID != null) {
        setState(() {
          _pickedFrontSideImageFile = File(provider.formData.voterID!);
        });
      }
      if (provider.formData.passport != null) {
        setState(() {
          _pickedBackSideImageFile = File(provider.formData.passport!);
        });
      }
    });
  }

  Future<void> _saveInfo() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    if (_pickedFrontSideImageFile == null || _pickedBackSideImageFile == null) {
      _showMessage(
        _pickedFrontSideImageFile == null && _pickedBackSideImageFile == null
            ? 'idConfirmation.errors.bothImages'
            : _pickedFrontSideImageFile == null
                ? 'idConfirmation.errors.frontImage'
                : 'idConfirmation.errors.backImage',
        true,
      );
      return;
    }

    final success = await Provider.of<DriverRegistrationProvider>(
      context,
      listen: false
    ).saveIdConfirmation(
      voterID: _pickedFrontSideImageFile!.path,
      passport: _pickedBackSideImageFile!.path,
    );

    _showMessage(
      success ? 'idConfirmation.success.saved' : 'idConfirmation.errors.saveFailed',
      !success,
    );

    if (success) {
      Navigator.of(context).pop();
    }
  }

  void _showMessage(String messageKey, bool isError) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? Colors.red : AppColors.primary,
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
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontFamily: "Montserrat",
                ),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'idConfirmation.close'.tr(),
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  Future<void> _pickFrontSideImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 150,
    );

    if (pickedImage == null) return;

    setState(() {
      _pickedFrontSideImageFile = File(pickedImage.path);
    });
  }

  Future<void> _pickBackSideImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 150,
    );

    if (pickedImage == null) return;

    setState(() {
      _pickedBackSideImageFile = File(pickedImage.path);
    });
  }

  @override
  void dispose() {
    _cnicController.dispose();
    super.dispose();
  }

  Widget _buildImagePicker({
    required BuildContext context,
    required String title,
    required File? imageFile,
    required Future<void> Function() onPickImage,
    required String placeholderImage,
  }) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      margin: EdgeInsets.symmetric(vertical: screenHeight * 0.03),
      height: screenHeight * 0.28,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          SizedBox(height: screenHeight * 0.01),
          Text(
            title.tr(),
            style: AppTextTheme.getLightTextTheme(context).bodyLarge,
          ),
          SizedBox(height: screenHeight * 0.008),
          Consumer<DriverRegistrationProvider>(
            builder: (context, provider, child) {
              final savedImage = title.contains("Voter")
                  ? provider.formData.voterID
                  : provider.formData.passport;
              final imageToShow = imageFile ?? (savedImage != null ? File(savedImage) : null);

              return Container(
                height: screenHeight * 0.15,
                width: screenWidth * 0.65,
                decoration: BoxDecoration(
                  border: imageToShow == null
                      ? Border.all(width: 1, color: Colors.black)
                      : Border.all(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: imageToShow == null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset(
                          placeholderImage,
                          fit: BoxFit.cover,
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.file(
                          imageToShow,
                          fit: BoxFit.fill,
                        ),
                      ),
              );
            },
          ),
          SizedBox(height: screenHeight * 0.001),
          TextButton(
            onPressed: onPickImage,
            style: TextButton.styleFrom(
              side: const BorderSide(width: 1, color: Colors.yellow),
              foregroundColor: Colors.black,
              fixedSize: const Size(165, 30),
            ),
            child: Text(
              'idConfirmation.addPhoto'.tr(),
              style: AppTextTheme.getLightTextTheme(context).bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'idConfirmation.title'.tr(),
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
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.055),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'idConfirmation.title'.tr(),
                  style: AppTextTheme.getDarkTextTheme(context).bodyLarge,
                ),
                SizedBox(height: screenHeight * 0.01),
                _buildImagePicker(
                  context: context,
                  title: 'idConfirmation.voterID',
                  imageFile: _pickedFrontSideImageFile,
                  onPickImage: _pickFrontSideImage,
                  placeholderImage: "assets/images/cnic_front.png",
                ),
                _buildImagePicker(
                  context: context,
                  title: 'idConfirmation.passport',
                  imageFile: _pickedBackSideImageFile,
                  onPickImage: _pickBackSideImage,
                  placeholderImage: "assets/images/cnic_back.png",
                ),
                SizedBox(height: screenHeight * 0.001),
                CustomButton(
                  text: 'idConfirmation.save'.tr(),
                  textStyle: AppTextTheme.getLightTextTheme(context).bodyLarge!,
                  onPressed: _saveInfo,
                  borderRadius: 44,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}