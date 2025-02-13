

// // import 'dart:io';

// // import 'package:easy_localization/easy_localization.dart';
// // import 'package:flutter/material.dart';
// // import 'package:image_picker/image_picker.dart';
// // import 'package:provider/provider.dart';
// // import 'package:rideapp/utils/theme/app_text_theme.dart';
// // import 'package:rideapp/viewmodel/provider/driver_registration_provider.dart';
// // import 'package:rideapp/widgets/custom_button.dart';

// // import '../../../utils/theme/app_colors.dart';
// // import '../widgets/custom_text_field.dart';

// // class BasicInfoView extends StatefulWidget {
// //   const BasicInfoView({Key? key}) : super(key: key);

// //   @override
// //   _BasicInfoViewState createState() => _BasicInfoViewState();
// // }

// // class _BasicInfoViewState extends State<BasicInfoView> {
// //   final _userNameController = TextEditingController();
// //   final _phoneNumberController = TextEditingController();
// //   final _passwordController = TextEditingController();
// //   final _emailController = TextEditingController();
// //   File? _pickedImageFile;
// //   final _formKey = GlobalKey<FormState>();

// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadSavedData();
// //   }

// //   Future<void> _loadSavedData() async {
// //     final provider =
// //         Provider.of<DriverRegistrationProvider>(context, listen: false);
// //     final savedData = provider.formData;

// //     if (savedData.username != null) {
// //       _userNameController.text = savedData.username!;
// //     }
// //     if (savedData.phone != null) {
// //       _phoneNumberController.text = savedData.phone!;
// //     }
// //     if (savedData.password != null) {
// //       _passwordController.text = savedData.password!;
// //     }
// //     if (savedData.email != null) {
// //       _emailController.text = savedData.email!;
// //     }
// //     if (savedData.profilePicture != null) {
// //       setState(() {
// //         _pickedImageFile = File(savedData.profilePicture!);
// //       });
// //     }
// //   }

// //   @override
// //   void dispose() {
// //     _userNameController.dispose();
// //     _phoneNumberController.dispose();
// //     _passwordController.dispose();
// //     _emailController.dispose();
// //     super.dispose();
// //   }

// //   Future<void> _pickImage() async {
// //     final pickedImage = await ImagePicker().pickImage(
// //       source: ImageSource.camera,
// //       imageQuality: 100,
// //       maxWidth: double.maxFinite,
// //     );

// //     if (pickedImage != null) {
// //       setState(() {
// //         _pickedImageFile = File(pickedImage.path);
// //       });
// //     }
// //   }

// //   Future<void> _saveInfo() async {
// //     final isValid = _formKey.currentState!.validate();
// //     if (!isValid || _pickedImageFile == null) {
// //       _showSnackBar('basicInfo.fillRequired'.tr(), Colors.red);
// //       return;
// //     }

// //     try {
// //       final provider =
// //           Provider.of<DriverRegistrationProvider>(context, listen: false);

// //       final success = await provider.saveBasicInfo(
// //         username: _userNameController.text,
// //         phone: _phoneNumberController.text,
// //         profilePicture: _pickedImageFile!.path,
// //       );

// //       if (success) {
// //         _showSnackBar('basicInfo.saveSuccess'.tr(), AppColors.buttonColor);
// //         Navigator.pop(context);
// //       } else {
// //         _showSnackBar('basicInfo.saveFailed'.tr(), Colors.red);
// //       }
// //     } catch (e) {
// //       _showSnackBar('basicInfo.error'.tr(args: [e.toString()]), Colors.red);
// //     }
// //   }

// //   void _showSnackBar(String message, Color backgroundColor) {
// //     ScaffoldMessenger.of(context).clearSnackBars();
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         backgroundColor: backgroundColor,
// //         content: Row(
// //           children: [
// //             Icon(
// //               backgroundColor == Colors.red ? Icons.info : Icons.check,
// //               color: Colors.white,
// //             ),
// //             const SizedBox(width: 3),
// //             Text(
// //               message,
// //               style: const TextStyle(
// //                 color: Colors.white,
// //                 fontFamily: "Montserrat",
// //               ),
// //             ),
// //           ],
// //         ),
// //         action: SnackBarAction(
// //           label: 'basicInfo.close'.tr(),
// //           textColor: Colors.white,
// //           onPressed: () {},
// //         ),
// //       ),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final screenWidth = MediaQuery.of(context).size.width;
// //     final screenHeight = MediaQuery.of(context).size.height;

// //     return Scaffold(
// //       appBar: AppBar(
// //         backgroundColor: AppColors.backgroundDark,
// //         title: Text(
// //           'basicInfo.title'.tr(),
// //           style: AppTextTheme.getDarkTextTheme(context).headlineSmall,
// //         ),
// //         centerTitle: true,
// //         leading: IconButton(
// //           onPressed: () {
// //             Navigator.of(context).pop();
// //           },
// //           icon: const Icon(
// //             Icons.arrow_back_ios_new,
// //             color: AppColors.backgroundLight,
// //           ),
// //         ),
// //       ),
// //       body: Consumer<DriverRegistrationProvider>(
// //         builder: (context, provider, child) {
// //           if (provider.isLoading) {
// //             return const Center(child: CircularProgressIndicator());
// //           }

// //           return SingleChildScrollView(
// //             child: Form(
// //               key: _formKey,
// //               child: Padding(
// //                 padding: EdgeInsets.symmetric(
// //                     horizontal: screenWidth * 0.08,
// //                     vertical: screenHeight * 0.015),
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     _buildImagePicker(),
// //                     const SizedBox(height: 12),
// //                     _buildTextField(
// //                       label: "userName",
// //                       controller: _userNameController,
// //                       validator: (value) => value!.isEmpty
// //                           ? 'basicInfo.userNameRequired'.tr()
// //                           : null,
// //                       prefixIcon: Icons.account_circle,
// //                     ),
// //                     const SizedBox(height: 15),
// //                     _buildTextField(
// //                       label: "phoneNumber",
// //                       controller: _phoneNumberController,
// //                       validator: (value) => value!.isEmpty
// //                           ? 'basicInfo.phoneRequired'.tr()
// //                           : null,
// //                       prefixIcon: Icons.phone,
// //                     ),
// //                     const SizedBox(height: 15),
// //                     _buildTextField(
// //                       label: "password",
// //                       controller: _passwordController,
// //                       validator: (value) => value!.isEmpty
// //                           ? 'basicInfo.passwordRequired'.tr()
// //                           : null,
// //                       prefixIcon: Icons.lock,
// //                     ),
// //                     const SizedBox(height: 15),
// //                     _buildTextField(
// //                       label: "email",
// //                       controller: _emailController,
// //                       validator: (value) {
// //                         if (value != null && value.isNotEmpty) {
// //                           String pattern =
// //                               r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$';
// //                           RegExp regex = RegExp(pattern);
// //                           if (!regex.hasMatch(value)) {
// //                             return 'basicInfo.invalidEmail'.tr();
// //                           }
// //                         }
// //                         return null;
// //                       },
// //                       prefixIcon: Icons.email,
// //                     ),
// //                     const SizedBox(height: 35),
// //                     CustomButton(
// //                       text: 'basicInfo.save'.tr(),
// //                       textStyle:
// //                           AppTextTheme.getLightTextTheme(context).bodyLarge!,
// //                       onPressed: _saveInfo,
// //                       borderRadius: 45,
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           );
// //         },
// //       ),
// //     );
// //   }
  
// //    Widget _buildImagePicker() {
// //     return Stack(
// //       children: [
// //         Align(
// //           alignment: Alignment.center,
// //           child: CircleAvatar(
// //             backgroundColor: Colors.transparent,
// //             radius: 50,
// //             foregroundImage: _pickedImageFile != null
// //                 ? FileImage(_pickedImageFile!)
// //                 : const AssetImage('assets/icons/user_account_icon.png') as ImageProvider,
// //           ),
// //         ),
// //         Positioned(
// //           bottom: -10,
// //           right: 140,
// //           child: IconButton(
// //             onPressed: _pickImage,
// //             icon: const Icon(
// //               Icons.camera_alt,
// //               color: Colors.black,
// //               size: 20,
// //             ),
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildTextField({
// //     required String label,
// //     required TextEditingController controller,
// //     required String? Function(String?) validator,
// //     required IconData prefixIcon,
// //   }) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(
// //           'basicInfo.$label'.tr(),
// //           style: AppTextTheme.getDarkTextTheme(context).bodyLarge,
// //         ),
// //         const SizedBox(height: 10),
// //         CustomTextFormField(
// //           controller: controller,
// //           prefixIcon: Icon(
// //             prefixIcon,
// //             color: AppColors.backgroundLight,
// //           ),
// //           hintText: "",
// //           onSaved: (value) {},
// //           validator: validator,
// //         ),
// //       ],
// //     );
// //   }}


// import 'dart:developer';
// import 'dart:io';

// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';
// import 'package:rideapp/models/user_model.dart';
// import 'package:rideapp/utils/theme/app_text_theme.dart';
// import 'package:rideapp/viewmodel/provider/auth_provider/auth_provider.dart';
// import 'package:rideapp/viewmodel/provider/driver_registration_provider.dart';
// import 'package:rideapp/widgets/custom_button.dart';

// import '../../../utils/theme/app_colors.dart';
// import '../widgets/custom_text_field.dart';

// class BasicInfoView extends StatefulWidget {
//   const BasicInfoView({Key? key}) : super(key: key);

//   @override
//   _BasicInfoViewState createState() => _BasicInfoViewState();
// }

// class _BasicInfoViewState extends State<BasicInfoView> {
// User? userData; 

//   final _userNameController = TextEditingController();
//   final _phoneNumberController = TextEditingController();
//   final _addressController = TextEditingController(); 
//   final _dobController = TextEditingController(); 
//   File? _pickedImageFile;
//   DateTime? _selectedDate; 
//   final _formKey = GlobalKey<FormState>();

//   @override
//   void initState() {
//     super.initState();
//      fetchData();
//     _loadSavedData();
      
//   }


//      Future<void> fetchData() async {
//     AuthProvider authService = AuthProvider();
//     await authService.fetchUserData();
//     var data = await authService.getUserData(); 
//     String? token = await authService.getToken();
//     setState(() {
//       userData = data; 
//     });

//     // Print the user data and token
//     log("Token is here: $token");
//     log('User Data: ${userData?.toJson()}');  
//   }


// Future<void> _loadSavedData() async {
//     final provider = Provider.of<DriverRegistrationProvider>(context, listen: false);
//     final savedData = provider.formData;

//     if (savedData.username != null) {
//       _userNameController.text = savedData.username!;
//     }
//     if (savedData.phone != null) {
//       _phoneNumberController.text = savedData.phone!;
//     }
//     if (savedData.address != null) {
//       _addressController.text = savedData.address!;
//     }
//     if (savedData.dob != null) {
//       _dobController.text = savedData.dob!;
//     }
//     if (savedData.profilePicture != null) {
//       setState(() {
//         _pickedImageFile = File(savedData.profilePicture!);
//       });
//     }
//   }

//   Future<void> _saveInfo() async {
//     final isValid = _formKey.currentState!.validate();
//     if (!isValid || _pickedImageFile == null) {
//       _showSnackBar('basicInfo.fillRequired'.tr(), Colors.red);
//       return;
//     }

//     try {
//       final provider = Provider.of<DriverRegistrationProvider>(context, listen: false);

//       final success = await provider.saveBasicInfo(
//         username: _userNameController.text,
//         phone: _phoneNumberController.text,
//         address: _addressController.text,
//         profilePicture: _pickedImageFile!.path,
//         dob: _dobController.text, // Fixed: using text value instead of controller
//       );

//       if (success) {
//         _showSnackBar('basicInfo.saveSuccess'.tr(), AppColors.buttonColor);
//         Navigator.pop(context);
//       } else {
//         _showSnackBar('basicInfo.saveFailed'.tr(), Colors.red);
//       }
//     } catch (e) {
//       _showSnackBar('basicInfo.error'.tr(args: [e.toString()]), Colors.red);
//     }
//   }


//   @override
//   void dispose() {
//     _userNameController.dispose();
//     _phoneNumberController.dispose();
//     _dobController.dispose();
//     super.dispose();
//   }

//   Future<void> _pickImage() async {
//     final pickedImage = await ImagePicker().pickImage(
//       source: ImageSource.camera,
//       imageQuality: 100,
//       maxWidth: double.maxFinite,
//     );

//     if (pickedImage != null) {
//       setState(() {
//         _pickedImageFile = File(pickedImage.path);
//       });
//     }
//   }

//   Future<void> _selectDate() async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate ?? DateTime.now().subtract(const Duration(days: 6570)), // 18 years ago
//       firstDate: DateTime.now().subtract(const Duration(days: 36500)), // 100 years ago
//       lastDate: DateTime.now().subtract(const Duration(days: 6570)), // 18 years ago
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: AppColors.buttonColor,
//               onPrimary: Colors.white,
//               surface: AppColors.backgroundLight,
//               onSurface: AppColors.backgroundDark,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );

//     if (picked != null) {
//       setState(() {
//         _selectedDate = picked;
//         _dobController.text = DateFormat('dd-MM-yyyy').format(picked);
//       });
//     }
//   }

//   void _showSnackBar(String message, Color backgroundColor) {
//     ScaffoldMessenger.of(context).clearSnackBars();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         backgroundColor: backgroundColor,
//         content: Row(
//           children: [
//             Icon(
//               backgroundColor == Colors.red ? Icons.info : Icons.check,
//               color: Colors.white,
//             ),
//             const SizedBox(width: 3),
//             Text(
//               message,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontFamily: "Montserrat",
//               ),
//             ),
//           ],
//         ),
//         action: SnackBarAction(
//           label: 'basicInfo.close'.tr(),
//           textColor: Colors.white,
//           onPressed: () {},
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: AppColors.backgroundDark,
//         title: Text(
//           'basicInfo.title'.tr(),
//           style: AppTextTheme.getDarkTextTheme(context).headlineSmall,
//         ),
//         centerTitle: true,
//         leading: IconButton(
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//           icon: const Icon(
//             Icons.arrow_back_ios_new,
//             color: AppColors.backgroundLight,
//           ),
//         ),
//       ),
//      body: Consumer<DriverRegistrationProvider>(
//         builder: (context, provider, child) {
//           if (provider.isLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           return SingleChildScrollView(
//             child: Form(
//               key: _formKey,
//               child: Padding(
//                 padding: EdgeInsets.symmetric(
//                     horizontal: screenWidth * 0.08,
//                     vertical: screenHeight * 0.015),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildImagePicker(),
//                     const SizedBox(height: 12),
//                     _buildTextField(
//                       label: "userName",
//                       controller: _userNameController,
//                       validator: (value) => value!.isEmpty
//                           ? 'basicInfo.userNameRequired'.tr()
//                           : null,
//                       prefixIcon: Icons.account_circle,
//                     ),
//                     const SizedBox(height: 15),
//                     // _buildTextField(
//                     //   label: "phoneNumber",
//                     //   controller: _phoneNumberController,
//                     //   validator: (value) => value!.isEmpty
//                     //       ? 'basicInfo.phoneRequired'.tr()
//                     //       : null,
//                     //   prefixIcon: Icons.phone,
//                     // ),
//                     // const SizedBox(height: 15),
//                     _buildTextField(
//                       label: "address",
//                       controller: _addressController,
//                       validator: (value) => value!.isEmpty
//                           ? 'basicInfo.addressRequired'.tr()
//                           : null,
//                       prefixIcon: Icons.location_on,
//                     ),
//                     const SizedBox(height: 15),
//                     _buildDateField(),
//                     const SizedBox(height: 90),
//                     CustomButton(
//                       text: 'basicInfo.save'.tr(),
//                       textStyle: AppTextTheme.getLightTextTheme(context).bodyLarge!,
//                       onPressed: _saveInfo,
//                       borderRadius: 45,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildImagePicker() {
//     return Stack(
//       children: [
//         Align(
//           alignment: Alignment.center,
//           child: CircleAvatar(
//             backgroundColor: Colors.transparent,
//             radius: 50,
//             foregroundImage: _pickedImageFile != null
//                 ? FileImage(_pickedImageFile!)
//                 : const AssetImage('assets/icons/user_account_icon.png') as ImageProvider,
//           ),
//         ),
//         Positioned(
//           bottom: -10,
//           right: 140,
//           child: IconButton(
//             onPressed: _pickImage,
//             icon: const Icon(
//               Icons.camera_alt,
//               color: Colors.black,
//               size: 20,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildTextField({
//     required String label,
//     required TextEditingController controller,
//     required String? Function(String?) validator,
//     required IconData prefixIcon,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'basicInfo.$label'.tr(),
//           style: AppTextTheme.getDarkTextTheme(context).bodyLarge,
//         ),
//         const SizedBox(height: 10),
//         CustomTextFormField(
//           controller: controller,
//           prefixIcon: Icon(
//             prefixIcon,
//             color: AppColors.backgroundLight,
//           ),
//           hintText: "",
//           onSaved: (value) {},
//           validator: validator,
//         ),
//       ],
//     );
//   }

//   Widget _buildDateField() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'basicInfo.dateOfBirth'.tr(),
//           style: AppTextTheme.getDarkTextTheme(context).bodyLarge,
//         ),
//         const SizedBox(height: 10),
//         GestureDetector(
//           onTap: _selectDate,
//           child: AbsorbPointer(
//             child: CustomTextFormField(
//               controller: _dobController,
//               prefixIcon: const Icon(
//                 Icons.calendar_today,
//                 color: AppColors.backgroundLight,
//               ),
//               hintText: "DD-MM-YYYY",
//               onSaved: (value) {},
//               validator: (value) => value!.isEmpty
//                   ? 'basicInfo.dobRequired'.tr()
//                   : null,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }


import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rideapp/models/user_model.dart';
import 'package:rideapp/utils/theme/app_text_theme.dart';
// import 'package:rideapp/viewmodel/provider/auth_provider/auth_provider.dart';
import 'package:rideapp/viewmodel/provider/driver_registration_provider.dart';
import 'package:rideapp/widgets/custom_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../utils/theme/app_colors.dart';
import '../widgets/custom_text_field.dart';

class BasicInfoView extends StatefulWidget {
  const BasicInfoView({Key? key}) : super(key: key);

  @override
  _BasicInfoViewState createState() => _BasicInfoViewState();
}

class _BasicInfoViewState extends State<BasicInfoView> {
  User? userData;
  String? userPhone;

  final _userNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _dobController = TextEditingController();
  File? _pickedImageFile;
  DateTime? _selectedDate;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // fetchData();
    _loadSavedData();
     _getUserPhone();
  }

 Future<void> _getUserPhone() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    // Get the complete userData string
    final userDataString = prefs.getString('userData');
    
    if (userDataString != null) {
      // Parse the JSON string to Map
      final userDataMap = jsonDecode(userDataString) as Map<String, dynamic>;
      // Get phone number from the map
      final phoneNumber = userDataMap['phone'] as String?;
      
      setState(() {
        userPhone = phoneNumber;
      });
      
      log('Retrieved phone number from userData: $userPhone');
      
      
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        await prefs.setString('phone', phoneNumber);
        log('Also saved phone to separate storage: $phoneNumber');
      }
    } else {
      log('No userData found in SharedPreferences');
    }
  } catch (e) {
    log('Error getting phone number: $e');
  }
}

  // Future<void> fetchData() async {
  //   AuthProvider authService = AuthProvider();
  //   await authService.fetchUserData();
  //   var data = await authService.getUserData();
  //   String? token = await authService.getToken();
  //   setState(() {
  //     userData = data;
  //   });
  //   log("Token is here: $token");
  //   log('User Data: ${userData?.toJson()}');
  // }

  Future<void> _loadSavedData() async {
    final provider = Provider.of<DriverRegistrationProvider>(context, listen: false);
    final savedData = provider.formData;

    if (savedData.username != null) {
      _userNameController.text = savedData.username!;
    }
    if (savedData.address != null) {
      _addressController.text = savedData.address!;
    }
    if (savedData.dob != null) {
      _dobController.text = savedData.dob!;
    }
    if (savedData.profilePicture != null) {
      setState(() {
        _pickedImageFile = File(savedData.profilePicture!);
      });
    }
  }

Future<void> _saveInfo() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid || _pickedImageFile == null) {
      _showSnackBar('basicInfo.fillRequired'.tr(), Colors.red);
      return;
    }

    try {
      final provider = Provider.of<DriverRegistrationProvider>(context, listen: false);
      String phoneNumber = '';
      
      // Get SharedPreferences instance
      final prefs = await SharedPreferences.getInstance();
      
      // First try to get from userData
      final userDataString = prefs.getString('userData');
      if (userDataString != null) {
        final userDataMap = jsonDecode(userDataString) as Map<String, dynamic>;
        phoneNumber = userDataMap['phone'] as String? ?? '';
        log('Got phone number from userData: $phoneNumber');
      }
      
      // If phone is empty, try getting from state
      if (phoneNumber.isEmpty && userPhone != null) {
        phoneNumber = userPhone!;
        log('Got phone number from state: $phoneNumber');
      }
      
      // If still empty, try getting from separate storage
      if (phoneNumber.isEmpty) {
        phoneNumber = prefs.getString('phone') ?? '';
        log('Got phone number from separate storage: $phoneNumber');
      }

      // Validate phone number
      if (phoneNumber.isEmpty) {
        _showSnackBar('Phone number not found', Colors.red);
        log('Error: Phone number is empty');
        return;
      }

      log('Proceeding to save with phone number: $phoneNumber');

      final success = await provider.saveBasicInfo(
        username: _userNameController.text,
        phone: phoneNumber,
        address: _addressController.text,
        profilePicture: _pickedImageFile!.path,
        dob: _dobController.text,
      );

      if (success) {
        log('Successfully saved basic info with phone number: $phoneNumber');
        // Save the successful data back to SharedPreferences
        await prefs.setString('phone', phoneNumber);
        _showSnackBar('basicInfo.saveSuccess'.tr(), AppColors.buttonColor);
        Navigator.pop(context);
      } else {
        _showSnackBar('basicInfo.saveFailed'.tr(), Colors.red);
      }
    } catch (e) {
      log('Error saving basic info: $e');
      _showSnackBar('basicInfo.error'.tr(args: [e.toString()]), Colors.red);
    }
  }


  @override
  void dispose() {
    _userNameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 100,
      maxWidth: double.maxFinite,
    );

    if (pickedImage != null) {
      setState(() {
        _pickedImageFile = File(pickedImage.path);
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().subtract(const Duration(days: 6570)),
      firstDate: DateTime.now().subtract(const Duration(days: 36500)),
      lastDate: DateTime.now().subtract(const Duration(days: 6570)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.buttonColor,
              onPrimary: Colors.white,
              surface: AppColors.backgroundLight,
              onSurface: AppColors.backgroundDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        content: Row(
          children: [
            Icon(
              backgroundColor == Colors.red ? Icons.info : Icons.check,
              color: Colors.white,
            ),
            const SizedBox(width: 3),
            Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: "Montserrat",
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'basicInfo.close'.tr(),
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
      
        title: Text(
          'basicInfo.title'.tr(),
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
      body: Consumer<DriverRegistrationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.08,
                    vertical: screenHeight * 0.015),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImagePicker(),
                    const SizedBox(height: 12),
                    _buildTextField(
                      label: "userName",
                      controller: _userNameController,
                      validator: (value) => value!.isEmpty
                          ? 'basicInfo.userNameRequired'.tr()
                          : null,
                      prefixIcon: Icons.account_circle,
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      label: "address",
                      controller: _addressController,
                      validator: (value) => value!.isEmpty
                          ? 'basicInfo.addressRequired'.tr()
                          : null,
                      prefixIcon: Icons.location_on,
                    ),
                    const SizedBox(height: 15),
                    _buildDateField(),
                    const SizedBox(height: 90),
                    CustomButton(
                      text: 'basicInfo.save'.tr(),
                      textStyle: AppTextTheme.getLightTextTheme(context).bodyLarge!,
                      onPressed: _saveInfo,
                      borderRadius: 45,
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

  Widget _buildImagePicker() {
    return Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 50,
            foregroundImage: _pickedImageFile != null
                ? FileImage(_pickedImageFile!)
                : const AssetImage('assets/icons/user_account_icon.png') as ImageProvider,
          ),
        ),
        Positioned(
          bottom: -10,
          right: 140,
          child: IconButton(
            onPressed: _pickImage,
            icon: const Icon(
              Icons.camera_alt,
              color: Colors.black,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    required IconData prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'basicInfo.$label'.tr(),
          style: AppTextTheme.getDarkTextTheme(context).bodyLarge,
        ),
        const SizedBox(height: 10),
        CustomTextFormField(
          controller: controller,
          prefixIcon: Icon(
            prefixIcon,
            color: AppColors.backgroundDark,
          ),
          hintText: "",
          onSaved: (value) {},
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'basicInfo.dateOfBirth'.tr(),
          style: AppTextTheme.getDarkTextTheme(context).bodyLarge,
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _selectDate,
          child: AbsorbPointer(
            child: CustomTextFormField(
              controller: _dobController,
              prefixIcon: const Icon(
                Icons.calendar_today,
                color: AppColors.backgroundDark,
              ),
              hintText: "DD-MM-YYYY",
              onSaved: (value) {},
              validator: (value) => value!.isEmpty
                  ? 'basicInfo.dobRequired'.tr()
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}