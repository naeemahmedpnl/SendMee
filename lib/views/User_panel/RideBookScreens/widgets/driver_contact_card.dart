
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rideapp/utils/constant/api_base_url.dart';
// import 'package:rideapp/utils/constant/api_base_url.dart';
import 'package:rideapp/utils/theme/app_text_theme.dart';
import 'package:rideapp/viewmodel/provider/message_provider/chatroom_provider.dart';
import 'package:rideapp/views/User_panel/messages/messages_screen.dart';

class DriverContactCard extends StatelessWidget {
  final String driverName;
  final String driverRating;
  final String driverImageUrl;
  final String? driverBikename;
  final String userId;
  final String driverId;
  final String phoneNumber;

  DriverContactCard({
    required this.driverName,
    required this.driverRating,
    required this.driverImageUrl,
     this.driverBikename,
    required this.userId,
    required this.driverId,
    required this.phoneNumber,
  });

   @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatRoomProvider>(context);
    final screenSize = MediaQuery.of(context).size;
    final fontSize = screenSize.width * 0.04;

    


    // Construct the full image URL
    String fullImageUrl = driverImageUrl.isNotEmpty 
        ? '${Constants.apiBaseUrl}$driverImageUrl' 
        : '';

    return Container(
      width: screenSize.width * 0.9,
      padding: EdgeInsets.all(screenSize.width * 0.03),
      decoration: BoxDecoration(
        color: Color(0xFFF5FFE8),
        borderRadius: BorderRadius.circular(screenSize.width * 0.03),
      ),
      child: Row(
        children: [
          // Driver Image
       CircleAvatar(
            radius: screenSize.width * 0.08,
            backgroundColor: Colors.grey[200],
            child: ClipRRect(
              borderRadius: BorderRadius.circular(screenSize.width * 0.08),
              child: fullImageUrl.isNotEmpty
                  ? Image.network(
                      fullImageUrl,
                      width: screenSize.width * 0.16,
                      height: screenSize.width * 0.16,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        log('Error loading image: $error');
                        return Image.asset(
                          "assets/images/profile.png",
                          width: screenSize.width * 0.16,
                          height: screenSize.width * 0.16,
                          fit: BoxFit.cover,
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    )
                  : Image.asset(
                      "assets/images/profile.png",
                      width: screenSize.width * 0.16,
                      height: screenSize.width * 0.16,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          SizedBox(width: screenSize.width * 0.03),
          // Driver Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driverName,
                  style: AppTextTheme.getLightTextTheme(context)
                      .headlineMedium
                ),
                SizedBox(height: screenSize.height * 0.005),
                // Text(
                //   driverBikename,
                //   style: AppTextTheme.getLightTextTheme(context)
                //       .titleLarge
                //       ?.copyWith(fontSize: fontSize * 0.8),
                // ),
                SizedBox(height: screenSize.height * 0.001),
                Text(
                  driverRating,
                  style: AppTextTheme.getLightTextTheme(context)
                      .titleLarge
                      ?.copyWith(fontSize: fontSize * 0.9),
                ),
              ],
            ),
          ),
          // Contact Buttons
          Column(
            children: [
              _buildContactButton(
                context: context,
                image: "assets/icons/messageicon.png",
                onTap: chatProvider.isLoading ? null : () async {
                  bool success = await chatProvider.createChatroom(targetUserId: driverId);
                  if (success) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserChatScreen(

                          driverName: driverName,
                         driverImageUrl: driverImageUrl,
                          userId: userId,
                          driverId: driverId,
                          phoneNumber: phoneNumber,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to create chatroom. Please try again.'))
                    );
                  }
                },
                size: screenSize.width * 0.1,
              ),
              SizedBox(height: screenSize.height * 0.01),
              _buildContactButton(
                context: context,
                image: "assets/icons/callicon.png",
                onTap: () {
                  // Call the driver
                },
                size: screenSize.width * 0.1,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton({
    required BuildContext context,
    required String image,
    required VoidCallback? onTap,
    required double size,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Image.asset(
        image,
        width: size,
        height: size,
      ),
    );
  }
}
