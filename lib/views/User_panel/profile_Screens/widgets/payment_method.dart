import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sendme/models/user_model.dart';
import 'package:sendme/utils/theme/app_colors.dart';
import 'package:sendme/utils/theme/app_text_theme.dart';
import 'package:sendme/viewmodel/provider/auth_provider/auth_provider.dart';
import 'package:sendme/viewmodel/provider/payment_provider.dart';

class PaymentMethodPopup extends StatefulWidget {
  final User? userData;

  const PaymentMethodPopup({super.key, this.userData});

  @override
  State<PaymentMethodPopup> createState() => _PaymentMethodPopupState();
}

class _PaymentMethodPopupState extends State<PaymentMethodPopup> {
  String? selectedMethod;
  final TextEditingController amountController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final List<double> quickAmounts = [100, 200, 500, 1000];
  bool isProcessing = false;
  bool isLoading = true;
  bool isPolling = false;
  User? userData;
  String? pollUrl;
  int pollingAttempts = 0;
  static const int maxPollingAttempts = 60; 

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    amountController.dispose();
    phoneController.dispose();
    isPolling = false;
    super.dispose();
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

  Future<void> _processPayment(BuildContext context) async {
    // Validate inputs
    if (amountController.text.isEmpty || userData == null) {
      _showErrorSnackBar('Please enter a valid amount');
      return;
    }
    
    if (phoneController.text.isEmpty) {
      _showErrorSnackBar('Please enter your mobile number');
      return;
    }
    
    if (selectedMethod == null) {
      _showErrorSnackBar('Please select a payment method');
      return;
    }

    setState(() => isProcessing = true);
    log('Payment process started...');

    try {
      final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);

      // Handle mobile money payments
      if (selectedMethod == 'ecocash' || selectedMethod == 'onemoney') {
        final phoneNumber = phoneController.text;
        
        log('Processing ${selectedMethod!.toUpperCase()} payment');
        log('Amount: ${amountController.text}, Phone: $phoneNumber');
        
        final success = await paymentProvider.processMobilePayment(
          amount: double.parse(amountController.text),
          phone: phoneNumber,
          method: selectedMethod!,
        );
        
        if (success) {
          log('${selectedMethod!.toUpperCase()} payment initiated successfully');
          pollUrl = paymentProvider.pollUrl;
          
          if (mounted) {
            // Show processing dialog
            _showProcessingPaymentDialog(
              context, 
              paymentProvider.instructions ?? 'Please check your phone for payment instructions.'
            );
            
            // Start polling for payment status
            _startPollingPaymentStatus(context, paymentProvider);
          }
        } else {
          throw paymentProvider.errorMessage ?? '${selectedMethod!.toUpperCase()} payment failed';
        }
      }
    } catch (e) {
      log('Payment error: $e');
      if (mounted) {
        _showErrorSnackBar('Payment failed: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => isProcessing = false);
        log('Payment process completed');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _startPollingPaymentStatus(BuildContext context, PaymentProvider paymentProvider) {
    if (pollUrl == null) {
      log('Error: Poll URL is null, cannot check payment status');
      return;
    }
    
    // Reset polling attempts counter and set polling flag
    pollingAttempts = 0;
    isPolling = true;
    
    _pollPaymentStatus(context, paymentProvider);
  }
  
  Future<void> _pollPaymentStatus(BuildContext context, PaymentProvider paymentProvider) async {
    if (!mounted || !isPolling || pollingAttempts >= maxPollingAttempts) {
      if (pollingAttempts >= maxPollingAttempts) {
        log('Polling stopped after reaching maximum attempts');
        Navigator.of(context).pop(); // Close processing dialog
        _showPaymentTimeoutDialog(context);
      }
      return;
    }
    
    try {
      log('Polling payment status, attempt ${pollingAttempts + 1}/${maxPollingAttempts}');
      pollingAttempts++;
      
      final statusResponse = await paymentProvider.checkPaymentStatus(pollUrl!);
      log('Payment status update: $statusResponse');
      
      if (statusResponse['success'] == true) {
        if (statusResponse['status'] == 'paid') {
          log('Payment completed successfully!');
          isPolling = false;
          
          if (mounted) {
            Navigator.of(context).pop(); // Close processing dialog
            
            // Refresh user data to show updated balance
            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            await authProvider.fetchUserData();
            
            // Show success dialog after user data is refreshed
            _showSuccessDialog(context);
          }
        } else if (statusResponse['status'] == 'pending') {
          // Continue polling if payment is still pending
          Future.delayed(const Duration(seconds: 3), () { // Faster polling (3s instead of 5s)
            if (mounted && isPolling) {
              _pollPaymentStatus(context, paymentProvider);
            }
          });
        } else if (statusResponse['status'] == 'cancelled' || statusResponse['status'] == 'failed') {
          log('Payment was ${statusResponse['status']}');
          isPolling = false;
          
          if (mounted) {
            Navigator.of(context).pop(); // Close processing dialog
            _showErrorSnackBar('Payment ${statusResponse['status']}: ${statusResponse['message'] ?? 'Please try again'}');
          }
        }
      } else {
        log('Error checking payment status: ${statusResponse['error']}');
        
        // Continue polling despite error (could be temporary)
        Future.delayed(const Duration(seconds: 3), () { // Faster polling
          if (mounted && isPolling) {
            _pollPaymentStatus(context, paymentProvider);
          }
        });
      }
    } catch (e) {
      log('Exception during payment status polling: $e');
      
      // Continue polling despite exception
      Future.delayed(const Duration(seconds: 3), () { // Faster polling
        if (mounted && isPolling) {
          _pollPaymentStatus(context, paymentProvider);
        }
      });
    }
  }

  void _showPaymentTimeoutDialog(BuildContext context) {
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.access_time,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Payment Pending',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'We haven\'t received confirmation for your payment yet. If you completed the payment, your balance will be updated soon.',
                  style: TextStyle(color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          side: const BorderSide(color: AppColors.buttonColor),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(); 
                          Navigator.of(context).pop(); 
                        },
                        child: const Text(
                          'Close',
                          style: TextStyle(
                            color: AppColors.buttonColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
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
                          
                          // Show processing dialog again
                          _showProcessingPaymentDialog(context, 'Checking payment status...');
                          
                          // Restart polling
                          if (pollUrl != null) {
                            final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
                            _startPollingPaymentStatus(context, paymentProvider);
                          }
                        },
                        child: const Text(
                          'Check Again',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showProcessingPaymentDialog(BuildContext context, String instructions) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
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
                    Icons.phone_android,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Processing Payment',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  instructions,
                  style: const TextStyle(color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.buttonColor),
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Waiting for confirmation',
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
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
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Payment Successful!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '\$${amountController.text} has been added to your wallet',
                  style: const TextStyle(color: Colors.black87),
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
                      Navigator.of(context).pop(); 
                      Navigator.of(context).pop(); 
                    },
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
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
        color: AppColors.backgroundLight,
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
                style: AppTextTheme.getLightTextTheme(context).headlineMedium,
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Color(0xffF5FFE8)),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _PaymentMethodCard(
                  title: 'EcoCash',
                 imagePath: 'assets/images/ecocash.png',
                  isSelected: selectedMethod == 'ecocash',
                  onTap: () => setState(() => selectedMethod = 'ecocash'),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _PaymentMethodCard(
                  title: 'OneMoney',
              imagePath: 'assets/images/onemoney.png',
                  isSelected: selectedMethod == 'onemoney',
                  onTap: () => setState(() => selectedMethod = 'onemoney'),
                ),
              ),
            ],
          ),
          if (selectedMethod != null) ...[
            const SizedBox(height: 20),
            // Phone number input field
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              style: AppTextTheme.getLightTextTheme(context).bodyLarge,
              decoration: InputDecoration(
                fillColor: AppColors.secondary,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                hintText: selectedMethod == 'ecocash' ? '077X XXX XXX' : '073X XXX XXX',
                hintStyle: AppTextTheme.getDarkTextTheme(context).bodyMedium?.copyWith(
                      color: Colors.black,
                    ),
                prefixIcon: const Icon(Icons.phone, color: Colors.grey),
                labelText: 'Mobile Number',
                labelStyle: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 25),
            Text(
              'Select Amount',
              style: AppTextTheme.getLightTextTheme(context).titleMedium,
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
                fillColor: AppColors.secondary,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                hintText: 'Enter custom amount',
                hintStyle: AppTextTheme.getDarkTextTheme(context).bodyMedium?.copyWith(
                      color: Colors.black,
                    ),
                prefixIcon: const Icon(Icons.attach_money, color: Colors.grey),
                labelText: 'Amount',
                labelStyle: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isProcessing 
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
                        style: AppTextTheme.getLightTextTheme(context).titleMedium,
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
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodCard({
    required this.title,
    required this.imagePath,
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
          color: isSelected ? AppColors.buttonColor : AppColors.secondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.buttonColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
                 Image.asset(
              imagePath,
              width: 32,
              height: 32,
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
  final bool isSelected;

  const _QuickAmountButton({
    required this.amount,
    required this.onTap,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.buttonColor : AppColors.secondary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '\$${amount.toStringAsFixed(0)}',
          style: AppTextTheme.getLightTextTheme(context).titleSmall?.copyWith(
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}