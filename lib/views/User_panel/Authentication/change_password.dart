import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';  // Add this import
import 'package:sendme/utils/routes/user_panel_routes.dart';
import 'package:sendme/utils/theme/app_colors.dart';
import 'package:sendme/viewmodel/provider/auth_provider/change_password_provider.dart';
import 'package:sendme/widgets/custom_button.dart';
import 'package:sendme/widgets/custom_text_field.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({Key? key}) : super(key: key);

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChangePasswordProvider(),
      child: Consumer<ChangePasswordProvider>(
        builder: (context, provider, _) {
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
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'change_password.title'.tr(),
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 20),
                              CustomTextFormField(
                                hintText: 'change_password.old_password'.tr(),
                                controller: _oldPasswordController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'change_password.validation.old_required'.tr();
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 10),
                              CustomTextFormField(
                                hintText: 'change_password.new_password'.tr(),
                                controller: _newPasswordController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'change_password.validation.new_required'.tr();
                                  }
                                  if (value.length < 6) {
                                    return 'change_password.validation.length'.tr();
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              if (provider.errorMessage != null)
                                Text(
                                  provider.errorMessage!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              const SizedBox(height: 10),
                              CustomButton(
                                text: 'change_password.button'.tr(),
                                isLoading: provider.isLoading,
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    await provider.changePassword(
                                      _oldPasswordController.text,
                                      _newPasswordController.text,
                                    );
                                    if (provider.isPasswordChanged) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('change_password.success'.tr()),
                                        ),
                                      );
                                      Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        AppRoutes.userLogin,
                                        (route) => false,
                                      );
                                    }
                                  }
                                },
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}