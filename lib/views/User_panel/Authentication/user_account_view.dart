
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sendme/utils/routes/user_panel_routes.dart';
import 'package:sendme/utils/theme/app_colors.dart';
import 'package:sendme/viewmodel/provider/auth_provider/auth_provider.dart';
import 'package:sendme/widgets/custom_button.dart';
import 'package:sendme/widgets/custom_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserAccountCreateView extends StatefulWidget {
  const UserAccountCreateView({Key? key}) : super(key: key);

  @override
  State<UserAccountCreateView> createState() => _UserAccountCreateViewState();
}

class _UserAccountCreateViewState extends State<UserAccountCreateView> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _nameController = TextEditingController();

  Future<void> changeLanguage(BuildContext context, String languageCode) async {
    await context.setLocale(Locale(languageCode));
  }

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _nameController = TextEditingController();
  }

Future<void> _handleSignUp() async {
  if (_formKey.currentState?.validate() ?? false) {
    try {
      // Get AuthProvider instance using Provider.of
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      await authProvider.completeProfile(
        _emailController.text,
        _passwordController.text,
        _nameController.text,
      );
      
      // Get SharedPreferences instance
      SharedPreferences prefs = await SharedPreferences.getInstance();
      
      // Remove OTP as it's no longer needed
      await prefs.remove('otp');
      
      // Verify token exists before navigation
      final token = prefs.getString('token');
      if (token == null) {
        throw Exception('Token not found after profile completion');
      }
      
      if (mounted) {
        // Navigate to home screen
        Navigator.pushReplacementNamed(context, AppRoutes.userLogin);
      }
    } catch (error) {
      // Error handling without SnackBar
      print('Error during signup: $error');
    } finally {
      // Hide loading indicator
      // if (mounted) {
      //   setState(() {
      //     _isLoading = false;
      //   });
      // }
    }
  }
}

  Future<void> _clearSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('otp');
  }

  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'userAccount.emailRequired'.tr();
    }
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      caseSensitive: false,
    );
    if (!emailRegExp.hasMatch(value)) {
      return 'userAccount.emailInvalid'.tr();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          color: AppColors.backgroundLight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Stack(
                children: [
                  SizedBox(
                    width: 412,
                    height: screenHeight * 0.4,
                    child: Image.asset(
                      'assets/images/sendme_signupp.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                  // Positioned(
                  //   top: 40,
                  //   right: 20,
                  //   child: Container(
                  //     height: 40,
                  //     decoration: BoxDecoration(
                  //       borderRadius: BorderRadius.circular(50),
                  //       border: Border.all(color: Colors.amber, width: 1),
                  //     ),
                  //     child: IconButton(
                  //       onPressed: () async {
                  //         try {
                  //           if (context.locale == const Locale('en')) {
                  //             await changeLanguage(context, 'es');
                  //           } else {
                  //             await changeLanguage(context, 'en');
                  //           }
                  //           if (context.mounted) {
                  //             ScaffoldMessenger.of(context).showSnackBar(
                  //               SnackBar(
                  //                 content: Text(
                  //                   context.locale.languageCode == 'en'
                  //                       ? 'Language changed to English'
                  //                       : 'Idioma cambiado a Español',
                  //                 ),
                  //                 duration: const Duration(seconds: 1),
                  //               ),
                  //             );
                  //           }
                  //         } catch (e) {
                  //           if (context.mounted) {
                  //             ScaffoldMessenger.of(context).showSnackBar(
                  //               const SnackBar(
                  //                 content: Text('Error changing language'),
                  //               ),
                  //             );
                  //           }
                  //         }
                  //       },
                  //       icon: Row(
                  //         mainAxisSize: MainAxisSize.min,
                  //         children: [
                  //           const Icon(
                  //             Icons.language,
                  //             size: 20,
                  //             color: Colors.amber,
                  //           ),
                  //           const SizedBox(width: 5),
                  //           Text(
                  //             context.locale.languageCode.toUpperCase(),
                  //             style: const TextStyle(
                  //               color: Colors.amber,
                  //               fontWeight: FontWeight.bold,
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                height: screenHeight * 0.6,
                decoration: const BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, left: 30, right: 30),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'userAccount.signUp'.tr(),
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        CustomTextFormField(
                          icon: Icons.person,
                          hintText: 'userAccount.enterName'.tr(),
                          controller: _nameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'userAccount.nameRequired'.tr();
                            }
                            return null;
                          },
                        ),
                        CustomTextFormField(
                          icon: Icons.email,
                          hintText: 'userAccount.enterEmail'.tr(),
                          controller: _emailController,
                          validator: emailValidator,
                        ),
                        CustomTextFormField(
                          icon: Icons.lock,
                          hintText: 'userAccount.enterNewPassword'.tr(),
                          isPassword: true,
                          controller: _passwordController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'userAccount.passwordRequired'.tr();
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 60),
                        CustomButton(
                          isLoading: authProvider.isLoading,
                          text: 'userAccount.signUp'.tr(),
                          onPressed: () async {
                                _handleSignUp();

                          
                            // if (_formKey.currentState?.validate() ?? false) {
                            //   try {
                            //     await authProvider.completeProfile(
                            //       _emailController.text,
                            //       _passwordController.text,
                            //       _nameController.text,
                            //     );
                            //     await _clearSharedPreferences();
                            //     Navigator.pushReplacementNamed(
                            //         context, AppRoutes.parcelScreen);
                            //   } catch (error) {
                            //     ScaffoldMessenger.of(context).showSnackBar(
                            //       SnackBar(
                            //         content: Text('userAccount.profileCreateError'.tr()),
                            //       ),
                            //     );
                            //   }
                            // }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  
}