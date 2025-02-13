import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 230,
      decoration: BoxDecoration(
        color: const Color(0XFFB3FCB1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Text(
          "Ok bro...",
          style: TextStyle(
            color: Colors.black,
            fontFamily: "Montserrat",
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
