
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:sendme/utils/theme/app_text_theme.dart';
import 'package:sendme/viewmodel/provider/auth_provider/auth_provider.dart';
import 'package:sendme/widgets/custom_button.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfileScreen({super.key, required this.userData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.userData['username'] ?? '');
    _phoneController =
        TextEditingController(text: widget.userData['phone'] ?? '');
    _addressController =
        TextEditingController(text: widget.userData['address'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      try {
        await authProvider.updateProfile(
          name: _nameController.text,
          address: _addressController.text,
          profilePicture: _imageFile,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new_outlined,
                            color: Colors.white, size: 30),
                      ),
                      Text("edit_profile.title".tr(),
                          style: AppTextTheme.getDarkTextTheme(context)
                              .headlineSmall),
                      const SizedBox(width: 50),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : (widget.userData['profilePicture'] != null
                            ? NetworkImage(widget.userData['profilePicture'])
                            : const AssetImage(
                                'assets/images/profile.png')) as ImageProvider,
                    child: _imageFile == null
                        ? const Icon(Icons.camera_alt,
                            size: 30, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'edit_profile.name_label'.tr(),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                  ),
                  validator: (value) => value?.isEmpty ?? true
                      ? 'edit_profile.name_validation'.tr()
                      : null,
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'edit_profile.phone_label'.tr(),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                  ),
                  keyboardType: TextInputType.phone,
                  readOnly: true,
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'edit_profile.address_label'.tr(),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                  ),
                  validator: (value) => value?.isEmpty ?? true
                      ? 'edit_profile.address_validation'.tr()
                      : null,
                ),
                const SizedBox(height: 24.0),
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: "edit_profile.save_button".tr(),
                    onPressed: _updateProfile,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
