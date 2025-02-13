import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sendme/models/user_model.dart';
import 'package:sendme/utils/routes/user_panel_routes.dart';
import 'package:sendme/utils/theme/app_text_theme.dart';
import 'package:sendme/viewmodel/provider/auth_provider/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.fetchUserData();
      final user = await authProvider.getUserData();

      setState(() {
        userData = user;
        isLoading = false;
      });
    } catch (e) {
      log('Error loading user data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildRatingStars() {
    double averageRating = userData?.passengerDetails?.ratingAverage ?? 0.0;
    int fullStars = averageRating.floor();
    bool hasHalfStar = (averageRating - fullStars) >= 0.5;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...List.generate(fullStars,
            (index) => const Icon(Icons.star, color: Colors.yellow, size: 20)),
        if (hasHalfStar)
          const Icon(Icons.star_half, color: Colors.yellow, size: 20),
        ...List.generate(
            5 - fullStars - (hasHalfStar ? 1 : 0),
            (index) =>
                const Icon(Icons.star_border, color: Colors.yellow, size: 20)),
        const SizedBox(width: 4.0),
        Text(averageRating.toStringAsFixed(1),
            style: const TextStyle(color: Colors.white)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      // backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_outlined,
                        color: Colors.black54, size: 25),
                  ),
                  Text("profile.title".tr(),
                      style: AppTextTheme.getLightTextTheme(context)
                          .headlineMedium),
                  IconButton(
                    onPressed: () => Navigator.pushNamed(
                        context, AppRoutes.editProfileScreen),
                    icon: const Icon(Icons.edit, color: Colors.black, size: 25),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/images/profile.png'),
              ),
              const SizedBox(height: 8.0),
              Text(
                userData?.username ?? 'N/A',
                style: const TextStyle(color: Colors.black, fontSize: 24.0),
              ),
              const SizedBox(height: 4.0),
              _buildRatingStars(),
              const SizedBox(height: 16.0),
              ProfileHistoryCard(userData: userData),
              const SizedBox(height: 16.0),
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text("profile.wallet".tr(),
                      style:
                          AppTextTheme.getLightTextTheme(context).titleLarge)),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.walletScreen);
                },
                child: Container(
                  width: screenWidth,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black54),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 10),
                    child: Row(
                      children: [
                        Image.asset(
                            width: 28, height: 28, "assets/images/wallet.png"),
                        const SizedBox(width: 15),
                        Text(
                          'Wallet',
                          style: AppTextTheme.getLightTextTheme(context)
                              .titleLarge,
                        ),
                        const Spacer(),
                        Text(
                          '${userData?.walletBalance ?? 0}',
                          style: AppTextTheme.getLightTextTheme(context)
                              .titleLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileHistoryCard extends StatelessWidget {
  final User? userData; // Changed type from Map<String, dynamic>? to User?

  const ProfileHistoryCard({Key? key, this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
                context, 'profile.phone_label'.tr(), userData?.phone ?? 'N/A'),
            const Divider(
              color: Colors.black,
            ),
            _buildInfoRow(
                context, 'profile.email_label'.tr(), userData?.email ?? 'N/A'),
            const Divider(
              color: Colors.black,
            ),
            // If address is not in your User model, add it there
            _buildInfoRow(context, 'profile.address_label'.tr(),
                userData?.email ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextTheme.getLightTextTheme(context).bodyLarge),
          Flexible(
            child: Text(
              value,
              style: AppTextTheme.getLightTextTheme(context).bodySmall,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
