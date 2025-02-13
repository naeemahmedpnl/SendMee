

import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rideapp/services/notification_service.dart';
import 'package:rideapp/utils/routes/user_panel_routes.dart';
import 'package:rideapp/utils/theme/app_colors.dart';
import 'package:rideapp/utils/theme/app_text_theme.dart';
import 'package:rideapp/viewmodel/provider/auth_provider/auth_provider.dart';
import 'package:rideapp/widgets/custom_button.dart';
import 'package:rideapp/widgets/custom_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserLoginView extends StatefulWidget {
  const UserLoginView({Key? key}) : super(key: key);

  @override
  _UserLoginViewState createState() => _UserLoginViewState();
}

class _UserLoginViewState extends State<UserLoginView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _submitLogin() async {
    if (!mounted) return;
    
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final notificationService = NotificationService();
      final fcmToken = await notificationService.getFCMToken();
      
      log('FCM Token before login: $fcmToken');

      if (fcmToken == null) {
        throw Exception('userLogin.errors.notificationInit'.tr());
      }

      final email = _emailController.text.trim();
      final password = _passwordController.text;

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final errorMessage = await authProvider.login(email, password, fcmToken);

      if (!mounted) return;

      if (errorMessage == null) {
        await _saveFCMTokenAndUserData(fcmToken);
        Navigator.pushReplacementNamed(context, AppRoutes.parcelScreen);
      } else {
        _showErrorSnackBar(errorMessage);
      }

    } catch (e) {
      log('Login error: $e');
      if (!mounted) return;
      
      _showErrorSnackBar(e.toString());
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveFCMTokenAndUserData(String fcmToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.setString('fcm_token', fcmToken),
        prefs.setString('last_login', DateTime.now().toIso8601String()),
      ]);
      log('FCM Token and user data saved successfully');
    } catch (e) {
      log('Error saving FCM token and user data: $e');
      throw Exception('userLogin.errors.saveUserData'.tr());
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'userLogin.dismiss'.tr(),
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'userLogin.emailRequired'.tr();
    }
    return null;
  }

  String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'userLogin.passwordRequired'.tr();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            color: AppColors.backgroundLight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: 412,
                  height: screenHeight * 0.4,
                  child: Image.asset(
                    'assets/images/send_melogin.png',
                    fit: BoxFit.fill,
                  ),
                ),
                const SizedBox(height: 20),
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
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'userLogin.signIn'.tr(),
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,  
                            ),
                          ),
                          const SizedBox(height: 15),
                          CustomTextFormField(
                            icon: Icons.email,
                            hintText: 'userLogin.enterEmail'.tr(),
                            controller: _emailController,
                            validator: emailValidator,
                          ),
                          CustomTextFormField(
                            icon: Icons.lock,
                            hintText: 'userLogin.enterPassword'.tr(),
                            isPassword: true,
                            controller: _passwordController,
                            validator: passwordValidator,
                          ),
                          if (_errorMessage != null)
                            Center(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, AppRoutes.userForgotPassword);
                              },
                              child: Text(
                                'userLogin.forgotPassword'.tr(),
                                style: AppTextTheme.getPrimaryTextTheme(context).titleMedium,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          CustomButton(
                            isLoading: _isLoading,
                            text: 'userLogin.signIn'.tr(),
                            onPressed: _submitLogin,
                            widthFactor: 0.8,
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'userLogin.dontHaveAccount'.tr(),
                                style: AppTextTheme.getLightTextTheme(context).titleLarge,
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacementNamed(context, AppRoutes.userSignup);
                                },
                                child: Text(
                                  'userLogin.signUp'.tr(),
                                  style: AppTextTheme.getPrimaryTextTheme(context).titleLarge,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
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