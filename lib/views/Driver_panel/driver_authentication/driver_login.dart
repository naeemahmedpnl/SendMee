// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:rideapp/services/notification_service.dart';
// import 'package:rideapp/utils/routes/driver_panel_routes.dart';
// import 'package:rideapp/utils/theme/app_colors.dart';
// import 'package:rideapp/utils/theme/app_text_theme.dart';
// import 'package:rideapp/viewmodel/provider/auth_provider/auth_provider.dart';
// import 'package:rideapp/widgets/custom_button.dart';
// import 'package:rideapp/widgets/custom_text_field.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class DriverLoginView extends StatefulWidget {
//   @override
//   _DriverLoginViewState createState() => _DriverLoginViewState();
// }

// class _DriverLoginViewState extends State<DriverLoginView> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   bool _isLoading = false;
//   String? _errorMessage; 

// Future<void> _submitLogin() async {
//   if (!mounted) return;
  
//   setState(() {
//     _isLoading = true;
//     _errorMessage = null;
//   });

//   try {
//     final notificationService = NotificationService();
//     final fcmToken = await notificationService.getFCMToken();
    
//     if (fcmToken == null) {
//       throw Exception("Failed to get FCM token");
//     }

//     log('FCM Token: $fcmToken');

//     final email = _emailController.text.trim();
//     final password = _passwordController.text;

//     // Validate inputs
//     if (email.isEmpty || password.isEmpty) {
//       throw Exception("Please fill all fields");
//     }

//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     final error = await authProvider.login(email, password, fcmToken);

//     if (!mounted) return;

//     if (error == null) {
//       Navigator.pushReplacementNamed(context, AppDriverRoutes.rideBooking);
//     } else {
//       setState(() => _errorMessage = error);
//     }

//   } catch (e) {
//     log('Login error: $e');
//     if (!mounted) return;
//     setState(() => _errorMessage = e.toString());
//   } finally {
//     if (mounted) {
//       setState(() => _isLoading = false);
//     }
//   }
// }
// // Add method to save token locally
// Future<void> saveTokenLocally(String? token) async {
//   if (token != null) {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('driver_fcm_token', token); // Different key for driver
//     log('Driver FCM token saved locally: $token');
//   }
// }

//   // Future<void> _submitLogin() async {
//   //   final email = _emailController.text;
//   //   final password = _passwordController.text;

//   //   setState(() {
//   //     _isLoading = true;
//   //     _errorMessage = null; 
//   //   });

//   //   final authProvider = Provider.of<AuthProvider>(context, listen: false);
//   //   final errorMessage = await authProvider.login(email, password);

//   //   setState(() {
//   //     _isLoading = false;
//   //     _errorMessage = errorMessage; // Display error if there's one
//   //   });

//   //   if (errorMessage == null) {
//   //     // On successful login, navigate to home page
//   //     Navigator.pushReplacementNamed(context, AppDriverRoutes.rideBooking);
//   //   }
//   // }

//   String? emailValidator(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Please enter your email address';
//     }
//     final emailRegExp = RegExp(
//       r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
//       caseSensitive: false,
//     );
//     if (!emailRegExp.hasMatch(value)) {
//       return 'Please enter a valid email address';
//     }
//     return null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     double screenHeight = MediaQuery.of(context).size.height;

//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       backgroundColor: AppColors.backgroundLight,
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: [
//           Expanded(
//             flex: 4,
//             child: Container(
//               width: 412,
//               height: screenHeight * 0.45,
//               padding: const EdgeInsets.only(top: 100),
//               child: Image.asset(
//                 width: 412,
//                 height: 368,
//                 'assets/images/sigin.png', 
//                 fit: BoxFit.contain,
//               ),
//             ),
//           ),
//           const SizedBox(height: 20),
//           Expanded(
//             flex: 6,
//             child: Container(
//               width: double.infinity,
//               decoration: const BoxDecoration(
//                 color: AppColors.backgroundDark,
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(20),
//                   topRight: Radius.circular(20),
//                 ),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       "Sign In",
//                       style: TextStyle(
//                         fontSize: 30,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     CustomTextFormField(
//                       icon: Icons.email,
//                       hintText: "Enter your email",
//                       controller: _emailController,
//                       validator: emailValidator,
//                     ),
//                     const SizedBox(height: 10),
//                     CustomTextFormField(
//                       icon: Icons.lock,
//                       hintText: "Enter your password",
//                       isPassword: true,
//                       controller: _passwordController,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter your password';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 10),
//                     if (_errorMessage != null)
//                       Center(
//                         child: Text(
//                           _errorMessage!,
//                           style: const TextStyle(
//                             color: Colors.red,
//                             fontSize: 14,
//                           ),
//                         ),
//                       ),
//                     Align(
//                       alignment: Alignment.centerRight,
//                       child: TextButton(
//                         onPressed: () {
//                           // Navigator.pushNamed(context, AppRoutes.userForgotPassword);
//                         },
//                         child: Text(
//                           "Forgot Password?",
//                           style: AppTextTheme.getPrimaryTextTheme(context).titleMedium,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     CustomButton(
//                       isLoading: _isLoading,
//                       text: "Sign In",
//                       onPressed: _submitLogin,
//                       widthFactor: 0.8, // 80% of screen width
//                     ),
//                     const SizedBox(height: 10),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           "Don't have an account?",
//                           style: AppTextTheme.getDarkTextTheme(context).titleLarge,
//                         ),
//                         TextButton(
//                           onPressed: () {
//                             Navigator.pushReplacementNamed(context, AppDriverRoutes.driverOverview);
//                           },
//                           child: Text(
//                             "Sign Up",
//                             style: AppTextTheme.getPrimaryTextTheme(context).titleLarge,
//                           ),
//                         ),
//                       ],
//                     )
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rideapp/services/notification_service.dart';
import 'package:rideapp/utils/routes/driver_panel_routes.dart';
import 'package:rideapp/utils/theme/app_colors.dart';
import 'package:rideapp/utils/theme/app_text_theme.dart';
import 'package:rideapp/viewmodel/provider/auth_provider/auth_provider.dart';
import 'package:rideapp/widgets/custom_button.dart';
import 'package:rideapp/widgets/custom_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DriverLoginView extends StatefulWidget {
  const DriverLoginView({Key? key}) : super(key: key);

  @override
  _DriverLoginViewState createState() => _DriverLoginViewState();
}

class _DriverLoginViewState extends State<DriverLoginView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _submitLogin() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final notificationService = NotificationService();
      final fcmToken = await notificationService.getFCMToken();

      if (fcmToken == null) {
        throw Exception('driverLogin.errors.fcmTokenError'.tr());
      }

      log('FCM Token: $fcmToken');

      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (email.isEmpty || password.isEmpty) {
        throw Exception('driverLogin.errors.fillAllFields'.tr());
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final error = await authProvider.login(email, password, fcmToken);

      if (!mounted) return;

      if (error == null) {
        await saveTokenLocally(fcmToken);
        Navigator.pushReplacementNamed(context, AppDriverRoutes.rideBooking);
      } else {
        setState(() => _errorMessage = error);
      }
    } catch (e) {
      log('Login error: $e');
      if (!mounted) return;
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> saveTokenLocally(String? token) async {
    if (token != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('driver_fcm_token', token);
      log('Driver FCM token saved locally: $token');
    }
  }

  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'driverLogin.emailRequired'.tr();
    }
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      caseSensitive: false,
    );
    if (!emailRegExp.hasMatch(value)) {
      return 'driverLogin.emailInvalid'.tr();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Container(
                  width: 412,
                  height: screenHeight * 0.45,
                  padding: const EdgeInsets.only(top: 100),
                  child: Image.asset(
                    'assets/images/sigin.png',
                    width: 412,
                    height: 368,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                flex: 6,
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.backgroundDark,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'driverLogin.signIn'.tr(),
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        CustomTextFormField(
                          icon: Icons.email,
                          hintText: 'driverLogin.enterEmail'.tr(),
                          controller: _emailController,
                          validator: emailValidator,
                        ),
                        const SizedBox(height: 10),
                        CustomTextFormField(
                          icon: Icons.lock,
                          hintText: 'driverLogin.enterPassword'.tr(),
                          isPassword: true,
                          controller: _passwordController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'driverLogin.passwordRequired'.tr();
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
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
                              // Navigator.pushNamed(context, AppRoutes.userForgotPassword);
                            },
                            child: Text(
                              'driverLogin.forgotPassword'.tr(),
                              style: AppTextTheme.getPrimaryTextTheme(context).titleMedium,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        CustomButton(
                          isLoading: _isLoading,
                          text: 'driverLogin.signIn'.tr(),
                          onPressed: _submitLogin,
                          widthFactor: 0.8,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'driverLogin.dontHaveAccount'.tr(),
                              style: AppTextTheme.getDarkTextTheme(context).titleLarge,
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                    context, AppDriverRoutes.driverOverview);
                              },
                              child: Text(
                                'driverLogin.signUp'.tr(),
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
          Positioned(
            top: 40,
            right: 20,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: Colors.amber, width: 1),
              ),
              child: IconButton(
                onPressed: () async {
                  try {
                    if (context.locale == const Locale('en')) {
                      await context.setLocale(const Locale('es'));
                    } else {
                      await context.setLocale(const Locale('en'));
                    }
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            context.locale.languageCode == 'en'
                                ? 'Language changed to English'
                                : 'Idioma cambiado a Español',
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Error changing language'),
                        ),
                      );
                    }
                  }
                },
                icon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.language,
                      size: 20,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      context.locale.languageCode.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}