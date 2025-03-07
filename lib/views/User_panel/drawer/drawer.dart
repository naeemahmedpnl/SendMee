import 'dart:convert';
import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sendme/utils/routes/driver_panel_routes.dart';
import 'package:sendme/utils/routes/user_panel_routes.dart';
import 'package:sendme/utils/theme/app_colors.dart';
import 'package:sendme/viewmodel/provider/auth_provider/auth_provider.dart';
import 'package:sendme/views/User_panel/drawer/customdrawerheader.dart';
import 'package:sendme/widgets/custom_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

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
Future<void> _handleDriverModeNavigation(BuildContext context) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    
    // Get latest user data from SharedPreferences
    String? userData = prefs.getString('userData'); 
    if (userData != null) {
     
      final Map<String, dynamic> userMap = jsonDecode(userData);
      final String driverStatus = userMap['driverRoleStatus'] ?? '';
      log(" Driver Status: $driverStatus");

      if (!context.mounted) return;

      // Check if user is a driver
      final bool isDriver = userMap['isDriver'] ?? false;
      log("Is User a Driver: $isDriver");
      
      if (!isDriver) {
        Navigator.pushReplacementNamed(
          context,
          AppDriverRoutes.driverOverview,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('drawer.error.not_driver'.tr())),
        );
        return;
      }

      // If user is a driver, check their status
      switch (driverStatus.toLowerCase()) {
        case 'pending':
          _showPendingDialog(context);
          break;
        case 'ban':
          _showBannedDialog(context);
          break;
        case 'accepted':
        case 'unban':
          Navigator.pushReplacementNamed(
            context, 
            AppDriverRoutes.rideBooking,
          );
          break;
        default:
          log("❌ Invalid driver status: $driverStatus");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('drawer.error.invalid_status'.tr())),
          );
      }
    } else {
      log("❌ No user data found in SharedPreferences");
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('drawer.error.no_user_data'.tr())),
      );
    }
  } catch (e) {
    log("❌ Error in driver navigation: $e");
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('drawer.error.general'.tr())),
    );
  }
}


void _showPendingDialog(BuildContext context) {
  showDialog(
    barrierColor: Colors.white.withOpacity(0.5),
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.backgroundLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.all(20),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.pending_actions,
            size: 60,
            color: AppColors.primary,
          ),
          const SizedBox(height: 20),
          Text(
            'driver.status.pending.title'.tr(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          Text(
            'driver.status.pending.message'.tr(),
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Image.asset(
            "assets/images/pending.png",
            width: 150,
            height: 150,
          ),
          const SizedBox(height: 20),
          CustomButton(
            text: 'driver.status.actions.back'.tr(),
            onPressed: () {
              Navigator.pop(context);
            },
            borderRadius: 44,
          )
        ],
      ),
    ),
  );
}

void _showBannedDialog(BuildContext context) {
  showDialog(
    barrierColor: Colors.white.withOpacity(0.5),
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.backgroundLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.all(20),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.gpp_bad_rounded,
            size: 60,
            color: Colors.red,
          ),
          const SizedBox(height: 20),
          Text(
            'driver.status.banned.title'.tr(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          Text(
            'driver.status.banned.message'.tr(),
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Image.asset(
            "assets/images/ban.png",
            width: 150,
            height: 150,
          ),
          const SizedBox(height: 20),
          CustomButton(
            text: 'driver.status.actions.contact_support'.tr(),
            onPressed: () {
              // Add support contact functionality
              Navigator.pop(context);
            },
            borderRadius: 44,
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'driver.status.actions.back'.tr(),
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.backgroundLight,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          const CustomDrawerHeader(),
                          const CustomDivider(),
                          _buildDrawerItem(
                            context,
                            Icons.person,
                            'drawer.profile'.tr(),
                            AppRoutes.profileScreen,
                          ),
                          const CustomDivider(),
                          _buildDrawerItem(
                            context,
                            Icons.history,
                            'drawer.history'.tr(),
                            AppRoutes.historyScreen,
                          ),
                          const CustomDivider(),
                          _buildDrawerItem(
                            context,
                            Icons.lock_reset,
                            'drawer.reset_password'.tr(),
                            AppRoutes.changePassword,
                          ),
                          const CustomDivider(),
                          _buildDrawerItem(
                            context,
                            Icons.support,
                            'drawer.support'.tr(),
                            AppRoutes.supportScreen,
                          ),
                          const CustomDivider(),
                          _buildDrawerItem(
                            context,
                            Icons.settings,
                            'drawer.settings'.tr(),
                            null,
                          ),
                        ],
                      ),
                      const Expanded(child: SizedBox()),
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 22),
                            child: CustomButton(
                              text: 'drawer.driver_mode'.tr(),
                              onPressed: () {
                                _handleDriverModeNavigation(context);
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildDrawerItem(
                            context,
                            Icons.logout,
                            'drawer.logout'.tr(),
                            null,
                            onTap: () {
                              _logout(context); 
                            },
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    String? route, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: AppColors.buttonColor,
        child: Icon(
          icon,
          color: AppColors.backgroundDark,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.black, fontSize: 17),
      ),
      onTap: onTap ??
          () {
            if (route != null) {
              Navigator.pushNamed(context, route);
            }
          },
    );
  }
}




class CustomDivider extends StatelessWidget {
  const CustomDivider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Divider(
      thickness: 0.3,
      color: Colors.black26,
      indent: 12,
      endIndent: 12,
    );
  }
}