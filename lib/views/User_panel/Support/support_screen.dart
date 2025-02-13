import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rideapp/utils/theme/app_colors.dart';
import 'package:rideapp/utils/theme/app_text_theme.dart';

class SupportScreen extends StatelessWidget {
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
                  onTap: () {},
                ),
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
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.chat, color: AppColors.primary),
                  title: Text(
                    'support.contact_section.chat'.tr(),
                    style: AppTextTheme.getLightTextTheme(context).titleSmall,
                  ),
                  onTap: () {},
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