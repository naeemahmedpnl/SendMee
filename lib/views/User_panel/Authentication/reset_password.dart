import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:sendme/utils/constant/api_base_url.dart';
import 'package:sendme/utils/routes/user_panel_routes.dart';
import 'package:sendme/utils/theme/app_colors.dart';
import 'package:sendme/widgets/custom_button.dart';
import 'package:sendme/widgets/custom_text_field.dart';
import 'package:http/http.dart' as http;

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  const ResetPasswordScreen({required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email;
  }

  String get baseUrl => Constants.apiBaseUrl;

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showPopup('reset_password.errors.passwords_not_match'.tr(), false);
      return;
    }

    final url = '$baseUrl/auth/resetPassword';
    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': _emailController.text,
        'otp': _otpController.text,
        'password': _newPasswordController.text,
        'confirmPassword': _confirmPasswordController.text,
      }),
    );

    final responseData = json.decode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (responseData['message'] == 'Password has been Change') {
        _showPopup('reset_password.success'.tr(), true);
      }
    } else if (response.statusCode == 400) {
      String errorMessage = 'reset_password.errors.invalid_otp'.tr();
      if (_newPasswordController.text.length < 8) {
        errorMessage += ' ${tr('reset_password.errors.password_length')}';
      }
      _showPopup(errorMessage, false);
    } else {
      _showPopup('reset_password.errors.general'.tr(args: [response.reasonPhrase ?? '']), false);
    }
  }

  void _showPopup(String message, bool isSuccess) {
    final snackBar = SnackBar(
      content: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(message),
        ),
      ),
      backgroundColor: isSuccess ? Colors.green : Colors.red,
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    if (isSuccess) {
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacementNamed(context, AppRoutes.userLogin);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          color: AppColors.backgroundLight,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: 412,
                  height: screenHeight * 0.3,
                  child: Image.asset(
                    'assets/images/otp.png',
                    fit: BoxFit.fill,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  height: screenHeight * 0.7,
                  decoration: const BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20, left: 30, right: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'reset_password.title'.tr(),
                          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        const SizedBox(height: 10),
                        CustomTextFormField(
                          controller: _emailController,
                          icon: Icons.email,
                          hintText: widget.email,
                          readOnly: true,
                        ),
                        CustomTextFormField(
                          icon: Icons.password_outlined,
                          hintText: 'reset_password.otp_hint'.tr(),
                          controller: _otpController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'reset_password.validation.otp_required'.tr();
                            }
                            return null;
                          },
                        ),
                        CustomTextFormField(
                          icon: Icons.lock,
                          hintText: 'reset_password.new_password_hint'.tr(),
                          isPassword: true,
                          controller: _newPasswordController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'reset_password.validation.new_password_required'.tr();
                            } else if (value.length < 8) {
                              return 'reset_password.validation.password_length'.tr();
                            }
                            return null;
                          },
                        ),
                        CustomTextFormField(
                          icon: Icons.lock,
                          hintText: 'reset_password.confirm_password_hint'.tr(),
                          isPassword: true,
                          controller: _confirmPasswordController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'reset_password.validation.confirm_password_required'.tr();
                            } else if (value != _newPasswordController.text) {
                              return 'reset_password.validation.passwords_not_match'.tr();
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),
                        CustomButton(
                          isLoading: true,
                          text: 'reset_password.button'.tr(),
                          onPressed: _changePassword
                        ),
                      ],
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