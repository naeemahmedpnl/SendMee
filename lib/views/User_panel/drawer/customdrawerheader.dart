import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:rideapp/models/user_model.dart';
import 'package:rideapp/utils/theme/app_colors.dart';
import 'package:rideapp/viewmodel/provider/auth_provider/auth_provider.dart';

class CustomDrawerHeader extends StatefulWidget {
  const CustomDrawerHeader({super.key});

  @override
  State<CustomDrawerHeader> createState() => _CustomDrawerHeaderState();
}

class _CustomDrawerHeaderState extends State<CustomDrawerHeader> {
 User? userData; 

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    AuthProvider authService = AuthProvider();
    
    // First, try to get cached data
    var data = await authService.getUserData();
    
    if (data == null) {
      // If no cached data, fetch from API
      await authService.fetchUserData();
      data = await authService.getUserData();
    }

    if (mounted) {
      setState(() {
        userData = data; 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      color: AppColors.backgroundLight,
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Expanded(
              flex: 3,
              child: CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage("assets/images/profile.png"),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (userData != null) ...[
                      Text(
                        userData?.username ?? 'No name',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                       userData?.email ?? 'No email',
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ] else ...[
                      Text(
                        'drawer_header.loading'.tr(),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'drawer_header.guest_email'.tr(),
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}