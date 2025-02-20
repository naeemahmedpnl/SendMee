

import 'dart:convert';
import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sendme/models/user_model.dart';
import 'package:sendme/utils/routes/user_panel_routes.dart';
import 'package:sendme/utils/theme/app_colors.dart';
import 'package:sendme/utils/theme/app_text_theme.dart';
import 'package:sendme/viewmodel/provider/auth_provider/auth_provider.dart';
import 'package:sendme/views/User_panel/drawer/drawer.dart';
import 'package:sendme/widgets/custom_button.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ParcelScreen extends StatefulWidget {
  const ParcelScreen({super.key});

  @override
  State<ParcelScreen> createState() => _ParcelScreenState();
}

class _ParcelScreenState extends State<ParcelScreen> {
  User? userData;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> saveParcelType(String type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('parcelType', type);
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      log('Starting to fetch user data...');
      final prefs = await SharedPreferences.getInstance();
      final existingToken = prefs.getString('token');
      log('Existing token from SharedPreferences: $existingToken');

      AuthProvider authService = AuthProvider();
      await authService.fetchUserData();
      var data = await authService.getUserData();
      
      if (data != null) {
        setState(() {
          userData = data;
        });

        if (userData != null) {
          Map<String, dynamic> userMap = userData!.toJson(); 
          await prefs.setString('userData', jsonEncode(userMap));
          
          String? token = await authService.getToken();
          if (token != null) {
            await prefs.setString('token', token); 
          }
          
          log('=========== Verification ===========');
          log('Saved User Data: ${prefs.getString('userData')}');
          log('Saved Token: ${prefs.getString('token')}');
          log('===================================');
        }
      }
    } catch (e) {
      log('Error in fetchData: $e');
      rethrow;
    }
  }

  Future<void> _onRefresh()async {
    await fetchData();
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    key: _scaffoldKey,
    drawer: const CustomDrawer(),
    backgroundColor: AppColors.primary,
    body: RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.primary,
      child: SafeArea(
        child: Column(
          children: [
            // App Bar Section
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.menu,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                  ),
                ],
              ),
            ),
            
            // Make the content scrollable for RefreshIndicator to work
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height - 
                             MediaQuery.of(context).padding.top - 
                             56, // AppBar height
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          // Image Section
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.3,
                            child: Image.asset(
                              'assets/images/Ridebooking.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                          
                          const SizedBox(height: 5),
                        ],
                      ),
                      
                      // Bottom Container Section
                      Container(
                        height: MediaQuery.of(context).size.height * 0.55,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: AppColors.backgroundLight,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 50,
                            left: 30,
                            right: 30,
                            bottom: 30
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'parcel.title'.tr(),
                                style: AppTextTheme.getLightTextTheme(context).headlineMedium
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'parcel.subtitle'.tr(),
                                style: AppTextTheme.getLightTextTheme(context).bodyLarge
                              ),
                              const SizedBox(height: 30),
                              GestureDetector(
                                onTap: () async {
                                  await saveParcelType('receive');
                                  if (mounted) {
                                    Navigator.pushNamed(context, AppRoutes.parcelSendingScreen);
                                  }
                                },
                                child: Container(
                                  height: 54,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppColors.primary,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'parcel.receive_button'.tr(),
                                      style: AppTextTheme.getPrimaryTextTheme(context).titleLarge,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              CustomButton(
                                text: 'parcel.send_button'.tr(),
                                onPressed: () async {
                                  await saveParcelType('send');
                                  if (mounted) {
                                    Navigator.pushNamed(context, AppRoutes.parcelReceivingScreen);
                                  }
                                },
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
          ],
        ),
      ),
    ),
  );
}}