// import 'package:flutter/material.dart';
// import 'package:sendme/utils/theme/app_colors.dart';
// import 'package:sendme/utils/theme/app_text_theme.dart';
// import 'package:sendme/views/User_panel/profile_Screens/widgets/add_card_details.dart';
// import 'package:sendme/widgets/custom_button.dart';

// class EditProfileScreen extends StatefulWidget {
//   @override
//   _EditProfileScreenState createState() => _EditProfileScreenState();
// }

// class _EditProfileScreenState extends State<EditProfileScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController(text: 'Andriew Julia');
//   final _phoneController = TextEditingController(text: '+923150362310');
//   final _addressController = TextEditingController(
//       text: 'Gulshan-e-Jamal Block C Gulshan e Jamal, Karachi');

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _phoneController.dispose();
//     _addressController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 10),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       IconButton(
//                         onPressed: () {
//                           Navigator.pop(context);
//                         },
//                         icon: const Icon(
//                           Icons.arrow_back_ios_new_outlined,
//                           color: Colors.white,
//                           size: 30,
//                         ),
//                       ),
//                       Text(
//                         "Edit Profile",
//                         style: AppTextTheme.getDarkTextTheme(context)
//                             .headlineSmall,
//                       ),
//                       const SizedBox(width: 50),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 const CircleAvatar(
//                   radius: 50,
//                   backgroundImage: AssetImage('assets/images/profile.png'),
//                 ),
//                 const SizedBox(height: 8.0),
//                 TextFormField(
//                   controller: _nameController,
//                   decoration: InputDecoration(
//                     labelText: 'Name',
//                     border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10.0)),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your name';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16.0),
//                 TextFormField(
//                   controller: _phoneController,
//                   decoration: InputDecoration(
//                     labelText: 'Phone No',
//                     border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10.0)),
//                   ),
//                   keyboardType: TextInputType.phone,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your phone number';
//                     } else if (!RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(value)) {
//                       return 'Please enter a valid phone number';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16.0),
//                 TextFormField(
//                   controller: _addressController,
//                   decoration: InputDecoration(
//                     labelText: 'Address',
//                     border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10.0)),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your address';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16.0),
//                 SizedBox(
//                   width: double.infinity,
//                   child: CustomButton(
//                     text: "Save Changes",
//                     onPressed: () {
//                       if (_formKey.currentState?.validate() ?? false) {
//                         // Handle the form submission logic here
//                       }
//                     },
//                   ),
//                 ),
//                 const SizedBox(height: 16.0),
//                 GestureDetector(
//                   onTap: () {
//                     Navigator.push(context, MaterialPageRoute(builder: (context)=> const  AddCardDetailsView()));

//                     // showDialog(
//                     //   context: context,
//                     //   builder: (BuildContext context) {
//                     //     return Dialog(
//                     //       shape: RoundedRectangleBorder(
//                     //         borderRadius: BorderRadius.circular(15.0),
//                     //       ),
//                     //       child: AddCardDetailsForm(),
//                     //     );
//                     //   },
//                     // );
//                   },
//                   child: Container(
//                     width: double.infinity,
//                     height: 50,
//                     decoration: BoxDecoration(
//                       border: Border.all(
//                         color: AppColors.primary,
//                         width: 2.0,
//                       ),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: const Center(
//                       child: Text(
//                         "Add Card Details",
//                         style: TextStyle(
//                           color: AppColors.primary,
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 if (isKeyboardVisible)
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Text('Keyboard is visible'),
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // import 'package:flutter/material.dart';
// // // import 'package:provider/provider.dart';
// // import 'package:sendme/utils/theme/app_text_theme.dart';
// // // import 'package:sendme/viewmodel/user_provider/profile_provider.dart';
// // import 'package:sendme/widgets/custom_button.dart';

// // class EditProfileScreen extends StatefulWidget {
// //   @override
// //   _EditProfileScreenState createState() => _EditProfileScreenState();
// // }

// // class _EditProfileScreenState extends State<EditProfileScreen> {
// //   final _formKey = GlobalKey<FormState>();
// //   late String _userName;
// //   late String _phone;
// //   late String _email;
// //   late String _address;

// //   @override
// //   void initState() {
// //     super.initState();
// //     // final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
// //     // _userName = profileProvider.userName;
// //     // _phone = profileProvider.phone;
// //     // _email = profileProvider.email;
// //     // _address = profileProvider.address;
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     // final profileProvider = Provider.of<ProfileProvider>(context);

// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text("Edit Profile"),
// //         backgroundColor: Colors.black,
// //       ),
// //       body: Padding(
// //         padding: const EdgeInsets.all(16.0),
// //         child: Form(
// //           key: _formKey,
// //           child: SingleChildScrollView(
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Text(
// //                   'Edit your profile details',
// //                   style: AppTextTheme.getDarkTextTheme(context).bodyMedium,
// //                 ),
// //                 const SizedBox(height: 20.0),
// //                 TextFormField(
// //                   initialValue: _userName,
// //                   decoration: InputDecoration(
// //                     labelText: 'Name',
// //                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
// //                   ),
// //                   onChanged: (value) => _userName = value,
// //                   validator: (value) {
// //                     if (value == null || value.isEmpty) {
// //                       return 'Please enter your name';
// //                     }
// //                     return null;
// //                   },
// //                 ),
// //                 const SizedBox(height: 16.0),
// //                 TextFormField(
// //                   initialValue: _phone,
// //                   decoration: InputDecoration(
// //                     labelText: 'Phone Number',
// //                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
// //                   ),
// //                   onChanged: (value) => _phone = value,
// //                   validator: (value) {
// //                     if (value == null || value.isEmpty) {
// //                       return 'Please enter your phone number';
// //                     }
// //                     return null;
// //                   },
// //                 ),
// //                 const SizedBox(height: 16.0),
// //                 TextFormField(
// //                   initialValue: _email,
// //                   decoration: InputDecoration(
// //                     labelText: 'Email',
// //                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
// //                   ),
// //                   onChanged: (value) => _email = value,
// //                   validator: (value) {
// //                     if (value == null || value.isEmpty || !RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
// //                       return 'Please enter a valid email address';
// //                     }
// //                     return null;
// //                   },
// //                 ),
// //                 const SizedBox(height: 16.0),
// //                 TextFormField(
// //                   initialValue: _address,
// //                   decoration: InputDecoration(
// //                     labelText: 'Address',
// //                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
// //                   ),
// //                   onChanged: (value) => _address = value,
// //                   validator: (value) {
// //                     if (value == null || value.isEmpty) {
// //                       return 'Please enter your address';
// //                     }
// //                     return null;
// //                   },
// //                 ),
// //                 const SizedBox(height: 20.0),
// //                 SizedBox(
// //                   width: double.infinity,
// //                   child: CustomButton(
// //                     text: "Save Changes",
// //                     onPressed: () {
// //                       if (_formKey.currentState?.validate() ?? false) {
// //                         // profileProvider.updateProfile(_userName, _phone, _email, _address);
// //                         Navigator.pop(context);
// //                       }
// //                     },
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

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

  const EditProfileScreen({Key? key, required this.userData}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
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
