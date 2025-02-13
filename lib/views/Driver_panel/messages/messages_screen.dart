
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sendme/utils/theme/app_text_theme.dart';
import 'package:sendme/viewmodel/provider/message_provider/chatroom_provider.dart';

class DriverChatScreen extends StatefulWidget {
  final String phoneNumber;
  final String userName;
  final String userId;
  final String driverId;

  const DriverChatScreen({
    Key? key,
    required this.phoneNumber,
    required this.userName,
    required this.userId,
    required this.driverId,
  }) : super(key: key);

  @override
  _DriverChatScreenState createState() => _DriverChatScreenState();
}

class _DriverChatScreenState extends State<DriverChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = Provider.of<ChatRoomProvider>(context, listen: false);
      chatProvider.initSocket(); // Initialize socket connection
      chatProvider.getMessages(); // Get existing messages
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.userName,
              style: AppTextTheme.getLightTextTheme(context)
                  .headlineSmall
                  ?.copyWith(fontSize: fontSize),
            ),
            Text(
              widget.phoneNumber,
              style: AppTextTheme.getLightTextTheme(context)
                  .titleSmall
                  ?.copyWith(fontSize: fontSize * 0.8),
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
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
                    final isMe = message['Sender'] == widget.driverId;

                    return Padding(
                      padding: EdgeInsets.only(bottom: screenSize.height * 0.01),
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
                            color: isMe ? Colors.blue[100] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(screenSize.width * 0.05),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message['message'] ?? '',
                                style: TextStyle(
                                  fontSize: fontSize,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: screenSize.height * 0.004),
                              Text(
                                _formatTime(message['createdOn'] ?? ''),
                                style: TextStyle(
                                  fontSize: fontSize * 0.7,
                                  color: Colors.grey[600],
                                ),
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
            padding: EdgeInsets.all(screenSize.width * 0.03),
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
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(screenSize.width * 0.05),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: screenSize.width * 0.04,
                        vertical: screenSize.height * 0.015,
                      ),
                    ),
                    maxLines: null,
                  ),
                ),
                SizedBox(width: screenSize.width * 0.02),
                Consumer<ChatRoomProvider>(
                  builder: (context, chatProvider, child) {
                    return IconButton(
                      onPressed: chatProvider.isLoading
                          ? null
                          : () async {
                              if (_messageController.text.trim().isEmpty) return;
                              
                              final success = await chatProvider.sendMessage(
                                _messageController.text.trim(),
                              );

                              if (success) {
                                _messageController.clear();
                                _scrollToBottom();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to send message. Please try again.'),
                                  ),
                                );
                              }
                            },
                      icon: Icon(
                        Icons.send,
                        color: Colors.blue,
                        size: screenSize.width * 0.07,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}