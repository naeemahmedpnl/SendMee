



// UserContactCard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sendme/utils/theme/app_text_theme.dart';
import 'package:sendme/viewmodel/provider/message_provider/chatroom_provider.dart';
import 'package:sendme/views/Driver_panel/messages/messages_screen.dart';


class UserContactCard extends StatelessWidget {
  final String userName;
  final String userRating;
  final String userImageUrl;
  final String tripDistance;
  final String userId;
  final String driverId;
  final String phoneNumber;

  UserContactCard({
    required this.userName,
    required this.userRating,
    required this.userImageUrl,
    required this.tripDistance,
    required this.userId,
    required this.driverId,
    required this.phoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatRoomProvider>(context);
    final screenSize = MediaQuery.of(context).size;
    final fontSize = screenSize.width * 0.04;

    return Container(
      width: screenSize.width * 0.9,
      padding: EdgeInsets.all(screenSize.width * 0.03),
      decoration: BoxDecoration(
        color: Color(0xFFF5FFE8),
        borderRadius: BorderRadius.circular(screenSize.width * 0.03),
      ),
      child: Row(
        children: [
          // User Image
          CircleAvatar(
            radius: screenSize.width * 0.08,
            backgroundImage: userImageUrl.isNotEmpty
                ? NetworkImage(userImageUrl)
                : AssetImage("assets/images/profile.png") as ImageProvider,
          ),
          SizedBox(width: screenSize.width * 0.03),
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: AppTextTheme.getLightTextTheme(context).headlineMedium?.copyWith(fontSize: fontSize),
                ),
                SizedBox(height: screenSize.height * 0.005),
                Text(
                  "Trip Distance: $tripDistance",
                  style: AppTextTheme.getLightTextTheme(context).titleLarge?.copyWith(fontSize: fontSize * 0.8),
                ),
                SizedBox(height: screenSize.height * 0.005),
                Text(
                  "Rating: $userRating",
                  style: AppTextTheme.getLightTextTheme(context).titleLarge?.copyWith(fontSize: fontSize * 0.8),
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
                  bool success = await chatProvider.createChatroom(targetUserId: userId);
                  if (success) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DriverChatScreen(
                          phoneNumber: phoneNumber,
                          userName: userName,
                          // userImageUrl: userImageUrl,
                          userId: userId,
                          driverId: driverId,
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
                  // Call the user
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
