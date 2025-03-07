

import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sendme/models/user_model.dart';
import 'package:sendme/utils/theme/app_colors.dart';
import 'package:sendme/utils/theme/app_text_theme.dart';
import 'package:sendme/viewmodel/provider/auth_provider/auth_provider.dart';

import 'package:sendme/views/User_panel/profile_Screens/widgets/payment_method.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
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
      log('Wallet data refreshed. New balance: ${user?.walletBalance}');
    } catch (e) {
      log('Error loading user data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadUserData,
          child: Padding(
            padding: const EdgeInsets.only(top: 10, left: 25, right: 25),
            child: isLoading 
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          Text(
                            'wallet.title'.tr(),
                            style: AppTextTheme.getLightTextTheme(context).headlineMedium,
                          ),
                          const SizedBox(width: 50)
                        ],
                      ),
                      Expanded(
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            const SizedBox(height: 20),
                            BalanceWidget(
                              userData: userData,
                              onAddMoney: () async {
                                await showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.white,
                                  builder: (context) => PaymentMethodPopup(userData: userData),
                                );
                                // Refresh data after payment sheet is closed
                                _loadUserData();
                              },
                            ),
                            const SizedBox(height: 20),
                            // Text(
                            //   "wallet.transactions".tr(),
                            //   style: AppTextTheme.getLightTextTheme(context).headlineMedium
                            // ),
                            // ...transactions.map((transaction) => 
                            //   TransactionItem(transaction: transaction)
                            // ).toList(),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class BalanceWidget extends StatelessWidget {
  final User? userData;
  final VoidCallback onAddMoney;

  const BalanceWidget({
    Key? key,
    required this.userData,
    required this.onAddMoney,
  }) : super(key: key);

  String formatBalance(double? balance) {
    if (balance == null) return '\$0.00';
    return '\$${balance.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        color: const Color(0xFFF5FFE8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'wallet.balance'.tr(),
                    style: AppTextTheme.getLightTextTheme(context).titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatBalance(userData?.walletBalance),
                    style: AppTextTheme.getLightTextTheme(context).headlineLarge?.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onAddMoney,
              child: Container(
                width: 117,
                height: 109,
                decoration: BoxDecoration(
                  color: AppColors.buttonColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'wallet.add_money'.tr(),
                    style: AppTextTheme.getLightTextTheme(context).headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}