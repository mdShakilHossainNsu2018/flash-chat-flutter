import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserController {
  User _loggedInUser;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _fireStore = FirebaseFirestore.instance;

  Future<User> getCurrentUser() async {
    try {
      final _user = await _auth.currentUser;
      if (_user != null) {
        _loggedInUser = _user;
      }
    } catch (e) {
      print(e);
    }
    print(
        "0Embedding the 'MyApp' inside the MaterialApp widget has solved the problem for me. ${_loggedInUser.email}");
    return _loggedInUser;
  }

  // User get getLoggedInUser {
  //   return _loggedInUser;
  // }
  //
  // String get getLoggedInUserEmail {
  //   return _loggedInUser.email;
  // }

  Future<UserCredential> signInWithEmailAndPassword(
      {@required BuildContext context,
      @required String email,
      @required String password}) async {
    return await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    // Navigator.pushNamed(context, ChatScreen.routeName);
  }

  Future<UserCredential> createUserWithEmailAndPassword(
      {@required BuildContext context,
      @required String email,
      @required String password}) async {
    return await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    // Navigator.pushNamed(context, ChatScreen.routeName);
  }

  Future<void> setProfilePic(String value) {
    _auth.currentUser.updatePhotoURL(value);
  }

  Future<String> getUrlByEmail(String email) async {
    String url;
    final exitingProfile = await _fireStore
        .collection("profile")
        .where('sender', isEqualTo: email)
        .get()
        .then((value) => {url = value.docs.first.get("imageUrl")});
    return url;
  }
}
