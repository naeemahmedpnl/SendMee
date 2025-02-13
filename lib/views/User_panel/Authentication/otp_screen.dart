import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rideapp/utils/routes/user_panel_routes.dart';
import 'package:rideapp/utils/theme/app_colors.dart';
import 'package:rideapp/widgets/custom_button.dart';
import 'package:rideapp/widgets/custom_text_field.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({Key? key}) : super(key: key);

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _storedOtp;

  @override
  void initState() {
    super.initState();
    _loadOtp();
  }

  Future<void> _loadOtp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _storedOtp = prefs.getString('otp');
    });
  }

  Future<void> _verifyOtp() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_storedOtp != null && _storedOtp == _otpController.text.trim()) {
        Navigator.pushNamed(context, AppRoutes.userAccountCreate);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('otp.invalid_otp'.tr()),
          ),
        );
      }
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
              flex: 5,
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 20,
                ),
                child: Image.asset(
                  'assets/images/sendme_otp.png',
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
            Expanded(
              flex: 5,
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
                          'otp.title'.tr(),
                          style: const TextStyle(
                            fontSize: 30, 
                            fontWeight: FontWeight.bold, 
                            color: Colors.black
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (_storedOtp != null)
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'otp.your_otp'.tr(args: [_storedOtp!]),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        const SizedBox(height: 20),
                        Text(
                          'otp.enter_code'.tr(),
                          style: const TextStyle(fontSize: 15, color: Colors.black),
                        ),
                        const SizedBox(height: 10),
                        CustomTextFormField(
                          isPhone: true,
                          controller: _otpController,
                          hintText: 'otp.code_hint'.tr(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'otp.validation.required'.tr();
                            } else if (value.length != 4) {
                              return 'otp.validation.length'.tr();
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        CustomButton(
                          text: 'otp.verify_button'.tr(),
                          onPressed: _verifyOtp,
                        ),
                        const SizedBox(height: 20),
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
  }
}