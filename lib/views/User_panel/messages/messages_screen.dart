
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sendme/utils/theme/app_text_theme.dart';
import 'package:sendme/viewmodel/provider/message_provider/chatroom_provider.dart';

class UserChatScreen extends StatefulWidget {
  final String driverName;
  final String driverImageUrl;
  final String userId;
  final String driverId;
  final String phoneNumber;

  const UserChatScreen({
    super.key,
    required this.driverName,
    required this.driverImageUrl,
    required this.userId,
    required this.driverId,
    required this.phoneNumber,
  });

  @override
  State<UserChatScreen> createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider =
          Provider.of<ChatRoomProvider>(context, listen: false);
      chatProvider.initSocket();
      chatProvider.getMessages();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final fontSize = screenSize.width * 0.04;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: screenSize.width * 0.05,
              backgroundImage: widget.driverImageUrl.isNotEmpty
                  ? NetworkImage(widget.driverImageUrl)
                  : AssetImage("assets/images/profile.png") as ImageProvider,
            ),
            SizedBox(width: screenSize.width * 0.03),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.driverName,
                    style: AppTextTheme.getLightTextTheme(context)
                        .headlineSmall
                        ?.copyWith(fontSize: fontSize),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.phoneNumber,
                    style: AppTextTheme.getLightTextTheme(context)
                        .titleSmall
                        ?.copyWith(fontSize: fontSize * 0.8),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: Consumer<ChatRoomProvider>(
              builder: (context, chatProvider, child) {
                if (chatProvider.isLoading) {
                  return Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
  controller: _scrollController,
  padding: EdgeInsets.all(screenSize.width * 0.03),
  itemCount: chatProvider.messages.length,
  itemBuilder: (context, index) {
    final message = chatProvider.messages[index];
    
    // Debug logs
    log('Message Data:');
    log('Sender ID: ${message['Sender']}');
    log('Current User ID: ${widget.userId}');
    log('Current Driver ID: ${widget.driverId}');
    log('Message Text: ${message['message']}');

    // If message sender matches driverId, it's from driver
    final isMe = message['Sender'] != widget.driverId;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: screenSize.height * 0.005,
        horizontal: screenSize.width * 0.02,
      ),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: screenSize.width * 0.7,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: screenSize.width * 0.04,
            vertical: screenSize.height * 0.01,
          ),
          decoration: BoxDecoration(
            color: isMe 
              ? Theme.of(context).primaryColor.withOpacity(0.2) 
              : Colors.grey[200],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(screenSize.width * 0.04),
              topRight: Radius.circular(screenSize.width * 0.04),
              bottomLeft: isMe 
                ? Radius.circular(screenSize.width * 0.04)
                : Radius.circular(0),
              bottomRight: isMe 
                ? Radius.circular(0)
                : Radius.circular(screenSize.width * 0.04),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Debug text to show sender (remove in production)
                  Text(
                    '(${message['Sender'] == widget.driverId ? "Driver" : "User"})',
                    style: TextStyle(
                      fontSize: fontSize * 0.6,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              Text(
                message['message'] ?? '',
                style: TextStyle(
                  fontSize: fontSize,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: screenSize.height * 0.004),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(message['createdOn'] ?? ''),
                    style: TextStyle(
                      fontSize: fontSize * 0.7,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (isMe) ...[
                    SizedBox(width: screenSize.width * 0.01),
                    Icon(
                      Icons.done_all,
                      size: fontSize * 0.8,
                      color: message['read'] == true 
                        ? Colors.blue 
                        : Colors.grey[400],
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  },
);
              },
            ),
          ),

          // Message Input
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.03,
              vertical: screenSize.height * 0.01,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius:
                            BorderRadius.circular(screenSize.width * 0.06),
                      ),
                      child: TextFormField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: screenSize.width * 0.04,
                            vertical: screenSize.height * 0.015,
                          ),
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                  ),
                  SizedBox(width: screenSize.width * 0.02),
                  Consumer<ChatRoomProvider>(
                    builder: (context, chatProvider, child) {
                      return Material(
                        color: Theme.of(context).primaryColor,
                        borderRadius:
                            BorderRadius.circular(screenSize.width * 0.06),
                        child: InkWell(
                          borderRadius:
                              BorderRadius.circular(screenSize.width * 0.06),
                          onTap: chatProvider.isLoading
                              ? null
                              : () async {
                                  if (_messageController.text.trim().isEmpty)
                                    return;

                                  final success =
                                      await chatProvider.sendMessage(
                                    _messageController.text.trim(),
                                  );

                                  if (success) {
                                    _messageController.clear();
                                    _scrollToBottom();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Failed to send message. Please try again.'),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                },
                          child: Container(
                            padding: EdgeInsets.all(screenSize.width * 0.035),
                            child: Icon(
                              Icons.send,
                              color: Colors.white,
                              size: screenSize.width * 0.06,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    final now = DateTime.now();

    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }

    return '${dateTime.day}/${dateTime.month} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
