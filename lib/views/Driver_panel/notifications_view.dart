import 'package:flutter/material.dart';
import '../../utils/theme/app_colors.dart';
import 'widgets/notification_tile.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        title: const Text(
          "Notifications",
          style: TextStyle(
            // color: Color(0xffB1A0A0),
            color: AppColors.kGreyColor,
            fontFamily: "Montserrat",
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.kGreyColor,
          ),
        ),
      ),
      body: const Column(
        children: [
          NotificationTile(userName: "Adam", messageText: "adam give you 5 star rating..", time: "1 hr"),
          NotificationTile(userName: "Adam", messageText: "adam give you 5 star rating..", time: "1 hr"),
          NotificationTile(userName: "Adam", messageText: "adam give you 5 star rating..", time: "1 hr"),
          NotificationTile(userName: "Adam", messageText: "adam give you 5 star rating..", time: "1 hr"),
        ],
      ),
    );
  }
}
