

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sendme/utils/routes/driver_panel_routes.dart';
import 'package:sendme/utils/theme/app_text_theme.dart';
import 'package:sendme/viewmodel/provider/profile_provider.dart';

class ProfileView extends StatefulWidget {
  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().fetchProfileData();
    });
  }

  Widget buildRatingStars(double rating) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return const Icon(Icons.star, color: Colors.yellow, size: 20);
        } else if (index == rating.floor() && rating % 1 > 0) {
          return const Icon(Icons.star_half, color: Colors.yellow, size: 20);
        }
        return const Icon(Icons.star_border, color: Colors.yellow, size: 20);
      })
        ..add(const SizedBox(width: 4))
        ..add(Text(rating.toStringAsFixed(1),
            style: const TextStyle(color: Colors.white))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error.isNotEmpty) {
          return Center(child: Text(provider.error));
        }

        final profile = provider.profileData;
        if (profile == null) return const SizedBox();

        return Scaffold(
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
                        icon: const Icon(
                          Icons.arrow_back_ios_new_outlined,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                      Text(
                        'profile.title'.tr(),
                        style: AppTextTheme.getDarkTextTheme(context)
                            .headlineMedium,
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(profile.profilePicture),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    profile.username,
                    style: const TextStyle(color: Colors.white, fontSize: 24.0),
                  ),
                  const SizedBox(height: 4.0),
                  buildRatingStars(profile.ratingAverage),
                  const SizedBox(height: 16.0),
                  Container(
                   
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEEEEE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildInfoRow(
                              'profile.phone_label'.tr(), profile.phone),
                          const SizedBox(height: 8.0),
                          _buildInfoRow(
                              'profile.email_label'.tr(), profile.email),
                          const SizedBox(height: 8.0),
                          const SizedBox(height: 8.0),
                          _buildInfoRow(
                              'profile.address_label'.tr(), profile.address),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEEEEE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'profile.total_earnings'.tr(),
                          style:
                              AppTextTheme.getLightTextTheme(context).bodyLarge,
                        ),
                        Text(
                          "\$${profile.totalEarnings}",
                          style:
                              AppTextTheme.getLightTextTheme(context).bodyLarge,
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              child: _buildStatColumn(
                                'profile.as_driver'.tr(),
                                profile.totalRides['asDriver'].toString(),
                              ),
                            ),
                            Expanded(
                              child: _buildStatColumn(
                                'profile.as_passenger'.tr(),
                                profile.totalRides['asPassenger'].toString(),
                              ),
                            ),
                            Expanded(
                              child: _buildStatColumn(
                                'profile.total_rides'.tr(),
                                profile.totalRides['total'].toString(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'profile.wallet'.tr(),
                      style: AppTextTheme.getDarkTextTheme(context).titleLarge,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, AppDriverRoutes.wallet);
                    },
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                  color: const Color(0xFFEEEEEE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 10),
                        child: Row(
                          children: [
                            Image.asset(
                                width: 28,
                                height: 28,
                                "assets/images/wallet.png"),
                            const SizedBox(width: 15),
                            Text(
                              'profile.wallet'.tr(),
                              style: AppTextTheme.getLightTextTheme(context)
                                  .titleLarge,
                            ),
                            const SizedBox(width: 150),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'profile.payment_method'.tr(),
                      style: AppTextTheme.getDarkTextTheme(context).titleLarge,
                    ),
                  ),
                  const SizedBox(height: 10),
               
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextTheme.getLightTextTheme(context).bodyLarge),
        Text(value, style: AppTextTheme.getLightTextTheme(context).bodyLarge),
      ],
    );
  }

Widget _buildStatColumn(String label, String value) {
  return Column(
    children: [
      Text(
        label,
        style: AppTextTheme.getLightTextTheme(context).labelMedium,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
      Text(
        value,
        style: AppTextTheme.getLightTextTheme(context).labelMedium,
        textAlign: TextAlign.center,
      ),
    ],
  );
}
}
