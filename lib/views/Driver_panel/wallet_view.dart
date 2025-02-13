
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:sendme/utils/theme/app_colors.dart';
import 'package:sendme/utils/theme/app_text_theme.dart';

class WalletView extends StatefulWidget {
  @override
  State<WalletView> createState() => _WalletViewState();
}

class _WalletViewState extends State<WalletView> {
  final amount = 3000;

  // final List<Transaction> transactions = [
  //   Transaction(reference: 'KHIE2323423443', amount: 230),
  //   Transaction(reference: 'KHIE2323423443', amount: 220),
  // ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 10, left: 25, right: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  Text(
                    'wallet.title'.tr(),
                    style: AppTextTheme.getDarkTextTheme(context).headlineMedium,
                  ),
                  const SizedBox(width: 50)
                ],
              ),
              const SizedBox(height: 20),
              BalanceWidget(amount: amount),
              const SizedBox(height: 20),
              Text(
                'wallet.transactions'.tr(),
                style: AppTextTheme.getDarkTextTheme(context).headlineMedium
              ),
              // Expanded(
              //   child: ListView.builder(
              //     itemCount: transactions.length,
              //     itemBuilder: (context, index) {
              //       final transaction = transactions[index];
              //       return TransactionItem(transaction: transaction);
              //     },
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class BalanceWidget extends StatelessWidget {
  final int amount;

  const BalanceWidget({required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
      color: const Color(0xFFEEEEEE),
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
                  // Using NumberFormat for localized number formatting
                  Text(
                    amount.toString(),
                    style: AppTextTheme.getLightTextTheme(context).headlineLarge,
                  ),
                ],
              ),
            ),
            Container(
              width: 117,
              height: 109,
              decoration: BoxDecoration(
                color: AppColors.buttonColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'wallet.withdrawMoney'.tr(),
                  style: AppTextTheme.getLightTextTheme(context).headlineSmall,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// class TransactionItem extends StatelessWidget {
//   final Transaction transaction;

//   const TransactionItem({required this.transaction});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppColors.backgroundLight,
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             transaction.reference,
//             style: AppTextTheme.getLightTextTheme(context).titleSmall,
//           ),
//           // Using NumberFormat for localized number formatting
//           Text(
//             transaction.amount.toString(),
//             style: AppTextTheme.getLightTextTheme(context).headlineSmall,
//           ),
//         ],
//       ),
//     );
//   }
// }

// class Transaction {
//   final String reference;
//   final double amount;

//   Transaction({required this.reference, required this.amount});
// }