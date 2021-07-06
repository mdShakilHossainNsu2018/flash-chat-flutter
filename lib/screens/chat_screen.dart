import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/controller/loading_indicator.dart';
import 'package:flash_chat/controller/msg_controller.dart';
import 'package:flash_chat/controller/pic_uploader.dart';
import 'package:flash_chat/controller/user_controller.dart';
import 'package:flash_chat/widgets/messages_stream_builder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../constants.dart';

final _auth = FirebaseAuth.instance;
final _picker = ImagePicker();

class ChatScreen extends StatefulWidget {
  static const String routeName = "chat_screen";
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String _messageText;

  final _messageController = TextEditingController();
  final UploadPicController _uploadPicController = UploadPicController();
  final MessageController _messageSenderController = MessageController();
  final LoadingIndicator _loadingIndicator = LoadingIndicator();
  final UserController _userController = UserController();
  final _fireStore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    // print(_userController.user.email);
  }

  void onUpdateDone({dynamic value}) {
    if (value != null) {
      print(value);
    }

    Navigator.pop(context);
    setState(() {});

    // print("onUpdateDone:     function called");
    // _auth.currentUser
    //     .updatePhotoURL(value)
    //     .then((value) => popAndUpdate())
    //     .catchError((err) => popAndUpdate());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                //Implement logout functionality
                _auth.signOut().then((value) => Navigator.pop(context));
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StreamBuilder<QuerySnapshot>(
                    builder: (BuildContext context, snapshot) {
                      // if(snapshot.hasData){
                      if (!snapshot.hasData) {
                        return CircleAvatar(
                          radius: 30,
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
                        child: snapshot.data.docs.isEmpty
                            ? Text(
                                _auth.currentUser.email
                                    .substring(0, 2)
                                    .toUpperCase(),
                                style: TextStyle(
                                    fontSize: 30, fontWeight: FontWeight.w700),
                              )
                            : null,
                        radius: 30,
                      );
                      // }
                      // return ;
                    },
                    stream: _fireStore
                        .collection("profile")
                        .where("sender", isEqualTo: _auth.currentUser.email)
                        .snapshots(),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.email,
                        color: Colors.white,
                      ),
                      Text(
                        _auth.currentUser.email,
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                  ElevatedButton.icon(
                      onPressed: () async {
                        final PickedFile pickedFile = await _picker.getImage(
                            source: ImageSource.gallery,
                            maxWidth: 150,
                            maxHeight: 150);
                        _loadingIndicator.showLoadingIndicator(
                            context: context, text: "Updating profile");
                        _uploadPicController
                            .uploadProfilePic(
                              pickedFile: pickedFile,
                              context: context,
                            )
                            .then((value) => _messageSenderController
                                .setProfileMessage(imageUrl: value)
                                .then((value) => onUpdateDone()))
                            .catchError((error) => onUpdateDone(value: error));
                      },
                      icon: Icon(Icons.cloud_upload),
                      label: Text("Upload Profile"))
                ],
              ),
            ),
            // ListTile(
            //   dense: true,
            //   title: Text(
            //     'PROFILE',
            //     style: TextStyle(fontWeight: FontWeight.bold),
            //   ),
            //   leading: Icon(Icons.assignment_ind_outlined),
            //   onTap: () {
            //     // Update the state of the app
            //     // ...
            //     // Then close the drawer
            //     exit(0);
            //   },
            // ),
            ListTile(
              dense: true,
              title: Text(
                'EXIT',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              leading: Icon(Icons.exit_to_app),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                exit(0);
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessagesStreamBuilder(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      onChanged: (value) {
                        //Do something with the user input.
                        _messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final PickedFile pickedFile =
                          await _picker.getImage(source: ImageSource.gallery);
                      _loadingIndicator.showLoadingIndicator(
                          context: context, text: "Uploading Image...");
                      _uploadPicController
                          .uploadPic(
                              pickedFile: pickedFile,
                              context: context,
                              loggedInUser: _auth.currentUser)
                          .then((value) => buildSendMessage(value)
                              .then((value) => Navigator.pop(context)));
                    },
                    icon: Icon(
                      Icons.image,
                      color: Colors.lightBlueAccent,
                      size: 30,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final PickedFile pickedFile =
                          await _picker.getImage(source: ImageSource.camera);
                      _loadingIndicator.showLoadingIndicator(
                          context: context, text: "Uploading...");
                      _uploadPicController
                          .uploadPic(
                              pickedFile: pickedFile,
                              context: context,
                              loggedInUser: _auth.currentUser)
                          .then((value) => buildSendMessage(value)
                              .then((value) => Navigator.pop(context)));
                    },
                    icon: Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.lightBlueAccent,
                      size: 30,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      //Implement send functionality.
                      _messageController.clear();
                      _messageSenderController.sendMessage(
                          imageUrl: null,
                          messageText: _messageText,
                          senderEmail: _auth.currentUser.email);
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<DocumentReference<Object>> buildSendMessage(String value) async {
    return await _messageSenderController.sendMessage(
        imageUrl: value,
        messageText: null,
        senderEmail: _auth.currentUser.email);
  }
}
