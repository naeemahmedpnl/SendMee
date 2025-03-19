import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:sendme/utils/theme/app_colors.dart';
import 'package:sendme/utils/theme/app_text_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});


     // Function to launch phone dialer
  Future<void> _launchPhoneDialer(String phoneNumber) async {
    final Uri uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch phone dialer';
    }
  }

  Future<void> _launchEmail(BuildContext context, String emailAddress) async {
    try {
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: emailAddress,
        queryParameters: {'subject': 'Support Inquiry'},
      );

      log('Attempting to launch: $emailUri');

      if (await canLaunchUrl(emailUri)) {
        await launchUrl(
          emailUri,
          mode: LaunchMode.externalApplication, 
        );
      } else {
        _showEmailFallbackDialog(context, emailAddress);
      }
    } catch (e) {
      _showEmailErrorSnackBar(context, e.toString());
    }
  }

  void _showEmailErrorSnackBar(BuildContext context, String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('support.whatsapp_error'.tr()),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showEmailFallbackDialog(BuildContext context, String emailAddress) {
    showDialog(
      barrierColor: Colors.black,
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Text('support.email_dialog.title'.tr()),
          content: Text(
            'support.email_dialog.content'.tr(args: [emailAddress]),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text('support.email_dialog.close'.tr()),
            ),
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: emailAddress));
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('support.email_dialog.copied'.tr())),
                );
              },
              child: Text('support.email_dialog.copy'.tr()),
            ),
          ],
        );
      },
    );
  }

  Future<void> _launchWhatsApp(BuildContext context, String phoneNumber) async {
    // Remove any non-numeric characters from the phone number
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    // Multiple URL formats to try
    final urlsToTry = [
      Uri.parse('https://wa.me/$cleanPhone'),
      Uri.parse('whatsapp://send?phone=$cleanPhone'),
    ];

    for (final url in urlsToTry) {
      try {
        log('Attempting WhatsApp URL: $url');

        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
          return;
        }
      } catch (e) {
        log('Error launching WhatsApp: $e');
      }
    }

    // If all attempts fail
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'Could not launch WhatsApp. Please check the app is installed.'),
        duration: Duration(seconds: 2),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColors.backgroundDark,
                      ),
                    ),
                    Text(
                      'support.title'.tr(),  
  style: AppTextTheme.getLightTextTheme(context).headlineSmall,
                    ),
                    const SizedBox(width: 50)
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'support.help_text'.tr(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.backgroundDark,
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'support.faq_section.title'.tr(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.backgroundDark,
                  ),
                ),
                const SizedBox(height: 10),
                ListTile(
                  leading: const Icon(Icons.question_answer, color: AppColors.primary),
                  title: Text(
                    'support.faq_section.booking'.tr(),
                    style: AppTextTheme.getLightTextTheme(context).titleSmall,
                  ),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.payment, color: AppColors.primary),
                  title: Text(
                    'support.faq_section.payment'.tr(),
                    style: AppTextTheme.getLightTextTheme(context).titleSmall,
                  ),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.cancel, color: AppColors.primary),
                  title: Text(
                    'support.faq_section.cancellation'.tr(),
                    style: AppTextTheme.getLightTextTheme(context).titleSmall,
                  ),
                  onTap: () {},
                ),

                Text(
                  'support.contact_section.title'.tr(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.backgroundDark,
                  ),
                ),
                const SizedBox(height: 10),
                    // Previous code remains the same until the phone ListTile
                ListTile(
                  leading: const Icon(Icons.phone, color: AppColors.primary),
                  title: Text(
                    'support.contact_section.call.title'.tr(),
                    style: AppTextTheme.getLightTextTheme(context).titleSmall,
                  ),
                  subtitle: Text(
                    'support.contact_section.call.phone'.tr(),
                    style: AppTextTheme.getLightTextTheme(context).titleSmall,
                  ),
                  onTap: () {
                    // Get the phone number from translation
                    final phoneNumber =
                        'support.contact_section.call.phone'.tr();
                    _launchPhoneDialer(phoneNumber);
                  },
                ),
                const SizedBox(height: 10),
                   ListTile(
                  leading: const Icon(Icons.email, color: AppColors.primary),
                  title: Text(
                    'support.contact_section.email.title'.tr(),
                    style: AppTextTheme.getLightTextTheme(context).titleSmall,
                  ),
                  subtitle: Text(
                    'support.contact_section.email.address'.tr(),
                    style: AppTextTheme.getLightTextTheme(context).titleSmall,
                  ),
                  onTap: () {
                    _launchEmail(context, 'support@ride-mexico.app');
                  },
                ),
                Text(
                  'support.feedback_section.title'.tr(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.backgroundDark,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'support.feedback_section.hint'.tr(),
                    filled: true,
                    fillColor: Color(0xFFE5E5E5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonColor,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'support.feedback_section.submit'.tr(),
                      style: const TextStyle(
                        fontSize: 18,
                        color: AppColors.backgroundDark,
                      ),
                    ),
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