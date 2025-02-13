import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rideapp/models/user_model.dart';
import 'package:rideapp/utils/theme/app_colors.dart';
import 'package:rideapp/utils/theme/app_text_theme.dart';
import 'package:rideapp/viewmodel/provider/auth_provider/auth_provider.dart';
import 'package:rideapp/viewmodel/provider/payment_provider.dart';

class PaymentMethodPopup extends StatefulWidget {
  final User? userData;

  const PaymentMethodPopup({this.userData});

  @override
  _PaymentMethodPopupState createState() => _PaymentMethodPopupState();
}

class _PaymentMethodPopupState extends State<PaymentMethodPopup> {
  String? selectedMethod;
  final TextEditingController amountController = TextEditingController();
  final List<double> quickAmounts = [100, 200, 500, 1000];
  bool isProcessing = false;
  bool isLoading = true;
  User? userData;

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

      if (mounted) {
        setState(() {
          userData = user;
          isLoading = false;
        });
      }

      log('PaymentMethodPopup - User data loaded:');
      log('User ID: ${userData?.id}');
      log('Full User Data: $userData');
    } catch (e) {
      log('Error loading user data: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

// Replace your existing _processPayment method with this fixed version:
Future<void> _processPayment(BuildContext context) async {
  if (amountController.text.isEmpty || userData == null) {
    log('Payment cancelled - amount empty or user data null');
    log('Amount: ${amountController.text}');
    log('User data: $userData');
    return;
  }

  setState(() => isProcessing = true);
  log('Payment process started...');

  try {
    final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);

    // Check selected payment method
    if (selectedMethod == 'card') {
        final userId = userData?.id;
        log('Processing card payment for user ID: $userId');
        log('Amount to be charged: ${amountController.text}');

        if (userId == null || userId.isEmpty) {
          throw 'User ID not found';
        }

        log('Initiating Stripe payment...');
        final success = await paymentProvider.makePayment(amountController.text);
        log('Stripe payment result: $success');

        if (success) {
          log('Stripe payment successful, updating wallet...');

          final walletSuccess = await paymentProvider.updateWalletBalance(
            userId,
            double.parse(amountController.text),
          );
          log('Wallet update result: $walletSuccess');

          if (walletSuccess) {
            log('Wallet updated successfully, refreshing user data...');

            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            await authProvider.fetchUserData();

            if (mounted) {
              _showSuccessDialog(context);
              log('Success dialog shown');
            }
          } else {
            throw 'Failed to update wallet balance';
          }
        } else if (paymentProvider.errorMessage != null) {
          throw paymentProvider.errorMessage!;
        }

    } else if (selectedMethod == 'oxxo') {
      log('Processing OXXO payment');
       // First parse as double to handle any decimal input
        double doubleAmount = double.parse(amountController.text);
        // Convert to whole number by rounding
        final amount = doubleAmount.round();
      log(" amount is  $amount");
      if (amount <= 0) {
        throw 'Invalid amount enterrrrred';
      }

      final success = await paymentProvider.getWalletPayment(amount);

      if (success) {
        log('OXXO payment successful');
        if (mounted) {
          _showSuccessDialog(context);
        }
      } else {
        throw paymentProvider.errorMessage ?? 'OXXO payment failed';
      }
    }
  } catch (e) {
    log('Payment error: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } finally {
    if (mounted) {
      setState(() => isProcessing = false);
      log('Payment process completed');
    }
  }
}
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: AppColors.backgroundDark,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AppColors.buttonColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Payment Successful!',
                  style: AppTextTheme.getDarkTextTheme(context).headlineMedium,
                ),
                const SizedBox(height: 10),
                Text(
                  '\$${amountController.text} has been added to your wallet',
                  style: AppTextTheme.getLightTextTheme(context).bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonColor,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      Navigator.of(context).pop(); // Close payment sheet
                    },
                    child: Text(
                      'Close',
                      style: AppTextTheme.getLightTextTheme(context).titleMedium,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Payment Method',
                style: AppTextTheme.getDarkTextTheme(context).headlineMedium,
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _PaymentMethodCard(
                  title: 'Credit Card',
                  icon: Icons.credit_card,
                  isSelected: selectedMethod == 'card',
                  onTap: () => setState(() => selectedMethod = 'card'),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _PaymentMethodCard(
                  title: 'OXXO',
                  icon: Icons.store,
                  isSelected: selectedMethod == 'oxxo',
                  onTap: () => setState(() => selectedMethod = 'oxxo'),
                ),
              ),
            ],
          ),
          if (selectedMethod != null) ...[
            const SizedBox(height: 25),
            Text(
              'Select Amount',
              style: AppTextTheme.getDarkTextTheme(context).titleMedium,
            ),
            const SizedBox(height: 15),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: quickAmounts
                  .map((amount) => _QuickAmountButton(
                        amount: amount,
                        onTap: () {
                          amountController.text = amount.toString();
                          setState(() {});
                        },
                        isSelected: amountController.text == amount.toString(),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: AppTextTheme.getLightTextTheme(context).bodyLarge,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                fillColor: AppColors.backgroundLight,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                hintText: 'Enter custom amount',
                hintStyle:
                    AppTextTheme.getDarkTextTheme(context).bodyMedium?.copyWith(
                          color: Colors.black,
                        ),
                prefixIcon: const Icon(Icons.attach_money, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isProcessing || amountController.text.isEmpty
                    ? null
                    : () => _processPayment(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonColor,
                  disabledBackgroundColor: AppColors.buttonColor.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Continue',
                        style:
                            AppTextTheme.getLightTextTheme(context).titleMedium,
                      ),
              ),
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodCard({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.buttonColor : AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.buttonColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? Colors.white : Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style:
                  AppTextTheme.getLightTextTheme(context).titleSmall?.copyWith(
                        color: isSelected ? Colors.white : Colors.grey,
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAmountButton extends StatelessWidget {
  final double amount;
  final VoidCallback onTap;

  const _QuickAmountButton({
    required this.amount,
    required this.onTap,
    required bool isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '\$${amount.toStringAsFixed(0)}',
          style: AppTextTheme.getLightTextTheme(context).titleSmall,
        ),
      ),
    );
  }
}
