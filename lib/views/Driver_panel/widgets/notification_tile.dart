import 'package:flutter/material.dart';

import '../../../utils/theme/app_colors.dart';

class NotificationTile extends StatelessWidget {
  final String userName;
  final String messageText;
  final String time;
  // final String userImage;
  const NotificationTile({
    super.key,
    required this.userName,
    required this.messageText,
    required this.time,
    // required this.userImage,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      direction: DismissDirection.horizontal,
      key: const Key("1"),
      child: Column(
        children: [
          ListTile(
            onTap: () {
              // Navigator.of(context).push(
              //   MaterialPageRoute(
              //     builder: (context) => MessageDetailView(
              //       userName: userName,
              //       userImage: userImage,
              //     ),
              //   ),
              // );
            },
            title: Text(
              userName,
              style: const TextStyle(
                  color: AppColors.kGreyColor,
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              messageText,
              style: const TextStyle(
                color: AppColors.kGreyColor,
                fontFamily: "Montserrat",
              ),
            ),
            trailing: Text(
              time,
              style: const TextStyle(
                color: AppColors.kGreyColor,
                fontFamily: "Montserrat",
              ),
            ),
            leading: CircleAvatar(
                radius: 25,
                backgroundColor: AppColors.kGreyColor,
                child: Image.asset("assets/icons/announcement.png")),
          ),
          const Divider(
            thickness: 0.25,
            indent: 20,
            endIndent: 20,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
