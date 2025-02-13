

import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sendme/utils/routes/driver_panel_routes.dart' as dp;
import 'package:sendme/utils/routes/user_panel_routes.dart';
import 'package:sendme/utils/theme/app_colors.dart';
import 'package:sendme/viewmodel/provider/auth_provider/auth_provider.dart';
import 'package:sendme/views/User_panel/drawer/customdrawerheader.dart';
import 'package:sendme/widgets/custom_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String currentLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString('selected_language');
    if (savedLanguage != null) {
      setState(() {
        currentLanguage = savedLanguage;
      });
      if (mounted) {
        await context.setLocale(Locale(savedLanguage));
      }
    }
  }

  Future<void> changeLanguage(BuildContext context, String languageCode) async {
    setState(() {
      currentLanguage = languageCode;
    });
    
    // Save language in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', languageCode);
    
    // Update locale
    if (mounted) {
      await context.setLocale(Locale(languageCode));
    }
  }

  Future<void> _logout(BuildContext context) async {
  try {
    // Get SharedPreferences instance
    final prefs = await SharedPreferences.getInstance();
    
    // Clear all SharedPreferences data
    await prefs.clear();
    
    // Get AuthProvider and logout
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    
    if (context.mounted) {
      // Navigate to login screen and remove all previous routes
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.userLogin,
        (Route<dynamic> route) => false,
      );
    }
  } catch (e) {
    log('Error during logout: $e');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('drawer.error.logout'.tr())),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.backgroundLight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
            const   CustomDrawerHeader(),
              const Divider(
                color: Colors.white54,
                indent: 5,
                endIndent: 5,
              ),
              // Profile ListTile
              ListTile(
                leading: const CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.buttonColor,
                  child: Icon(
                    Icons.person,
                    color: AppColors.backgroundDark,
                    size: 20,
                  ),
                ),
                title: Text(
                  'drawer.profile'.tr(),
                  style: const TextStyle(color: Colors.black, fontSize: 20),
                ),
                onTap: () {
                  Navigator.of(context).pushNamed(dp.AppDriverRoutes.profile);
                },
              ),
              const CustomDivider(),
              // Language Switcher with fixed width trailing
              ListTile(
                leading: Container(
                  decoration: BoxDecoration(
                    color: AppColors.buttonColor,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  width: 36,
                  height: 36,
                  child: const Icon(
                    Icons.language,
                    color: AppColors.backgroundDark,
                    size: 20,
                  ),
                ),
                title: Text(
                  'drawer.language'.tr(),
                  style: const TextStyle(color: Colors.black, fontSize: 20),
                ),
                trailing: SizedBox(
                  width: 50, // Fixed width for trailing widget
                  child: Container(
                    height: 32,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.buttonColor, width: 1),
                    ),
                    child: Center(
                      child: Text(
                        currentLanguage.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                onTap: () async {
                  try {
                    if (currentLanguage == 'en') {
                      await changeLanguage(context, 'es');
                    } else {
                      await changeLanguage(context, 'en');
                    }

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('drawer.languageChanged'.tr()),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('drawer.languageError'.tr()),
                        ),
                      );
                    }
                  }
                },
              ),
              const CustomDivider(),
              ListTile(
                leading: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.buttonColor,
                  child: Image.asset("assets/icons/Vector-2.png"),
                ),
                title: Text(
                  'drawer.wallet'.tr(),
                  style: const TextStyle(color: Colors.black, fontSize: 20),
                ),
                onTap: () {
                  Navigator.of(context).pushNamed(dp.AppDriverRoutes.wallet);
                },
              ),
              const CustomDivider(),
              ListTile(
                leading: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.buttonColor,
                  child: Image.asset("assets/icons/Settings.png"),
                ),
                title: Text(
                  'drawer.notifications'.tr(),
                  style: const TextStyle(color: Colors.black, fontSize: 20),
                ),
                onTap: () {
                  Navigator.of(context).pushNamed(dp.AppDriverRoutes.notifications);
                },
              ),
              const CustomDivider(),
              ListTile(
                leading: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.buttonColor,
                  child: Image.asset("assets/icons/Vector-1.png"),
                ),
                title: Text(
                  'drawer.support'.tr(),
                  style: const TextStyle(color: Colors.black, fontSize: 20),
                ),
                onTap: () {
                  Navigator.of(context).pushNamed(dp.AppDriverRoutes.support);
                },
              ),
            ],
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: CustomButton(
                  text: 'drawer.passengerMode'.tr(),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, AppRoutes.parcelScreen);
                  },
                ),
              ),
              const SizedBox(height: 15),
              ListTile(
                leading: const CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.buttonColor,
                  child: Icon(
                    Icons.logout,
                    color: AppColors.backgroundDark,
                    size: 20,
                  ),
                ),
                title: Text(
                  'drawer.logout'.tr(),
                  style: const TextStyle(color: Colors.black, fontSize: 20),
                ),
                onTap: () {
                  _logout(context);
                },
              ),
              const SizedBox(
                height: 50,
              )
            ],
          ),
        ],
      ),
    );
  }
}

class CustomDivider extends StatelessWidget {
  const CustomDivider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Divider(
      thickness: 0.3,
      color: Colors.white54,
      indent: 12,
      endIndent: 12,
    );
  }
}