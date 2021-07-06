import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/controller/msg_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  final MessageController _messageController = MessageController();
  MessageBubble(
      {@required this.sender,
      @required this.text,
      @required this.isMe,
      @required this.id,
      @required this.timestamp,
      @required this.imageUrl});
  final String sender, text;
  final bool isMe;
  final String id;
  final Timestamp timestamp;
  final String imageUrl;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _fireStore = FirebaseFirestore.instance;

  String getDateTime(timestamp) {
    var date =
        DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);
    return DateFormat('MM/dd, hh:mm a').format(date);
  }

  SnackBar snackBar;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        if (_auth.currentUser.email != sender) {
          return;
        }
        showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Container(
                height: 100,
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        _messageController.deleteMessage(
                            context: context, id: id);
                      },
                      icon: Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: 50,
                      ),
                    )
                  ],
                ),
              );
            });
      },
      child: Padding(
        padding: (imageUrl != null && text == null)
            ? const EdgeInsets.all(0)
            : EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Material(
              borderRadius: (imageUrl != null && text == null)
                  ? BorderRadius.zero
                  : BorderRadius.circular(30),
              elevation: 10,
              color: isMe ? Colors.lightBlueAccent : Colors.white,
              child: Padding(
                padding: (imageUrl != null && text == null)
                    ? EdgeInsets.symmetric(vertical: 10.0, horizontal: 10)
                    : const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 20),
                child: (imageUrl != null && text == null)
                    ? Image.network(
                        imageUrl,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }
                          return Container(
                            height: 200,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes
                                    : null,
                              ),
                            ),
                          );
                        },
                      )
                    : Text(
                        text,
                        style: TextStyle(
                            fontSize: 15,
                            color: isMe ? Colors.white : Colors.black),
                      ),
              ),
            ),
            Row(
              mainAxisAlignment:
                  isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                Text(
                  getDateTime(timestamp),
                  style: TextStyle(color: Colors.black54, fontSize: 12.0),
                ),
                SizedBox(
                  width: 5,
                ),
                StreamBuilder<QuerySnapshot>(
                    stream: _fireStore
                        .collection("profile")
                        .where("sender", isEqualTo: sender)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return CircleAvatar(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        );
                      }

                      return CircleAvatar(
                        backgroundImage: snapshot.data.docs.isNotEmpty
                            ? NetworkImage(
                                snapshot.data.docs.first.get("imageUrl"))
                            : null,
                        backgroundColor: Colors.brown.shade800,
                        radius: 10,
                        child: snapshot.data.docs.isEmpty
                            ? Text(sender.substring(0, 1).toUpperCase())
                            : null,
                      );
                    })
              ],
            ),
          ],
        ),
      ),
    );
  }
}
