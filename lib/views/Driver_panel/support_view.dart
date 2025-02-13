import 'package:flutter/material.dart';
import 'package:sendme/utils/theme/app_colors.dart';
import 'package:sendme/utils/theme/app_text_theme.dart';

class SupportView extends StatelessWidget {
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
                        IconButton(onPressed: (){
                          Navigator.pop(context);
                        }, icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: AppColors.backgroundDark,
                        )),
                        Text(
                          'Support',
                          style:AppTextTheme.getLightTextTheme(context).headlineSmall),
                           const SizedBox(
                            width: 50,
                          )
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'How can we help you?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.backgroundLight,
                  ),
                ),
                const SizedBox(height: 20),
        
                // Help Center / FAQ Section
                const Text(
                  'Help Center / FAQ',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.backgroundLight,
                  ),
                ),
                const SizedBox(height: 10),
                ListTile(
                  leading:
                      const Icon(Icons.question_answer, color: AppColors.primary),
                  title: Text('How to book a ride?',  style: AppTextTheme.getLightTextTheme(context).titleSmall),
                  onTap: () {
                    // Navigate to FAQ details or expand the content
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.payment, color: AppColors.primary),
                  title: Text('Payment methods',  style: AppTextTheme.getLightTextTheme(context).titleSmall),
                  onTap: () {
                    // Navigate to FAQ details or expand the content
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.cancel, color: AppColors.primary),
                  title:  Text('Cancellation policy',  style: AppTextTheme.getLightTextTheme(context).titleSmall),
                  onTap: () {
                    // Navigate to FAQ details or expand the content
                  },
                ),
             
        
                // Contact Us Section
                const Text(
                  'Contact Us',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.backgroundLight,
                  ),
                ),
                const SizedBox(height: 10),
                ListTile(
                  leading: const Icon(Icons.phone, color: AppColors.primary),
                  title: Text('Call Us',  style: AppTextTheme.getLightTextTheme(context).titleSmall),
                  subtitle: Text('+1 234 567 890',  style: AppTextTheme.getLightTextTheme(context).titleSmall),
                  onTap: () {
                    // Add phone call functionality
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.email, color: AppColors.primary),
                  title:  Text('Email Us', style: AppTextTheme.getLightTextTheme(context).titleSmall),
                  subtitle:  Text('support@sendmeapp.com', style: AppTextTheme.getLightTextTheme(context).titleSmall),
                  onTap: () {
                    // Add email functionality
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.chat, color: AppColors.primary),
                  title: Text('Chat with Us',  style: AppTextTheme.getLightTextTheme(context).titleSmall),
                  onTap: () {
                    // Navigate to chat screen
                  },
                ),
    
        
                // Feedback/Issue Submission Form
                const Text(
                  'Submit an Issue or Feedback',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.backgroundLight,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Describe your issue or feedback',
                    filled: true,
                    fillColor: AppColors.backgroundLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    // Submit issue or feedback
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonColor,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Submit',
                      style: TextStyle(
                          fontSize: 18, color: AppColors.backgroundDark),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
 // Use background color
    );
  }
}
