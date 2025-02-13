// // // import 'dart:io';
// // // import 'package:flutter/material.dart';
// // // import 'package:image_picker/image_picker.dart';
// // // import 'package:provider/provider.dart';
// // // import 'package:rideapp/models/messeage_model.dart';
// // // import 'package:rideapp/utils/theme/app_colors.dart';
// // // import 'package:rideapp/viewmodel/provider/message_provider/chat_provider.dart';
// // // import 'package:rideapp/viewmodel/provider/message_provider/chatroom_provider.dart';
// // // import 'package:url_launcher/url_launcher.dart';

// // // class UserChatScreen extends StatefulWidget {
// // //   final String driverName;
// // //   final String driverImageUrl;
// // //   final String userId;
// // //   final String driverId;
// // //   final String phoneNumber;

// // //   const UserChatScreen({
// // //     Key? key,
// // //     required this.driverName,
// // //     required this.driverImageUrl,
// // //     required this.userId,
// // //     required this.driverId,
// // //     required this.phoneNumber,
// // //   }) : super(key: key);

// // //   @override
// // //   _UserChatScreenState createState() => _UserChatScreenState();
// // // }

// // // class _UserChatScreenState extends State<UserChatScreen> {
// // //     final TextEditingController _controller = TextEditingController();
// // //   final ScrollController _scrollController = ScrollController();
// // //   ChatRoomProvider? _chatRoomProvider;
// // //   ChatMessageProvider? _chatProvider;

// // //    @override
// // //   void initState() {
// // //     super.initState();
// // //     // Initialize providers in initState
// // //     _chatRoomProvider = Provider.of<ChatRoomProvider>(context, listen: false);
// // //     _chatProvider = Provider.of<ChatMessageProvider>(context, listen: false);
// // //     _initializeChat();
// // //   }

// // // void _initializeChat() async {
// // //     await _chatProvider?.initialize();

// // //     try {
// // //       bool success = await _chatRoomProvider?.createChatroom(
// // //         targetUserId: widget.driverId
// // //       ) ?? false;

// // //       if (success) {
// // //         final existingChatroomId = _chatRoomProvider?.chatroomId;
// // //         if (existingChatroomId != null) {
// // //           _chatProvider?.socket?.emit('join-room', existingChatroomId);
// // //           await _chatProvider?.getMessages(existingChatroomId);
// // //           _scrollToBottom();

// // //           // Listen for new messages
// // //           _chatProvider?.socket?.on('receive-message', (data) {
// // //             if (mounted) {
// // //               setState(() {});
// // //               _scrollToBottom();
// // //             }
// // //           });
// // //         }
// // //       } else {
// // //         if (mounted) {
// // //           ScaffoldMessenger.of(context).showSnackBar(
// // //             const SnackBar(content: Text('Failed to initialize chat')),
// // //           );
// // //         }
// // //       }
// // //     } catch (e) {
// // //       log('Error initializing chat: $e');
// // //       if (mounted) {
// // //         ScaffoldMessenger.of(context).showSnackBar(
// // //           const SnackBar(content: Text('Error initializing chat')),
// // //         );
// // //       }
// // //     }
// // //   }

// // //   @override
// // //   void dispose() {
// // //     // Clean up without accessing providers
// // //     _chatProvider?.socket?.off('receive-message');
// // //     _controller.dispose();
// // //     _scrollController.dispose();
// // //     super.dispose();
// // //   }

// // //   // Function to show phone number dialog
// // //   void _showPhoneDialog() {
// // //     showDialog(
// // //       context: context,
// // //       builder: (BuildContext context) {
// // //         return AlertDialog(
// // //            backgroundColor: AppColors.backgroundDark,
// // //           shape: RoundedRectangleBorder(
// // //             borderRadius: BorderRadius.circular(15),
// // //           ),
// // //           title: Text(widget.driverName),
// // //           content: Column(
// // //             mainAxisSize: MainAxisSize.min,
// // //             children: [
// // //               Text(widget.phoneNumber),
// // //               const SizedBox(height: 20),
// // //               Row(
// // //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// // //                 children: [
// // //                   TextButton(
// // //                     onPressed: () => Navigator.pop(context),
// // //                     child: const Text('Cancel'),
// // //                   ),
// // //                   ElevatedButton(
// // //                     onPressed: () {
// // //                       Navigator.pop(context);
// // //                       _makePhoneCall();
// // //                     },
// // //                     style: ElevatedButton.styleFrom(
// // //                       backgroundColor: Colors.teal,
// // //                     ),
// // //                     child: const Text(
// // //                       'Call',
// // //                       style: TextStyle(color: Colors.white),
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //             ],
// // //           ),
// // //         );
// // //       },
// // //     );
// // //   }

// // //   Future<void> _makePhoneCall() async {
// // //   // Format phone number to remove any spaces or special characters
// // //   final phoneNumber = widget.phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

// // //   try {
// // //     final Uri phoneUri = Uri.parse('tel:$phoneNumber');

// // //     if (!context.mounted) return;

// // //     if (await canLaunchUrl(phoneUri)) {
// // //       await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
// // //     } else {
// // //       if (context.mounted) {
// // //         ScaffoldMessenger.of(context).showSnackBar(
// // //           const SnackBar(
// // //             content: Text('Could not launch phone dialer'),
// // //             backgroundColor: Colors.red,
// // //           ),
// // //         );
// // //       }
// // //     }
// // //   } catch (e) {
// // //     if (context.mounted) {
// // //       ScaffoldMessenger.of(context).showSnackBar(
// // //         SnackBar(
// // //           content: Text('Error: ${e.toString()}'),
// // //           backgroundColor: Colors.red,
// // //         ),
// // //       );
// // //     }
// // //   }
// // // }

// // //   void _sendMessage() {
// // //     if (_controller.text.isNotEmpty) {
// // //       context.read<ChatProvider>().sendMessage(_controller.text);
// // //       _controller.clear();
// // //       _scrollToBottom();
// // //     }
// // //   }

// // //   void _scrollToBottom() {
// // //     if (_scrollController.hasClients) {
// // //       _scrollController.animateTo(
// // //         _scrollController.position.maxScrollExtent,
// // //         duration: const Duration(milliseconds: 300),
// // //         curve: Curves.easeOut,
// // //       );
// // //     }
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(
// // //         backgroundColor: Colors.teal,
// // //         title: Row(
// // //           children: [
// // //             CircleAvatar(
// // //               backgroundImage: NetworkImage(widget.driverImageUrl),
// // //             ),
// // //             const SizedBox(width: 10),
// // //             Expanded(
// // //               child: Column(
// // //                 crossAxisAlignment: CrossAxisAlignment.start,
// // //                 children: [
// // //                   Text(
// // //                     widget.driverName,
// // //                     style: const TextStyle(fontSize: 16),
// // //                     overflow: TextOverflow.ellipsis,
// // //                   ),
// // //                   const Text('Driver', style: TextStyle(fontSize: 12)),
// // //                 ],
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //         actions: [
// // //            IconButton(
// // //             icon: const Icon(Icons.call),
// // //             onPressed: () async {
// // //               try {
// // //                 await _makePhoneCall();
// // //               } catch (e) {
// // //                 if (mounted) {
// // //                   ScaffoldMessenger.of(context).showSnackBar(
// // //                     SnackBar(
// // //                       content: Text('Failed to make call: $e'),
// // //                       backgroundColor: Colors.red,
// // //                     ),
// // //                   );
// // //                 }
// // //               }
// // //             },
// // //           ),
// // //           IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
// // //         ],
// // //       ),
// // //       body: Column(
// // //         children: [
// // //           Expanded(
// // //             child: Container(
// // //               color: const Color.fromARGB(255, 29, 29, 29),
// // //               child: Consumer<ChatProvider>(
// // //                 builder: (context, chatProvider, _) {
// // //                   if (chatProvider.isLoading) {
// // //                     return const Center(child: CircularProgressIndicator());
// // //                   }

// // //                   if (chatProvider.messages.isEmpty) {
// // //                     return const Center(
// // //                       child: Text('No messages yet'),
// // //                     );
// // //                   }

// // //                   return ListView.builder(
// // //                     controller: _scrollController,
// // //                     reverse: true,
// // //                     itemCount: chatProvider.messages.length,
// // //                     itemBuilder: (context, index) {
// // //                        final message = chatProvider.messages[index];
// // //                        final isCurrentUser =
// // //                           message.senderId == chatProvider.currentUserId;
// // //                       return ChatBubble(
// // //                         // key: ValueKey(message.id),
// // //                         message: message,
// // //                         isCurrentUser: isCurrentUser,
// // //                         senderName: isCurrentUser ? 'You' : widget.driverName,
// // //                       );
// // //                     },
// // //                   );
// // //                 },
// // //               ),
// // //             ),
// // //           ),
// // //           ChatInputField(
// // //             controller: _controller,
// // //             onSendPressed: _sendMessage,
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // // }

// // // class ChatBubble extends StatelessWidget {
// // //   final Message message;
// // //   final bool isCurrentUser;
// // //   final String senderName;

// // //   const ChatBubble({
// // //     Key? key,
// // //     required this.message,
// // //     required this.isCurrentUser,
// // //     required this.senderName,
// // //   }) : super(key: key);

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Align(
// // //       alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
// // //       child: Container(
// // //         constraints: BoxConstraints(
// // //           maxWidth: MediaQuery.of(context).size.width * 0.7,
// // //         ),
// // //         margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
// // //         padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
// // //         decoration: BoxDecoration(
// // //           color: isCurrentUser ? Colors.blue[100] : Colors.green[100],
// // //           borderRadius: BorderRadius.only(
// // //             topLeft: const Radius.circular(20),
// // //             topRight: const Radius.circular(20),
// // //             bottomLeft: isCurrentUser
// // //                 ? const Radius.circular(20)
// // //                 : const Radius.circular(0),
// // //             bottomRight: isCurrentUser
// // //                 ? const Radius.circular(0)
// // //                 : const Radius.circular(20),
// // //           ),
// // //           boxShadow: [
// // //             BoxShadow(
// // //               color: Colors.black.withOpacity(0.1),
// // //               blurRadius: 5,
// // //               spreadRadius: 1,
// // //             ),
// // //           ],
// // //         ),
// // //         child: Column(
// // //           crossAxisAlignment: CrossAxisAlignment.start,
// // //           children: [
// // //             Text(
// // //               senderName,
// // //               style: TextStyle(
// // //                 fontWeight: FontWeight.bold,
// // //                 color: Colors.grey[600],
// // //                 fontSize: 12,
// // //               ),
// // //             ),
// // //             const SizedBox(height: 4),
// // //             _buildMessageContent(context),
// // //             const SizedBox(height: 4),
// // //             Text(
// // //               _formatTime(message.createdOn),
// // //               style: TextStyle(
// // //                 color: Colors.grey[600],
// // //                 fontSize: 10,
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   Widget _buildMessageContent(BuildContext context) {
// // //     if (message.messageType == 'image' && message.images != null) {
// // //       return Column(
// // //         children: message.images!.map((imageUrl) {
// // //           return GestureDetector(
// // //             onTap: () => _showFullImage(context, imageUrl),
// // //             child: Container(
// // //               margin: const EdgeInsets.only(top: 8),
// // //               child: ClipRRect(
// // //                 borderRadius: BorderRadius.circular(10),
// // //                 child: Image.network(
// // //                   imageUrl,
// // //                   fit: BoxFit.cover,
// // //                   loadingBuilder: (context, child, loadingProgress) {
// // //                     if (loadingProgress == null) return child;
// // //                     return Container(
// // //                       height: 200,
// // //                       width: double.infinity,
// // //                       alignment: Alignment.center,
// // //                       child: CircularProgressIndicator(
// // //                         value: loadingProgress.expectedTotalBytes != null
// // //                             ? loadingProgress.cumulativeBytesLoaded /
// // //                                 loadingProgress.expectedTotalBytes!
// // //                             : null,
// // //                       ),
// // //                     );
// // //                   },
// // //                   errorBuilder: (context, error, stackTrace) {
// // //                     return Container(
// // //                       height: 200,
// // //                       width: double.infinity,
// // //                       color: Colors.grey[300],
// // //                       child: const Icon(Icons.error),
// // //                     );
// // //                   },
// // //                 ),
// // //               ),
// // //             ),
// // //           );
// // //         }).toList(),
// // //       );
// // //     }
// // //     return Text(
// // //       message.content,
// // //       style: const TextStyle(
// // //         color: Colors.black87,
// // //         fontSize: 16,
// // //       ),
// // //     );
// // //   }

// // //   void _showFullImage(BuildContext context, String imageUrl) {
// // //     Navigator.of(context).push(
// // //       MaterialPageRoute(
// // //         builder: (context) => Scaffold(
// // //           backgroundColor: Colors.black,
// // //           appBar: AppBar(
// // //             backgroundColor: Colors.black,
// // //             leading: IconButton(
// // //               icon: const Icon(Icons.arrow_back),
// // //               onPressed: () => Navigator.pop(context),
// // //             ),
// // //           ),
// // //           body: Center(
// // //             child: InteractiveViewer(
// // //               minScale: 0.5,
// // //               maxScale: 4.0,
// // //               child: Image.network(
// // //                 imageUrl,
// // //                 fit: BoxFit.contain,
// // //                 loadingBuilder: (context, child, loadingProgress) {
// // //                   if (loadingProgress == null) return child;
// // //                   return Center(
// // //                     child: CircularProgressIndicator(
// // //                       value: loadingProgress.expectedTotalBytes != null
// // //                           ? loadingProgress.cumulativeBytesLoaded /
// // //                               loadingProgress.expectedTotalBytes!
// // //                           : null,
// // //                     ),
// // //                   );
// // //                 },
// // //               ),
// // //             ),
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   String _formatTime(DateTime time) {
// // //     return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
// // //   }
// // // }

// // // class ChatInputField extends StatelessWidget {
// // //   final TextEditingController controller;
// // //   final VoidCallback onSendPressed;

// // //   const ChatInputField({
// // //     Key? key,
// // //     required this.controller,
// // //     required this.onSendPressed,
// // //   }) : super(key: key);

// // //   void _showImageOptions(BuildContext context) {
// // //     showModalBottomSheet(
// // //       context: context,
// // //       backgroundColor: Colors.black87,
// // //       builder: (context) => Container(
// // //         height: 160,
// // //         padding: const EdgeInsets.all(20),
// // //         child: Column(
// // //           children: [
// // //             ListTile(
// // //               leading: const Icon(Icons.camera_alt, color: Colors.white),
// // //               title: const Text('Take Photo',
// // //                   style: TextStyle(color: Colors.white)),
// // //               onTap: () {
// // //                 Navigator.pop(context);
// // //                 _pickImage(context, ImageSource.camera);
// // //               },
// // //             ),
// // //             ListTile(
// // //               leading: const Icon(Icons.photo_library, color: Colors.white),
// // //               title: const Text('Choose from Gallery',
// // //                   style: TextStyle(color: Colors.white)),
// // //               onTap: () {
// // //                 Navigator.pop(context);
// // //                 _pickImage(context, ImageSource.gallery);
// // //               },
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   Future<void> _pickImage(BuildContext context, ImageSource source) async {
// // //     try {
// // //       final ImagePicker picker = ImagePicker();
// // //       final XFile? image = await picker.pickImage(
// // //         source: source,
// // //         imageQuality: 70,
// // //       );

// // //       if (image != null) {
// // //         if (context.mounted) {
// // //           final chatProvider =
// // //               Provider.of<ChatProvider>(context, listen: false);
// // //           await chatProvider.sendImageMessage([File(image.path)]);
// // //         }
// // //       }
// // //     } catch (e) {
// // //       print('Error picking image: $e');
// // //       if (context.mounted) {
// // //         ScaffoldMessenger.of(context).showSnackBar(
// // //           const SnackBar(content: Text('Failed to pick image')),
// // //         );
// // //       }
// // //     }
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Container(
// // //       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
// // //       color: Colors.black,
// // //       child: Row(
// // //         children: [
// // //           IconButton(
// // //             icon: const Icon(Icons.add_photo_alternate, color: Colors.grey),
// // //             onPressed: () => _showImageOptions(context),
// // //           ),
// // //           Expanded(
// // //             child: TextField(
// // //               controller: controller,
// // //               decoration: const InputDecoration(
// // //                 hintText: 'Type your message',
// // //                 hintStyle: TextStyle(color: Colors.grey),
// // //                 border: InputBorder.none,
// // //                 contentPadding:
// // //                     EdgeInsets.symmetric(horizontal: 10, vertical: 10),
// // //               ),
// // //               style: const TextStyle(color: Colors.white),
// // //               keyboardType: TextInputType.multiline,
// // //               maxLines: null,
// // //               textCapitalization: TextCapitalization.sentences,
// // //             ),
// // //           ),
// // //           IconButton(
// // //             icon: const Icon(Icons.send, color: Colors.yellow),
// // //             onPressed: onSendPressed,
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // // }

// // // // // import 'dart:developer';
// // // // // // import 'dart:io';
// // // // // import 'package:flutter/material.dart';
// // // // // // import 'package:image_picker/image_picker.dart';
// // // // // import 'package:provider/provider.dart';
// // // // // import 'package:rideapp/models/messeage_model.dart';
// // // // // // import 'package:rideapp/utils/theme/app_colors.dart';
// // // // // import 'package:rideapp/viewmodel/provider/message_provider/chat_provider.dart';
// // // // // import 'package:rideapp/viewmodel/provider/message_provider/chatroom_provider.dart';
// // // // // import 'package:url_launcher/url_launcher.dart';

// // // // // class UserChatScreen extends StatefulWidget {
// // // // //   final String driverName;
// // // // //   final String driverImageUrl;
// // // // //   final String userId;
// // // // //   final String driverId;
// // // // //   final String phoneNumber;

// // // // //   const UserChatScreen({
// // // // //     Key? key,
// // // // //     required this.driverName,
// // // // //     required this.driverImageUrl,
// // // // //     required this.userId,
// // // // //     required this.driverId,
// // // // //     required this.phoneNumber,
// // // // //   }) : super(key: key);

// // // // //   @override
// // // // //   _UserChatScreenState createState() => _UserChatScreenState();
// // // // // }

// // // // // class _UserChatScreenState extends State<UserChatScreen> {
// // // // //   final TextEditingController _controller = TextEditingController();
// // // // //   final ScrollController _scrollController = ScrollController();
// // // // //   ChatRoomProvider? _chatRoomProvider;
// // // // //   ChatProvider? _chatProvider;

// // // // //   @override
// // // // //   void initState() {
// // // // //     super.initState();
// // // // //     _chatRoomProvider = Provider.of<ChatRoomProvider>(context, listen: false);
// // // // //     _chatProvider = Provider.of<ChatProvider>(context, listen: false);
// // // // //     _initializeChat();
// // // // //   }

// // // // //   void _initializeChat() async {
// // // // //     await _chatProvider?.initialize();
// // // // //     print('Current User ID: ${_chatProvider?.currentUserId}'); // Debug print

// // // // //     try {
// // // // //       bool success = await _chatRoomProvider?.createChatroom(
// // // // //               targetUserId: widget.driverId) ??
// // // // //           false;

// // // // //       if (success) {
// // // // //         final existingChatroomId = _chatRoomProvider?.chatroomId;
// // // // //         if (existingChatroomId != null) {
// // // // //           _chatProvider?.socket?.emit('join-room', existingChatroomId);
// // // // //           await _chatProvider?.getMessages(existingChatroomId);
// // // // //           _scrollToBottom();

// // // // //           _chatProvider?.socket?.on('receive-message', (data) {
// // // // //             if (mounted) {
// // // // //               setState(() {});
// // // // //               _scrollToBottom();
// // // // //             }
// // // // //           });
// // // // //         }
// // // // //       } else {
// // // // //         if (mounted) {
// // // // //           ScaffoldMessenger.of(context).showSnackBar(
// // // // //             const SnackBar(
// // // // //               content: Text('Failed to initialize chat'),
// // // // //               backgroundColor: Colors.red,
// // // // //             ),
// // // // //           );
// // // // //         }
// // // // //       }
// // // // //     } catch (e) {
// // // // //       print('Error initializing chat: $e');
// // // // //       if (mounted) {
// // // // //         ScaffoldMessenger.of(context).showSnackBar(
// // // // //           SnackBar(
// // // // //             content: Text('Error initializing chat: $e'),
// // // // //             backgroundColor: Colors.red,
// // // // //           ),
// // // // //         );
// // // // //       }
// // // // //     }
// // // // //   }

// // // // //   @override
// // // // //   void dispose() {
// // // // //     _chatProvider?.socket?.off('receive-message');
// // // // //     _controller.dispose();
// // // // //     _scrollController.dispose();
// // // // //     super.dispose();
// // // // //   }

// // // // //   Future<void> _makePhoneCall() async {
// // // // //     final phoneNumber = widget.phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

// // // // //     try {
// // // // //       final Uri phoneUri = Uri.parse('tel:$phoneNumber');

// // // // //       if (!context.mounted) return;

// // // // //       if (await canLaunchUrl(phoneUri)) {
// // // // //         await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
// // // // //       } else {
// // // // //         if (context.mounted) {
// // // // //           ScaffoldMessenger.of(context).showSnackBar(
// // // // //             const SnackBar(
// // // // //               content: Text('Could not launch phone dialer'),
// // // // //               backgroundColor: Colors.red,
// // // // //             ),
// // // // //           );
// // // // //         }
// // // // //       }
// // // // //     } catch (e) {
// // // // //       if (context.mounted) {
// // // // //         ScaffoldMessenger.of(context).showSnackBar(
// // // // //           SnackBar(
// // // // //             content: Text('Error: ${e.toString()}'),
// // // // //             backgroundColor: Colors.red,
// // // // //           ),
// // // // //         );
// // // // //       }
// // // // //     }
// // // // //   }

// // // // //   void _sendMessage() {
// // // // //     if (_controller.text.isNotEmpty) {
// // // // //       context.read<ChatProvider>().sendMessage(_controller.text);
// // // // //       _controller.clear();
// // // // //       _scrollToBottom();
// // // // //     }
// // // // //   }

// // // // //   void _scrollToBottom() {
// // // // //     if (_scrollController.hasClients) {
// // // // //       _scrollController.animateTo(
// // // // //         _scrollController.position.maxScrollExtent,
// // // // //         duration: const Duration(milliseconds: 300),
// // // // //         curve: Curves.easeOut,
// // // // //       );
// // // // //     }
// // // // //   }

// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     return Scaffold(
// // // // //       appBar: AppBar(
// // // // //         backgroundColor: Colors.teal,
// // // // //         title: Row(
// // // // //           children: [
// // // // //             CircleAvatar(
// // // // //               backgroundImage: NetworkImage(widget.driverImageUrl),
// // // // //             ),
// // // // //             const SizedBox(width: 10),
// // // // //             Expanded(
// // // // //               child: Column(
// // // // //                 crossAxisAlignment: CrossAxisAlignment.start,
// // // // //                 children: [
// // // // //                   Text(
// // // // //                     widget.driverName,
// // // // //                     style: const TextStyle(
// // // // //                       fontSize: 16,
// // // // //                       color: Colors.white,
// // // // //                       fontWeight: FontWeight.bold,
// // // // //                     ),
// // // // //                     overflow: TextOverflow.ellipsis,
// // // // //                   ),
// // // // //                   const Text(
// // // // //                     'Driver',
// // // // //                     style: TextStyle(fontSize: 12, color: Colors.white70),
// // // // //                   ),
// // // // //                 ],
// // // // //               ),
// // // // //             ),
// // // // //           ],
// // // // //         ),
// // // // //         actions: [
// // // // //           IconButton(
// // // // //             icon: const Icon(Icons.call, color: Colors.white),
// // // // //             onPressed: _makePhoneCall,
// // // // //           ),
// // // // //           IconButton(
// // // // //             icon: const Icon(Icons.more_vert, color: Colors.white),
// // // // //             onPressed: () {},
// // // // //           ),
// // // // //         ],
// // // // //       ),
// // // // //       body: Container(
// // // // //         color: const Color(0xFF1D1D1D),
// // // // //         child: Column(
// // // // //           children: [
// // // // //             Expanded(
// // // // //               child:
// // // // //                   Consumer<ChatProvider>(builder: (context, chatProvider, _) {
// // // // //                 if (chatProvider.isLoading) {
// // // // //                   return const Center(
// // // // //                     child: CircularProgressIndicator(
// // // // //                       color: Colors.teal,
// // // // //                     ),
// // // // //                   );
// // // // //                 }

// // // // //                 if (chatProvider.messages.isEmpty) {
// // // // //                   return const Center(
// // // // //                     child: Text(
// // // // //                       'No messages yet',
// // // // //                       style: TextStyle(color: Colors.white70),
// // // // //                     ),
// // // // //                   );
// // // // //                 }

// // // // //                 return ListView.builder(
// // // // //                   controller: _scrollController,
// // // // //                   reverse: true, // Keep this
// // // // //                   itemCount: chatProvider.messages.length,
// // // // //                   itemBuilder: (context, index) {
// // // // //                     final message = chatProvider.messages[index];
// // // // //                     final isCurrentUser =
// // // // //                         message.senderId == chatProvider.currentUserId;

// // // // //                     // Debug log
// // // // //                     log('Message ${index}: SenderId=${message.senderId}, CurrentUser=${chatProvider.currentUserId}, IsCurrentUser=$isCurrentUser');

// // // // //                     return ChatBubble(
// // // // //                       message: message,
// // // // //                       isCurrentUser: isCurrentUser,
// // // // //                       senderName: isCurrentUser ? 'You' : widget.driverName,
// // // // //                     );
// // // // //                   },
// // // // //                 );
// // // // //               }),
// // // // //             ),
// // // // //             ChatInputField(
// // // // //               controller: _controller,
// // // // //               onSendPressed: _sendMessage,
// // // // //             ),
// // // // //           ],
// // // // //         ),
// // // // //       ),
// // // // //     );
// // // // //   }
// // // // // }

// // // // // class ChatBubble extends StatelessWidget {
// // // // //   final Message message;
// // // // //   final bool isCurrentUser;
// // // // //   final String senderName;

// // // // //   const ChatBubble({
// // // // //     Key? key,
// // // // //     required this.message,
// // // // //     required this.isCurrentUser,
// // // // //     required this.senderName,
// // // // //   }) : super(key: key);

// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     return Padding(
// // // // //       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// // // // //       child: Column(
// // // // //         crossAxisAlignment:
// // // // //             isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
// // // // //         children: [
// // // // //           Text(
// // // // //             senderName,
// // // // //             style: TextStyle(
// // // // //               fontSize: 12,
// // // // //               color: Colors.grey[400],
// // // // //             ),
// // // // //           ),
// // // // //           const SizedBox(height: 2),
// // // // //           Container(
// // // // //             constraints: BoxConstraints(
// // // // //               maxWidth: MediaQuery.of(context).size.width * 0.75,
// // // // //             ),
// // // // //             decoration: BoxDecoration(
// // // // //               color: isCurrentUser ? Colors.teal : Colors.grey[800],
// // // // //               borderRadius: BorderRadius.only(
// // // // //                 topLeft: const Radius.circular(16),
// // // // //                 topRight: const Radius.circular(16),
// // // // //                 bottomLeft: isCurrentUser
// // // // //                     ? const Radius.circular(16)
// // // // //                     : const Radius.circular(4),
// // // // //                 bottomRight: isCurrentUser
// // // // //                     ? const Radius.circular(4)
// // // // //                     : const Radius.circular(16),
// // // // //               ),
// // // // //               boxShadow: [
// // // // //                 BoxShadow(
// // // // //                   color: Colors.black.withOpacity(0.1),
// // // // //                   blurRadius: 3,
// // // // //                   offset: const Offset(0, 2),
// // // // //                 ),
// // // // //               ],
// // // // //             ),
// // // // //             padding: const EdgeInsets.all(12),
// // // // //             child: Column(
// // // // //               crossAxisAlignment: CrossAxisAlignment.start,
// // // // //               children: [
// // // // //                 _buildMessageContent(context),
// // // // //                 const SizedBox(height: 4),
// // // // //                 Row(
// // // // //                   mainAxisSize: MainAxisSize.min,
// // // // //                   children: [
// // // // //                     Text(
// // // // //                       _formatTime(message.createdOn),
// // // // //                       style: TextStyle(
// // // // //                         fontSize: 10,
// // // // //                         color:
// // // // //                             isCurrentUser ? Colors.white70 : Colors.grey[400],
// // // // //                       ),
// // // // //                     ),
// // // // //                     if (isCurrentUser) ...[
// // // // //                       const SizedBox(width: 4),
// // // // //                       Icon(
// // // // //                         Icons.done_all,
// // // // //                         size: 12,
// // // // //                         color: Colors.white70,
// // // // //                       ),
// // // // //                     ],
// // // // //                   ],
// // // // //                 ),
// // // // //               ],
// // // // //             ),
// // // // //           ),
// // // // //         ],
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   Widget _buildMessageContent(BuildContext context) {
// // // // //     if (message.messageType == 'image' && message.images != null) {
// // // // //       return Column(
// // // // //         crossAxisAlignment: CrossAxisAlignment.start,
// // // // //         children: message.images!.map((imageUrl) {
// // // // //           return GestureDetector(
// // // // //             onTap: () => _showFullImage(context, imageUrl),
// // // // //             child: Container(
// // // // //               margin: const EdgeInsets.only(bottom: 8),
// // // // //               child: ClipRRect(
// // // // //                 borderRadius: BorderRadius.circular(8),
// // // // //                 child: Image.network(
// // // // //                   imageUrl,
// // // // //                   fit: BoxFit.cover,
// // // // //                   loadingBuilder: (context, child, loadingProgress) {
// // // // //                     if (loadingProgress == null) return child;
// // // // //                     return Container(
// // // // //                       height: 200,
// // // // //                       width: double.infinity,
// // // // //                       alignment: Alignment.center,
// // // // //                       child: CircularProgressIndicator(
// // // // //                         value: loadingProgress.expectedTotalBytes != null
// // // // //                             ? loadingProgress.cumulativeBytesLoaded /
// // // // //                                 loadingProgress.expectedTotalBytes!
// // // // //                             : null,
// // // // //                         color: Colors.teal,
// // // // //                       ),
// // // // //                     );
// // // // //                   },
// // // // //                   errorBuilder: (context, error, stackTrace) {
// // // // //                     return Container(
// // // // //                       height: 200,
// // // // //                       width: double.infinity,
// // // // //                       color: Colors.grey[800],
// // // // //                       child: const Icon(
// // // // //                         Icons.error_outline,
// // // // //                         color: Colors.white70,
// // // // //                       ),
// // // // //                     );
// // // // //                   },
// // // // //                 ),
// // // // //               ),
// // // // //             ),
// // // // //           );
// // // // //         }).toList(),
// // // // //       );
// // // // //     }
// // // // //     return Text(
// // // // //       message.content,
// // // // //       style: const TextStyle(
// // // // //         color: Colors.white,
// // // // //         fontSize: 16,
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   String _formatTime(DateTime time) {
// // // // //     return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
// // // // //   }
// // // // // }

// // // // // void _showFullImage(BuildContext context, String imageUrl) {
// // // // //   Navigator.of(context).push(
// // // // //     MaterialPageRoute(
// // // // //       builder: (context) => Scaffold(
// // // // //         backgroundColor: Colors.black,
// // // // //         appBar: AppBar(
// // // // //           backgroundColor: Colors.black,
// // // // //           iconTheme: const IconThemeData(color: Colors.white),
// // // // //         ),
// // // // //         body: Center(
// // // // //           child: InteractiveViewer(
// // // // //             minScale: 0.5,
// // // // //             maxScale: 4.0,
// // // // //             child: Image.network(
// // // // //               imageUrl,
// // // // //               fit: BoxFit.contain,
// // // // //               loadingBuilder: (context, child, loadingProgress) {
// // // // //                 if (loadingProgress == null) return child;
// // // // //                 return CircularProgressIndicator(
// // // // //                   value: loadingProgress.expectedTotalBytes != null
// // // // //                       ? loadingProgress.cumulativeBytesLoaded /
// // // // //                           loadingProgress.expectedTotalBytes!
// // // // //                       : null,
// // // // //                   color: Colors.teal,
// // // // //                 );
// // // // //               },
// // // // //             ),
// // // // //           ),
// // // // //         ),
// // // // //       ),
// // // // //     ),
// // // // //   );
// // // // // }

// // // // // class ChatInputField extends StatelessWidget {
// // // // //   final TextEditingController controller;
// // // // //   final VoidCallback onSendPressed;

// // // // //   const ChatInputField({
// // // // //     Key? key,
// // // // //     required this.controller,
// // // // //     required this.onSendPressed,
// // // // //   }) : super(key: key);

// // // // //   // void _showImageOptions(BuildContext context) {
// // // // //   //   showModalBottomSheet(
// // // // //   //     context: context,
// // // // //   //     backgroundColor: const Color(0xFF1D1D1D),
// // // // //   //     shape: const RoundedRectangleBorder(
// // // // //   //       borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
// // // // //   //     ),
// // // // //   //     builder: (context) => Container(
// // // // //   //       padding: const EdgeInsets.all(20),
// // // // //   //       child: Column(
// // // // //   //         mainAxisSize: MainAxisSize.min,
// // // // //   //         children: [
// // // // //   //           ListTile(
// // // // //   //             leading: const Icon(Icons.camera_alt, color: Colors.teal),
// // // // //   //             title: const Text(
// // // // //   //               'Take Photo',
// // // // //   //               style: TextStyle(color: Colors.white),
// // // // //   //             ),
// // // // //   //             onTap: () {
// // // // //   //               Navigator.pop(context);
// // // // //   //               _pickImage(context, ImageSource.camera);
// // // // //   //             },
// // // // //   //           ),
// // // // //   //           ListTile(
// // // // //   //             leading: const Icon(Icons.photo_library, color: Colors.teal),
// // // // //   //             title: const Text(
// // // // //   //               'Choose from Gallery',
// // // // //   //               style: TextStyle(color: Colors.white),
// // // // //   //             ),
// // // // //   //             onTap: () {
// // // // //   //               Navigator.pop(context);
// // // // //   //               _pickImage(context, ImageSource.gallery);
// // // // //   //             },
// // // // //   //           ),
// // // // //   //         ],
// // // // //   //       ),
// // // // //   //     ),
// // // // //   //   );
// // // // //   // }

// // // // //   // Future<void> _pickImage(BuildContext context, ImageSource source) async {
// // // // //   //   try {
// // // // //   //     final ImagePicker picker = ImagePicker();
// // // // //   //     final XFile? image = await picker.pickImage(
// // // // //   //       source: source,
// // // // //   //       imageQuality: 70,
// // // // //   //     );

// // // // //   //     if (image != null && context.mounted) {
// // // // //   //       final chatProvider = Provider.of<ChatProvider>(context, listen: false);
// // // // //   //       await chatProvider.sendImageMessage([File(image.path)]);
// // // // //   //     }
// // // // //   //   } catch (e) {
// // // // //   //     print('Error picking image: $e');
// // // // //   //     if (context.mounted) {
// // // // //   //       ScaffoldMessenger.of(context).showSnackBar(
// // // // //   //         const SnackBar(
// // // // //   //           content: Text('Failed to pick image'),
// // // // //   //           backgroundColor: Colors.red,
// // // // //   //         ),
// // // // //   //       );
// // // // //   //     }
// // // // //   //   }
// // // // //   // }

// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     return Container(
// // // // //       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
// // // // //       color: const Color(0xFF1D1D1D),
// // // // //       child: Row(
// // // // //         children: [
// // // // //           IconButton(
// // // // //             icon: const Icon(
// // // // //               Icons.add_photo_alternate,
// // // // //               color: Colors.teal,
// // // // //               size: 24,
// // // // //             ),
// // // // //             onPressed: ()
// // // // //           {}),
// // // // //           Expanded(
// // // // //             child: Container(
// // // // //               decoration: BoxDecoration(
// // // // //                 color: Colors.grey[900],
// // // // //                 borderRadius: BorderRadius.circular(24),
// // // // //               ),
// // // // //               child: TextField(
// // // // //                 controller: controller,
// // // // //                 decoration: const InputDecoration(
// // // // //                   hintText: 'Type your message...',
// // // // //                   hintStyle: TextStyle(color: Colors.grey),
// // // // //                   border: InputBorder.none,
// // // // //                   contentPadding: EdgeInsets.symmetric(
// // // // //                     horizontal: 16,
// // // // //                     vertical: 10,
// // // // //                   ),
// // // // //                 ),
// // // // //                 style: const TextStyle(
// // // // //                   color: Colors.white,
// // // // //                   fontSize: 16,
// // // // //                 ),
// // // // //                 keyboardType: TextInputType.multiline,
// // // // //                 maxLines: null,
// // // // //                 textCapitalization: TextCapitalization.sentences,
// // // // //                 onSubmitted: (_) => onSendPressed(),
// // // // //               ),
// // // // //             ),
// // // // //           ),
// // // // //           IconButton(
// // // // //             icon: const Icon(
// // // // //               Icons.send,
// // // // //               color: Colors.teal,
// // // // //               size: 24,
// // // // //             ),
// // // // //             onPressed: onSendPressed,
// // // // //           ),
// // // // //         ],
// // // // //       ),
// // // // //     );
// // // // //   }
// // // // // }

// // // // import 'dart:developer';
// // // // import 'package:flutter/material.dart';
// // // // import 'package:provider/provider.dart';
// // // // import 'package:rideapp/viewmodel/provider/message_provider/chat_provider.dart';
// // // // import 'package:url_launcher/url_launcher.dart';

// // // // class UserChatScreen extends StatefulWidget {
// // // //   final String driverName;
// // // //   final String driverImageUrl;
// // // //   final String userId;
// // // //   final String driverId;
// // // //   final String phoneNumber;

// // // //   const UserChatScreen({
// // // //     Key? key,
// // // //     required this.driverName,
// // // //     required this.driverImageUrl,
// // // //     required this.userId,
// // // //     required this.driverId,
// // // //     required this.phoneNumber,
// // // //   }) : super(key: key);

// // // //   @override
// // // //   _UserChatScreenState createState() => _UserChatScreenState();
// // // // }

// // // // class _UserChatScreenState extends State<UserChatScreen> {
// // // //   final TextEditingController _controller = TextEditingController();
// // // //   final ScrollController _scrollController = ScrollController();
// // // //   bool _isInitialized = false;

// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //     WidgetsBinding.instance.addPostFrameCallback((_) {
// // // //       _initializeChat();
// // // //     });
// // // //   }

// // // //   void _initializeChat() async {
// // // //     if (_isInitialized) return;

// // // //     final messageProvider = Provider.of<ChatMessageProvider>(context, listen: false);
// // // //     setState(() => _isInitialized = true);

// // // //     try {
// // // //       // Get messages for this chatroom
// // // //       await messageProvider.getMessages(widget.driverId);
// // // //       _scrollToBottom();

// // // //     } catch (e) {
// // // //       log('Error initializing chat: $e');
// // // //       if (mounted) {
// // // //         ScaffoldMessenger.of(context).showSnackBar(
// // // //           const SnackBar(
// // // //             content: Text('Failed to initialize chat'),
// // // //             backgroundColor: Colors.red,
// // // //           ),
// // // //         );
// // // //       }
// // // //     }
// // // //   }

// // // //   @override
// // // //   void dispose() {
// // // //     _controller.dispose();
// // // //     _scrollController.dispose();
// // // //     super.dispose();
// // // //   }

// // // //   void _sendMessage() async {
// // // //     if (_controller.text.isEmpty) return;

// // // //     final messageProvider = Provider.of<ChatMessageProvider>(context, listen: false);

// // // //     final success = await messageProvider.sendMessage(
// // // //       chatroomId: widget.driverId,
// // // //       message: _controller.text,
// // // //     );

// // // //     if (success) {
// // // //       _controller.clear();
// // // //       _scrollToBottom();
// // // //     } else {
// // // //       if (mounted) {
// // // //         ScaffoldMessenger.of(context).showSnackBar(
// // // //           const SnackBar(content: Text('Failed to send message')),
// // // //         );
// // // //       }
// // // //     }
// // // //   }

// // // //   void _scrollToBottom() {
// // // //     if (_scrollController.hasClients) {
// // // //       _scrollController.animateTo(
// // // //         _scrollController.position.maxScrollExtent,
// // // //         duration: const Duration(milliseconds: 300),
// // // //         curve: Curves.easeOut,
// // // //       );
// // // //     }
// // // //   }

// // // //   Future<void> _makePhoneCall() async {
// // // //     final phoneNumber = widget.phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
// // // //     try {
// // // //       final phoneUri = Uri.parse('tel:$phoneNumber');
// // // //       if (!await launchUrl(phoneUri, mode: LaunchMode.externalApplication)) {
// // // //         if (mounted) {
// // // //           ScaffoldMessenger.of(context).showSnackBar(
// // // //             const SnackBar(
// // // //               content: Text('Could not launch phone dialer'),
// // // //               backgroundColor: Colors.red,
// // // //             ),
// // // //           );
// // // //         }
// // // //       }
// // // //     } catch (e) {
// // // //       if (mounted) {
// // // //         ScaffoldMessenger.of(context).showSnackBar(
// // // //           SnackBar(
// // // //             content: Text('Error: ${e.toString()}'),
// // // //             backgroundColor: Colors.red,
// // // //           ),
// // // //         );
// // // //       }
// // // //     }
// // // //   }

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Scaffold(
// // // //       appBar: AppBar(
// // // //         backgroundColor: Colors.teal,
// // // //         title: Row(
// // // //           children: [
// // // //             CircleAvatar(
// // // //               backgroundImage: NetworkImage(widget.driverImageUrl),
// // // //             ),
// // // //             const SizedBox(width: 10),
// // // //             Expanded(
// // // //               child: Column(
// // // //                 crossAxisAlignment: CrossAxisAlignment.start,
// // // //                 children: [
// // // //                   Text(
// // // //                     widget.driverName,
// // // //                     style: const TextStyle(
// // // //                       fontSize: 16,
// // // //                       color: Colors.white,
// // // //                       fontWeight: FontWeight.bold,
// // // //                     ),
// // // //                     overflow: TextOverflow.ellipsis,
// // // //                   ),
// // // //                   const Text(
// // // //                     'Driver',
// // // //                     style: TextStyle(fontSize: 12, color: Colors.white70),
// // // //                   ),
// // // //                 ],
// // // //               ),
// // // //             ),
// // // //           ],
// // // //         ),
// // // //         actions: [
// // // //           IconButton(
// // // //             icon: const Icon(Icons.call, color: Colors.white),
// // // //             onPressed: _makePhoneCall,
// // // //           ),
// // // //           IconButton(
// // // //             icon: const Icon(Icons.more_vert, color: Colors.white),
// // // //             onPressed: () {},
// // // //           ),
// // // //         ],
// // // //       ),
// // // //       body: Container(
// // // //         color: const Color(0xFF1D1D1D),
// // // //         child: Column(
// // // //           children: [
// // // //             Expanded(
// // // //               child: Consumer<ChatMessageProvider>(
// // // //                 builder: (context, messageProvider, _) {
// // // //                   if (messageProvider.isLoading) {
// // // //                     return const Center(
// // // //                       child: CircularProgressIndicator(color: Colors.teal),
// // // //                     );
// // // //                   }

// // // //                   if (messageProvider.messages.isEmpty) {
// // // //                     return const Center(
// // // //                       child: Text(
// // // //                         'No messages yet',
// // // //                         style: TextStyle(color: Colors.white70),
// // // //                       ),
// // // //                     );
// // // //                   }

// // // //                   return ListView.builder(
// // // //                     controller: _scrollController,
// // // //                     reverse: true,
// // // //                     itemCount: messageProvider.messages.length,
// // // //                     itemBuilder: (context, index) {
// // // //                       final message = messageProvider.messages[index];
// // // //                       return ChatBubble(
// // // //                         message: message,
// // // //                         isCurrentUser: message['senderId'] == widget.userId,
// // // //                         senderName: message['senderId'] == widget.userId
// // // //                           ? 'You'
// // // //                           : widget.driverName,
// // // //                       );
// // // //                     },
// // // //                   );
// // // //                 },
// // // //               ),
// // // //             ),
// // // //             ChatInputField(
// // // //               controller: _controller,
// // // //               onSendPressed: _sendMessage,
// // // //             ),
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // // }

// // // // class ChatBubble extends StatelessWidget {
// // // //   final Map<String, dynamic> message;
// // // //   final bool isCurrentUser;
// // // //   final String senderName;

// // // //   const ChatBubble({
// // // //     Key? key,
// // // //     required this.message,
// // // //     required this.isCurrentUser,
// // // //     required this.senderName,
// // // //   }) : super(key: key);

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     // Safely get message content with fallback
// // // //     final String messageContent = message['content']?.toString() ?? 'Message unavailable';

// // // //     // Safely parse timestamp with fallback
// // // //     DateTime? messageTime;
// // // //     try {
// // // //       messageTime = message['createdOn'] != null
// // // //         ? DateTime.parse(message['createdOn'].toString())
// // // //         : DateTime.now();
// // // //     } catch (e) {
// // // //       log('Error parsing message time: $e');
// // // //       messageTime = DateTime.now();
// // // //     }

// // // //     return Padding(
// // // //       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// // // //       child: Column(
// // // //         crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
// // // //         children: [
// // // //           Text(
// // // //             senderName,
// // // //             style: TextStyle(
// // // //               fontSize: 12,
// // // //               color: Colors.grey[400],
// // // //             ),
// // // //           ),
// // // //           const SizedBox(height: 2),
// // // //           Container(
// // // //             constraints: BoxConstraints(
// // // //               maxWidth: MediaQuery.of(context).size.width * 0.75,
// // // //             ),
// // // //             decoration: BoxDecoration(
// // // //               color: isCurrentUser ? Colors.yellow[700] : Colors.grey[800],
// // // //               borderRadius: BorderRadius.only(
// // // //                 topLeft: const Radius.circular(16),
// // // //                 topRight: const Radius.circular(16),
// // // //                 bottomLeft: !isCurrentUser
// // // //                     ? const Radius.circular(4)
// // // //                     : const Radius.circular(16),
// // // //                 bottomRight: isCurrentUser
// // // //                     ? const Radius.circular(4)
// // // //                     : const Radius.circular(16),
// // // //               ),
// // // //               boxShadow: [
// // // //                 BoxShadow(
// // // //                   color: Colors.black.withOpacity(0.1),
// // // //                   blurRadius: 3,
// // // //                   offset: const Offset(0, 2),
// // // //                 ),
// // // //               ],
// // // //             ),
// // // //             padding: const EdgeInsets.all(12),
// // // //             child: Column(
// // // //               crossAxisAlignment: isCurrentUser
// // // //                   ? CrossAxisAlignment.end
// // // //                   : CrossAxisAlignment.start,
// // // //               children: [
// // // //                 messageContent.isNotEmpty
// // // //                     ? Text(
// // // //                         messageContent,
// // // //                         style: TextStyle(
// // // //                           color: isCurrentUser ? Colors.black87 : Colors.white,
// // // //                           fontSize: 16,
// // // //                         ),
// // // //                       )
// // // //                     : const Text(
// // // //                         'Message unavailable',
// // // //                         style: TextStyle(
// // // //                           color: Colors.grey,
// // // //                           fontSize: 14,
// // // //                           fontStyle: FontStyle.italic,
// // // //                         ),
// // // //                       ),
// // // //                 const SizedBox(height: 4),
// // // //                 Row(
// // // //                   mainAxisSize: MainAxisSize.min,
// // // //                   children: [
// // // //                     Text(
// // // //                       _formatTime(messageTime),
// // // //                       style: TextStyle(
// // // //                         fontSize: 10,
// // // //                         color: isCurrentUser ? Colors.black87 : Colors.grey[400],
// // // //                       ),
// // // //                     ),
// // // //                     if (isCurrentUser) ...[
// // // //                       const SizedBox(width: 4),
// // // //                       const Icon(
// // // //                         Icons.done_all,
// // // //                         size: 12,
// // // //                         color: Colors.black87,
// // // //                       ),
// // // //                     ],
// // // //                   ],
// // // //                 ),
// // // //               ],
// // // //             ),
// // // //           ),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }

// // // //   String _formatTime(DateTime time) {
// // // //     return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
// // // //   }
// // // // }

// // // // class ChatInputField extends StatelessWidget {
// // // //   final TextEditingController controller;
// // // //   final VoidCallback onSendPressed;

// // // //   const ChatInputField({
// // // //     Key? key,
// // // //     required this.controller,
// // // //     required this.onSendPressed,
// // // //   }) : super(key: key);

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Container(
// // // //       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
// // // //       color: const Color(0xFF1D1D1D),
// // // //       child: Row(
// // // //         children: [
// // // //           Expanded(
// // // //             child: Container(
// // // //               decoration: BoxDecoration(
// // // //                 color: Colors.grey[900],
// // // //                 borderRadius: BorderRadius.circular(24),
// // // //               ),
// // // //               child: TextField(
// // // //                 controller: controller,
// // // //                 decoration: const InputDecoration(
// // // //                   hintText: 'Type your message...',
// // // //                   hintStyle: TextStyle(color: Colors.grey),
// // // //                   border: InputBorder.none,
// // // //                   contentPadding: EdgeInsets.symmetric(
// // // //                     horizontal: 16,
// // // //                     vertical: 10,
// // // //                   ),
// // // //                 ),
// // // //                 style: const TextStyle(
// // // //                   color: Colors.white,
// // // //                   fontSize: 16,
// // // //                 ),
// // // //                 keyboardType: TextInputType.multiline,
// // // //                 maxLines: null,
// // // //                 textCapitalization: TextCapitalization.sentences,
// // // //                 onSubmitted: (_) => onSendPressed(),
// // // //               ),
// // // //             ),
// // // //           ),
// // // //           IconButton(
// // // //             icon: const Icon(
// // // //               Icons.send,
// // // //               color: Colors.teal,
// // // //               size: 24,
// // // //             ),
// // // //             onPressed: onSendPressed,
// // // //           ),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }
// // // // }

// // // // import 'dart:developer';
// // // // import 'package:flutter/material.dart';
// // // // import 'package:provider/provider.dart';
// // // // import 'package:rideapp/models/messeage_model.dart';
// // // // import 'package:rideapp/viewmodel/provider/message_provider/chat_provider.dart';
// // // // import 'package:url_launcher/url_launcher.dart';

// // // // class UserChatScreen extends StatefulWidget {
// // // //   final String driverName;
// // // //   final String driverImageUrl;
// // // //   final String userId;
// // // //   final String driverId;
// // // //   final String phoneNumber;

// // // //   const UserChatScreen({
// // // //     Key? key,
// // // //     required this.driverName,
// // // //     required this.driverImageUrl,
// // // //     required this.userId,
// // // //     required this.driverId,
// // // //     required this.phoneNumber,
// // // //   }) : super(key: key);

// // // //   @override
// // // //   State<UserChatScreen> createState() => _UserChatScreenState();
// // // // }

// // // // class _UserChatScreenState extends State<UserChatScreen> {
// // // //   final TextEditingController _controller = TextEditingController();
// // // //   final ScrollController _scrollController = ScrollController();
// // // //   bool _isInitialized = false;

// // // //   bool isCurrentUser(Message message) {
// // // //     return message.senderId == widget.userId;
// // // //   }

// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //     WidgetsBinding.instance.addPostFrameCallback((_) {
// // // //       _initializeChat();
// // // //     });
// // // //   }

// // // //   void _initializeChat() async {
// // // //     if (_isInitialized) return;

// // // //     final messageProvider = Provider.of<ChatMessageProvider>(context, listen: false);
// // // //     setState(() => _isInitialized = true);

// // // //     try {
// // // //       await messageProvider.getMessages(widget.driverId);
// // // //       _scrollToBottom();
// // // //     } catch (e) {
// // // //       log('Error initializing chat: $e');
// // // //       if (mounted) {
// // // //         _showErrorSnackbar('Failed to load messages');
// // // //       }
// // // //     }
// // // //   }

// // // //   void _showErrorSnackbar(String message) {
// // // //     ScaffoldMessenger.of(context).showSnackBar(
// // // //       SnackBar(
// // // //         content: Text(message),
// // // //         backgroundColor: Colors.red,
// // // //         behavior: SnackBarBehavior.floating,
// // // //       ),
// // // //     );
// // // //   }

// // // //   @override
// // // //   void dispose() {
// // // //     _controller.dispose();
// // // //     _scrollController.dispose();
// // // //     super.dispose();
// // // //   }

// // // //   void _sendMessage() async {
// // // //     final message = _controller.text.trim();
// // // //     if (message.isEmpty) return;

// // // //     final messageProvider = Provider.of<ChatMessageProvider>(context, listen: false);

// // // //     final success = await messageProvider.sendMessage(
// // // //       chatroomId: widget.driverId,
// // // //       message: message,
// // // //     );

// // // //     if (success) {
// // // //       _controller.clear();
// // // //       _scrollToBottom();
// // // //     } else if (mounted) {
// // // //       _showErrorSnackbar('Failed to send message');
// // // //     }
// // // //   }

// // // //   void _scrollToBottom() {
// // // //     if (_scrollController.hasClients) {
// // // //       _scrollController.animateTo(
// // // //         0,
// // // //         duration: const Duration(milliseconds: 300),
// // // //         curve: Curves.easeOut,
// // // //       );
// // // //     }
// // // //   }

// // // //   Future<void> _makePhoneCall() async {
// // // //     try {
// // // //       final phoneNumber = widget.phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
// // // //       final phoneUri = Uri.parse('tel:$phoneNumber');

// // // //       if (!await launchUrl(phoneUri, mode: LaunchMode.externalApplication)) {
// // // //         if (mounted) {
// // // //           _showErrorSnackbar('Could not launch phone dialer');
// // // //         }
// // // //       }
// // // //     } catch (e) {
// // // //       log('Phone call error: $e');
// // // //       if (mounted) {
// // // //         _showErrorSnackbar('Failed to make phone call');
// // // //       }
// // // //     }
// // // //   }

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Scaffold(
// // // //       backgroundColor: const Color(0xFF1D1D1D),
// // // //       appBar: AppBar(
// // // //         backgroundColor: Colors.teal,
// // // //         leading: IconButton(
// // // //           icon: const Icon(Icons.arrow_back, color: Colors.white),
// // // //           onPressed: () => Navigator.pop(context),
// // // //         ),
// // // //         title: Row(
// // // //           children: [
// // // //             CircleAvatar(
// // // //               backgroundImage: NetworkImage(widget.driverImageUrl),
// // // //               backgroundColor: Colors.grey[800],
// // // //               onBackgroundImageError: (e, _) {
// // // //                 log('Error loading driver image: $e');
// // // //               },
// // // //             ),
// // // //             const SizedBox(width: 10),
// // // //             Expanded(
// // // //               child: Column(
// // // //                 crossAxisAlignment: CrossAxisAlignment.start,
// // // //                 mainAxisSize: MainAxisSize.min,
// // // //                 children: [
// // // //                   Text(
// // // //                     widget.driverName,
// // // //                     style: const TextStyle(
// // // //                       fontSize: 16,
// // // //                       color: Colors.white,
// // // //                       fontWeight: FontWeight.bold,
// // // //                     ),
// // // //                     overflow: TextOverflow.ellipsis,
// // // //                   ),
// // // //                   const Text(
// // // //                     'Driver',
// // // //                     style: TextStyle(fontSize: 12, color: Colors.white70),
// // // //                   ),
// // // //                 ],
// // // //               ),
// // // //             ),
// // // //           ],
// // // //         ),
// // // //         actions: [
// // // //           IconButton(
// // // //             icon: const Icon(Icons.call, color: Colors.white),
// // // //             onPressed: _makePhoneCall,
// // // //             tooltip: 'Call Driver',
// // // //           ),
// // // //           IconButton(
// // // //             icon: const Icon(Icons.more_vert, color: Colors.white),
// // // //             onPressed: () {},
// // // //             tooltip: 'More Options',
// // // //           ),
// // // //         ],
// // // //       ),
// // // //       body: SafeArea(
// // // //         child: Column(
// // // //           children: [
// // // //             Expanded(
// // // //               child: Consumer<ChatMessageProvider>(
// // // //                 builder: (context, messageProvider, _) {
// // // //                   if (messageProvider.isLoading) {
// // // //                     return const Center(
// // // //                       child: CircularProgressIndicator(color: Colors.teal),
// // // //                     );
// // // //                   }

// // // //                   if (messageProvider.messages.isEmpty) {
// // // //                     return const Center(
// // // //                       child: Text(
// // // //                         'No messages yet\nStart chatting with your driver',
// // // //                         textAlign: TextAlign.center,
// // // //                         style: TextStyle(
// // // //                           color: Colors.white70,
// // // //                           fontSize: 16,
// // // //                         ),
// // // //                       ),
// // // //                     );
// // // //                   }

// // // //                   return ListView.builder(
// // // //                     controller: _scrollController,
// // // //                     reverse: true,
// // // //                     padding: const EdgeInsets.all(12),
// // // //                     itemCount: messageProvider.messages.length,
// // // //                     itemBuilder: (context, index) {
// // // //                       final message = messageProvider.messages[index];
// // // //                       return ChatBubble(
// // // //                         message: message,
// // // //                         isCurrentUser: isCurrentUser(message),
// // // //                         senderName: isCurrentUser(message) ? 'You' : widget.driverName,
// // // //                       );
// // // //                     },
// // // //                   );
// // // //                 },
// // // //               ),
// // // //             ),
// // // //             ChatInputField(
// // // //               controller: _controller,
// // // //               onSendPressed: _sendMessage,
// // // //             ),
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // // }

// // // // class ChatBubble extends StatelessWidget {
// // // //   final Message message;
// // // //   final bool isCurrentUser;
// // // //   final String senderName;

// // // //   const ChatBubble({
// // // //     Key? key,
// // // //     required this.message,
// // // //     required this.isCurrentUser,
// // // //     required this.senderName,
// // // //   }) : super(key: key);

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Padding(
// // // //       padding: const EdgeInsets.symmetric(vertical: 4),
// // // //       child: Column(
// // // //         crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
// // // //         children: [
// // // //           Text(
// // // //             senderName,
// // // //             style: TextStyle(
// // // //               fontSize: 12,
// // // //               color: Colors.grey[400],
// // // //             ),
// // // //           ),
// // // //           const SizedBox(height: 2),
// // // //           Container(
// // // //             constraints: BoxConstraints(
// // // //               maxWidth: MediaQuery.of(context).size.width * 0.75,
// // // //             ),
// // // //             decoration: BoxDecoration(
// // // //               color: isCurrentUser ? Colors.yellow[700] : Colors.grey[800],
// // // //               borderRadius: BorderRadius.only(
// // // //                 topLeft: const Radius.circular(16),
// // // //                 topRight: const Radius.circular(16),
// // // //                 bottomLeft: !isCurrentUser
// // // //                     ? const Radius.circular(4)
// // // //                     : const Radius.circular(16),
// // // //                 bottomRight: isCurrentUser
// // // //                     ? const Radius.circular(4)
// // // //                     : const Radius.circular(16),
// // // //               ),
// // // //               boxShadow: [
// // // //                 BoxShadow(
// // // //                   color: Colors.black.withOpacity(0.1),
// // // //                   blurRadius: 3,
// // // //                   offset: const Offset(0, 2),
// // // //                 ),
// // // //               ],
// // // //             ),
// // // //             padding: const EdgeInsets.all(12),
// // // //             child: Column(
// // // //               crossAxisAlignment: isCurrentUser
// // // //                   ? CrossAxisAlignment.end
// // // //                   : CrossAxisAlignment.start,
// // // //               children: [
// // // //                 Text(
// // // //                   message.content,
// // // //                   style: TextStyle(
// // // //                     color: isCurrentUser ? Colors.black87 : Colors.white,
// // // //                     fontSize: 16,
// // // //                   ),
// // // //                 ),
// // // //                 const SizedBox(height: 4),
// // // //                 Row(
// // // //                   mainAxisSize: MainAxisSize.min,
// // // //                   children: [
// // // //                     Text(
// // // //                       _formatTime(message.createdOn),
// // // //                       style: TextStyle(
// // // //                         fontSize: 10,
// // // //                         color: isCurrentUser ? Colors.black87 : Colors.grey[400],
// // // //                       ),
// // // //                     ),
// // // //                     if (isCurrentUser) ...[
// // // //                       const SizedBox(width: 4),
// // // //                       Icon(
// // // //                         Icons.done_all,
// // // //                         size: 12,
// // // //                         color: isCurrentUser ? Colors.black87 : Colors.white70,
// // // //                       ),
// // // //                     ],
// // // //                   ],
// // // //                 ),
// // // //               ],
// // // //             ),
// // // //           ),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }

// // // //   String _formatTime(DateTime time) {
// // // //     final hour = time.hour.toString().padLeft(2, '0');
// // // //     final minute = time.minute.toString().padLeft(2, '0');
// // // //     return "$hour:$minute";
// // // //   }
// // // // }

// // // // class ChatInputField extends StatelessWidget {
// // // //   final TextEditingController controller;
// // // //   final VoidCallback onSendPressed;

// // // //   const ChatInputField({
// // // //     Key? key,
// // // //     required this.controller,
// // // //     required this.onSendPressed,
// // // //   }) : super(key: key);

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Container(
// // // //       padding: const EdgeInsets.all(8),
// // // //       decoration: BoxDecoration(
// // // //         color: const Color(0xFF1D1D1D),
// // // //         boxShadow: [
// // // //           BoxShadow(
// // // //             color: Colors.black.withOpacity(0.1),
// // // //             blurRadius: 8,
// // // //             offset: const Offset(0, -2),
// // // //           ),
// // // //         ],
// // // //       ),
// // // //       child: Row(
// // // //         children: [
// // // //           Expanded(
// // // //             child: Container(
// // // //               decoration: BoxDecoration(
// // // //                 color: Colors.grey[900],
// // // //                 borderRadius: BorderRadius.circular(24),
// // // //               ),
// // // //               child: TextField(
// // // //                 controller: controller,
// // // //                 decoration: const InputDecoration(
// // // //                   hintText: 'Message your driver...',
// // // //                   hintStyle: TextStyle(color: Colors.grey),
// // // //                   border: InputBorder.none,
// // // //                   contentPadding: EdgeInsets.symmetric(
// // // //                     horizontal: 16,
// // // //                     vertical: 10,
// // // //                   ),
// // // //                 ),
// // // //                 style: const TextStyle(
// // // //                   color: Colors.white,
// // // //                   fontSize: 16,
// // // //                 ),
// // // //                 keyboardType: TextInputType.multiline,
// // // //                 maxLines: null,
// // // //                 textCapitalization: TextCapitalization.sentences,
// // // //                 onSubmitted: (_) => onSendPressed(),
// // // //               ),
// // // //             ),
// // // //           ),
// // // //           const SizedBox(width: 8),
// // // //           Container(
// // // //             decoration: const BoxDecoration(
// // // //               color: Colors.teal,
// // // //               shape: BoxShape.circle,
// // // //             ),
// // // //             child: IconButton(
// // // //               icon: const Icon(
// // // //                 Icons.send,
// // // //                 color: Colors.white,
// // // //                 size: 20,
// // // //               ),
// // // //               onPressed: onSendPressed,
// // // //               tooltip: 'Send Message',
// // // //             ),
// // // //           ),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }
// // // // }

// // import 'package:flutter/material.dart';
// // import 'package:provider/provider.dart';
// // import 'package:rideapp/utils/theme/app_text_theme.dart';
// // import 'package:rideapp/viewmodel/provider/message_provider/chat_provider.dart';
// // import 'package:shared_preferences/shared_preferences.dart';

// // class UserChatScreen extends StatefulWidget {
// //   final String driverName;
// //   final String driverImageUrl;
// //   final String userId;
// //   final String driverId;
// //   final String phoneNumber;

// //   const UserChatScreen({
// //     Key? key,
// //     required this.driverName,
// //     required this.driverImageUrl,
// //     required this.userId,
// //     required this.driverId,
// //     required this.phoneNumber,
// //   }) : super(key: key);

// //   @override
// //   State<UserChatScreen> createState() => _UserChatScreenState();
// // }

// // class _UserChatScreenState extends State<UserChatScreen> {
// //   final TextEditingController _messageController = TextEditingController();
// //   final ScrollController _scrollController = ScrollController();
// //   late ChatMessageProvider _chatMessageProvider;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _chatMessageProvider = Provider.of<ChatMessageProvider>(context, listen: false);
// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       _loadMessages();
// //     });
// //   }

// //   void _loadMessages() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     final chatroomId = prefs.getString('chatroom_id');
// //     if (chatroomId != null) {
// //       await _chatMessageProvider.getMessages(chatroomId);
// //     }
// //   }

// //   Future<void> _sendMessage() async {
// //     if (_messageController.text.trim().isEmpty) return;

// //     final prefs = await SharedPreferences.getInstance();
// //     final chatroomId = prefs.getString('chatroom_id');

// //     if (chatroomId != null) {
// //       final success = await _chatMessageProvider.sendMessage(
// //         chatroomId: chatroomId,
// //         message: _messageController.text.trim(),
// //       );

// //       if (success) {
// //         _messageController.clear();
// //         // Scroll to bottom after sending message
// //         if (_scrollController.hasClients) {
// //           _scrollController.animateTo(
// //             0,
// //             duration: const Duration(milliseconds: 300),
// //             curve: Curves.easeOut,
// //           );
// //         }
// //       }
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final screenSize = MediaQuery.of(context).size;

// //     return Scaffold(
// //       appBar: AppBar(
// //         titleSpacing: 0,
// //         leading: IconButton(
// //           icon: const Icon(Icons.arrow_back),
// //           onPressed: () => Navigator.pop(context),
// //         ),
// //         title: Row(
// //           children: [
// //             CircleAvatar(
// //               radius: 20,
// //               backgroundImage: widget.driverImageUrl.isNotEmpty
// //                   ? NetworkImage(widget.driverImageUrl)
// //                   : const AssetImage("assets/images/profile.png") as ImageProvider,
// //             ),
// //             const SizedBox(width: 8),
// //             Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Text(
// //                   widget.driverName,
// //                   style: AppTextTheme.getLightTextTheme(context).titleMedium,
// //                 ),
// //                 Text(
// //                   widget.phoneNumber,
// //                   style: AppTextTheme.getLightTextTheme(context).bodySmall,
// //                 ),
// //               ],
// //             ),
// //           ],
// //         ),
// //       ),
// //       body: Column(
// //         children: [
// //           Expanded(
// //             child: Consumer<ChatMessageProvider>(
// //               builder: (context, provider, child) {
// //                 if (provider.isLoading) {
// //                   return const Center(child: CircularProgressIndicator());
// //                 }

// //                 if (provider.messages.isEmpty) {
// //                   return const Center(child: Text('No messages yet'));
// //                 }

// //                 return ListView.builder(
// //                   controller: _scrollController,
// //                   reverse: true,
// //                   padding: const EdgeInsets.all(16),
// //                   itemCount: provider.messages.length,
// //                   itemBuilder: (context, index) {
// //                     final message = provider.messages[index];
// //                     final isMe = message.senderId == widget.userId;

// //                     return Padding(
// //                       padding: const EdgeInsets.only(bottom: 8),
// //                       child: Align(
// //                         alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
// //                         child: Container(
// //                           constraints: BoxConstraints(
// //                             maxWidth: screenSize.width * 0.7,
// //                           ),
// //                           padding: const EdgeInsets.symmetric(
// //                             horizontal: 16,
// //                             vertical: 10,
// //                           ),
// //                           decoration: BoxDecoration(
// //                             color: isMe ? Colors.blue : Colors.grey[200],
// //                             borderRadius: BorderRadius.circular(20),
// //                           ),
// //                           child: Text(
// //                             message.content,
// //                             style: TextStyle(
// //                               color: isMe ? Colors.white : Colors.black,
// //                             ),
// //                           ),
// //                         ),
// //                       ),
// //                     );
// //                   },
// //                 );
// //               },
// //             ),
// //           ),
// //           Container(
// //             padding: const EdgeInsets.all(8),
// //             decoration: const BoxDecoration(
// //               color: Colors.white,
// //               boxShadow: [
// //                 BoxShadow(
// //                   color: Colors.black12,
// //                   blurRadius: 4,
// //                 ),
// //               ],
// //             ),
// //             child: Row(
// //               children: [
// //                 Expanded(
// //                   child: TextField(
// //                     controller: _messageController,
// //                     decoration: InputDecoration(
// //                       hintText: 'Type a message...',
// //                       border: OutlineInputBorder(
// //                         borderRadius: BorderRadius.circular(25),
// //                         borderSide: BorderSide.none,
// //                       ),
// //                       filled: true,
// //                       fillColor: Colors.grey[200],
// //                       contentPadding: const EdgeInsets.symmetric(
// //                         horizontal: 20,
// //                         vertical: 10,
// //                       ),
// //                     ),
// //                     textCapitalization: TextCapitalization.sentences,
// //                     minLines: 1,
// //                     maxLines: 5,
// //                   ),
// //                 ),
// //                 const SizedBox(width: 8),
// //                 Container(
// //                   decoration: BoxDecoration(
// //                     color: Theme.of(context).primaryColor,
// //                     shape: BoxShape.circle,
// //                   ),
// //                   child: IconButton(
// //                     icon: const Icon(Icons.send, color: Colors.white),
// //                     onPressed: _sendMessage,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   @override
// //   void dispose() {
// //     _messageController.dispose();
// //     _scrollController.dispose();
// //     super.dispose();
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:rideapp/services/sockets_io.dart';
// import 'package:rideapp/utils/theme/app_text_theme.dart';
// import 'package:rideapp/viewmodel/provider/message_provider/chat_provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:developer';

// class UserChatScreen extends StatefulWidget {
//   final String driverName;
//   final String driverImageUrl;
//   final String userId;
//   final String driverId;
//   final String phoneNumber;

//   const UserChatScreen({
//     Key? key,
//     required this.driverName,
//     required this.driverImageUrl,
//     required this.userId,
//     required this.driverId,
//     required this.phoneNumber,
//   }) : super(key: key);

//   @override
//   State<UserChatScreen> createState() => _UserChatScreenState();
// }

// class _UserChatScreenState extends State<UserChatScreen> {
//   final TextEditingController _messageController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   late ChatMessageProvider _chatMessageProvider;
//   bool _isSending = false;
//   final SocketService _socketService = SocketService();

//   @override
//   void initState() {
//     super.initState();
//     _initializeChat();
//   }

//   void _initializeChat() async {
//     _chatMessageProvider = Provider.of<ChatMessageProvider>(context, listen: false);

//     // Print debug info
//     log('Initializing chat for user: ${widget.userId}');
//     log('Driver ID: ${widget.driverId}');

//     final prefs = await SharedPreferences.getInstance();
//     final chatroomId = prefs.getString('chatroom_id');
//     log('Chatroom ID from SharedPreferences: $chatroomId');

//     if (chatroomId != null) {
//       // Initialize socket connection
//       _chatMessageProvider.initSocketConnection(chatroomId);

//       // Get initial messages
//       await _chatMessageProvider.getMessages(chatroomId);

//       // Debug log after getting messages
//       log('Initial messages loaded. Count: ${_chatMessageProvider.messages.length}');
//     } else {
//       log('No chatroom ID found in SharedPreferences');
//     }
//   }

//   Future<void> _sendMessage() async {
//     if (_messageController.text.trim().isEmpty || _isSending) return;

//     setState(() => _isSending = true);

//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final chatroomId = prefs.getString('chatroom_id');

//       if (chatroomId != null) {
//         log('Sending message to chatroom: $chatroomId');
//         final success = await _chatMessageProvider.sendMessage(
//           chatroomId: chatroomId,
//           message: _messageController.text.trim(),
//         );

//         if (success) {
//           _messageController.clear();
//           if (_scrollController.hasClients) {
//             _scrollController.animateTo(
//               0,
//               duration: const Duration(milliseconds: 300),
//               curve: Curves.easeOut,
//             );
//           }
//         } else {
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('Failed to send message. Please try again.'))
//             );
//           }
//         }
//       } else {
//         log('No chatroom ID found when sending message');
//       }
//     } catch (e) {
//       log('Error sending message: $e');
//     } finally {
//       if (mounted) {
//         setState(() => _isSending = false);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;

//     return Scaffold(
//       appBar: AppBar(
//         titleSpacing: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Row(
//           children: [
//             CircleAvatar(
//               radius: 20,
//               backgroundImage: widget.driverImageUrl.isNotEmpty
//                   ? NetworkImage(widget.driverImageUrl)
//                   : const AssetImage("assets/images/profile.png") as ImageProvider,
//             ),
//             const SizedBox(width: 8),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     widget.driverName,
//                     style: AppTextTheme.getLightTextTheme(context).titleMedium,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   Text(
//                     widget.phoneNumber,
//                     style: AppTextTheme.getLightTextTheme(context).bodySmall,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           // Debug button
//           IconButton(
//             icon: const Icon(Icons.bug_report),
//             onPressed: () {
//               _debugPrintState();
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: Consumer<ChatMessageProvider>(
//               builder: (context, provider, child) {
//                 if (provider.isLoading) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 if (provider.messages.isEmpty) {
//                   return Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Icon(
//                           Icons.message_outlined,
//                           size: 48,
//                           color: Colors.grey,
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           'No messages yet\nStart the conversation!',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             color: Colors.grey[600],
//                             fontSize: 16,
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 }

//                 return ListView.builder(
//                   controller: _scrollController,
//                   reverse: true,
//                   padding: const EdgeInsets.all(16),
//                   itemCount: provider.messages.length,
//                   itemBuilder: (context, index) {
//                     final message = provider.messages[index];
//                     final isMe = message.senderId == widget.userId;

//                     return Padding(
//                       padding: const EdgeInsets.only(bottom: 8),
//                       child: Align(
//                         alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
//                         child: Container(
//                           constraints: BoxConstraints(
//                             maxWidth: screenSize.width * 0.7,
//                           ),
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 16,
//                             vertical: 10,
//                           ),
//                           decoration: BoxDecoration(
//                             color: isMe ? Colors.blue : Colors.grey[200],
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: Text(
//                             message.content,
//                             style: TextStyle(
//                               color: isMe ? Colors.white : Colors.black,
//                             ),
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: const BoxDecoration(
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black12,
//                   blurRadius: 4,
//                 ),
//               ],
//             ),
//             child: SafeArea(
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: _messageController,
//                       decoration: InputDecoration(
//                         hintText: 'Type a message...',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(25),
//                           borderSide: BorderSide.none,
//                         ),
//                         filled: true,
//                         fillColor: Colors.grey[200],
//                         contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 20,
//                           vertical: 10,
//                         ),
//                       ),
//                       textCapitalization: TextCapitalization.sentences,
//                       minLines: 1,
//                       maxLines: 5,
//                       onSubmitted: (_) => _sendMessage(),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Container(
//                     decoration: BoxDecoration(
//                       color: Theme.of(context).primaryColor,
//                       shape: BoxShape.circle,
//                     ),
//                     child: IconButton(
//                       icon: _isSending
//                           ? const SizedBox(
//                               width: 24,
//                               height: 24,
//                               child: CircularProgressIndicator(
//                                 strokeWidth: 2,
//                                 valueColor: AlwaysStoppedAnimation<Color>(
//                                   Colors.white,
//                                 ),
//                               ),
//                             )
//                           : const Icon(Icons.send, color: Colors.white),
//                       onPressed: _isSending ? null : _sendMessage,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _debugPrintState() async {
//     final prefs = await SharedPreferences.getInstance();
//     log('=== Chat Debug Info ===');
//     log('User ID: ${widget.userId}');
//     log('Driver ID: ${widget.driverId}');
//     log('Chatroom ID: ${prefs.getString('chatroom_id')}');
//     log('Message Count: ${_chatMessageProvider.messages.length}');
//     log('Is Sending: $_isSending');
//     log('Socket Service initialized: ${_socketService}');
//     log('Current Message: ${_messageController.text}');
//     log('====================');
//   }

//   @override
//   void dispose() {
//     _chatMessageProvider.closeSocket();
//     _messageController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }
// }

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rideapp/utils/theme/app_text_theme.dart';
import 'package:rideapp/viewmodel/provider/message_provider/chatroom_provider.dart';

class UserChatScreen extends StatefulWidget {
  final String driverName;
  final String driverImageUrl;
  final String userId;
  final String driverId;
  final String phoneNumber;

  const UserChatScreen({
    Key? key,
    required this.driverName,
    required this.driverImageUrl,
    required this.userId,
    required this.driverId,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  _UserChatScreenState createState() => _UserChatScreenState();
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
