import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rideapp/utils/routes/user_panel_routes.dart';
import 'package:rideapp/utils/theme/app_colors.dart';
import 'package:rideapp/viewmodel/provider/auth_provider/auth_provider.dart';
import 'package:rideapp/widgets/custom_button.dart';
import 'package:rideapp/widgets/custom_text_field.dart';

class UserForgotPassword extends StatefulWidget {
  const UserForgotPassword({super.key});

  @override
  State<UserForgotPassword> createState() => _UserForgotPasswordState();
}

class _UserForgotPasswordState extends State<UserForgotPassword> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  void _submitForgotPassword() async {
    final email = _emailController.text;

    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'forgot_password.validation.email_required'.tr();
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final forgotPasswordProvider = Provider.of<AuthProvider>(context, listen: false);
    final errorMessage = await forgotPasswordProvider.sendOTP(email);

    setState(() {
      _isLoading = false;
      _errorMessage = errorMessage;
    });

    if (errorMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('forgot_password.otp_sent'.tr()),
        ),
      );

      Navigator.pushNamed(context, AppRoutes.resetPasswordScreen, arguments: email);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        color: AppColors.backgroundLight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 20,
                ),
                child: Image.asset(
                  'assets/images/otp.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Expanded(
              flex: 7,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(30, 20, 30, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'forgot_password.title'.tr(),
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'forgot_password.email_label'.tr(),
                        style: const TextStyle(fontSize: 18, color: Colors.black),
                      ),
                      const SizedBox(height: 10),
                      CustomTextFormField(
                        icon: null,
                        hintText: 'forgot_password.email_hint'.tr(),
                        controller: _emailController,
                      ),
                      const SizedBox(height: 10),
                      if (_errorMessage != null)
                        Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      const SizedBox(height: 20),
                      CustomButton(
                        text: _isLoading 
                          ? 'forgot_password.sending'.tr() 
                          : 'forgot_password.button'.tr(),
                        isLoading: _isLoading,
                        onPressed: _submitForgotPassword,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}