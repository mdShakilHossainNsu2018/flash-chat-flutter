import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'loading_indicator.dart';

final _fireStore = FirebaseFirestore.instance;

class MessageController {
  final LoadingIndicator _loadingIndicator = LoadingIndicator();
  final _auth = FirebaseAuth.instance;
  Future<DocumentReference> sendMessage(
      {@required String messageText,
      @required String senderEmail,
      @required String imageUrl}) async {
    final DocumentReference _fireStoreInstance =
        await _fireStore.collection("messages").add({
      "text": messageText,
      "sender": senderEmail,
      "createdAt": Timestamp.now(),
      "imageUrl": imageUrl,
    });
    return _fireStoreInstance;
  }

  QuerySnapshot querySnapshot;
  Future<DocumentReference> setProfileMessage(
      {@required String imageUrl}) async {
    // String id;
    DocumentReference _fireStoreInstance;

    final exitingProfile = await _fireStore
        .collection("profile")
        .where('sender', isEqualTo: _auth.currentUser.email)
        .get()
        .then((value) => setQuery(value));
    if (querySnapshot.docs.isNotEmpty) {
      var collection = _fireStore.collection("profile");
      collection.doc(querySnapshot.docs.first.id).update({
        "imageUrl": imageUrl,
      });
    } else {
      final DocumentReference _fireStoreInstance =
          await _fireStore.collection("profile").add({
        "sender": _auth.currentUser.email,
        "createdAt": Timestamp.now(),
        "imageUrl": imageUrl,
      });
    }
    return _fireStoreInstance;
  }

  Future<DocumentReference> deleteMessage(
      {@required BuildContext context, @required String id}) {
    _loadingIndicator.showLoadingIndicator(
        context: context, text: "Deleting..");
    return _fireStore
        .collection("messages")
        .doc(id)
        .delete()
        .then((value) => messageDelete(value, context));
  }

  messageDelete(void value, context) {
    Navigator.pop(context);
    Navigator.pop(context);
    final snackBar = SnackBar(content: Text('Message deleted Successfully.'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  setQuery(QuerySnapshot<Map<String, dynamic>> value) {
    querySnapshot = value;
  }
}
