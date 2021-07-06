import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/controller/user_controller.dart';
import 'package:flutter/material.dart';

import 'message_bubble.dart';

class MessagesStreamBuilder extends StatelessWidget {
  final _fireStore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final UserController _userController = UserController();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        final messages = snapshot.data.docs.reversed;
        List<MessageBubble> messagesBubbleWidgets = [];

        for (var message in messages) {
          final messageText = message.get('text');
          final messageSender = message.get('sender');
          final messageId = message.id;
          final messageCreatedAt = message.get('createdAt');
          final messageImageUrl = message.get('imageUrl');

          //
          // print(messageCreatedAt.runtimeType);

          final messageBubble = MessageBubble(
            text: messageText,
            sender: messageSender,
            isMe: _auth.currentUser.email == messageSender,
            id: messageId,
            timestamp: messageCreatedAt,
            imageUrl: messageImageUrl,
          );

          messagesBubbleWidgets.add(messageBubble);
        }
        return Expanded(
            child: ListView(
          reverse: true,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          children: messagesBubbleWidgets,
        ));
      },
      stream:
          _fireStore.collection("messages").orderBy("createdAt").snapshots(),
    );
  }
}
