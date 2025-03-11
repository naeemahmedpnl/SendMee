
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:sendme/utils/routes/user_panel_routes.dart';
import 'package:sendme/utils/theme/app_colors.dart';
import 'package:sendme/utils/theme/app_text_theme.dart';
import 'package:sendme/viewmodel/provider/auth_provider/auth_provider.dart';
import 'package:sendme/views/User_panel/Authentication/user_login_view.dart';
import 'package:sendme/widgets/custom_button.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class UserSignupView extends StatefulWidget {
  const UserSignupView({super.key});

  @override
  State<UserSignupView> createState() => _UserSignupViewState();
}

class _UserSignupViewState extends State<UserSignupView> {
  final TextEditingController _phoneNumberController = TextEditingController();
  String _phoneNumber = '';

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _handleSignUp(AuthProvider authProvider) async {
    if (_phoneNumber.isEmpty) {
      _showErrorSnackBar('userSignup.errors.invalidPhone'.tr());
      return;
    }

    try {
      await authProvider.registerWithPhoneNumber(_phoneNumber);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.otpScreen);
    } catch (error) {
      _showErrorSnackBar(error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.backgroundLight,
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Container(
                width: screenWidth,
                height: screenHeight * 0.45,
                child: Image.asset(
                  'assets/images/sendme_signup.png',
                  fit: BoxFit.fill,
                ),
              ),
              Container(
                width: screenWidth,
                height: screenHeight * 0.57,
                decoration: const BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 20,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'userSignup.signUp'.tr(),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'userSignup.phoneNumber'.tr(),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      IntlPhoneField(
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                        controller: _phoneNumberController,
                        decoration: InputDecoration(
                          labelText: 'userSignup.phoneNumber'.tr(),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(16),
                            ),
                          ),
                        ),
                        initialCountryCode: 'ZA',
                        onChanged: (phone) {
                          setState(() {
                            _phoneNumber = phone.completeNumber;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      CustomButton(
                        text: 'userSignup.signUp'.tr(),
                        isLoading: authProvider.isLoading,
                        onPressed: () => _handleSignUp(authProvider),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'userSignup.continueWith'.tr(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/logos/facebook.png',
                            width: 45,
                            height: 45,
                          ),
                          const SizedBox(width: 5),
                          Image.asset(
                            'assets/logos/google.png',
                            width: 45,
                            height: 45,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'userSignup.alreadyHaveAccount'.tr(),
                            style: AppTextTheme.getLightTextTheme(context).titleLarge,
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const UserLoginView(),
                                ),
                                (Route<dynamic> route) => false,
                              );
                            },
                            child: Text(
                              'userSignup.signIn'.tr(),
                              style: AppTextTheme.getPrimaryTextTheme(context).titleLarge,
                            ),
                          ),
                        ],
                      )
                    ],
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