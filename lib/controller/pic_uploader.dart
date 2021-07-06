import 'dart:io' as io;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

class UploadPicController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<String> uploadPic(
      {@required PickedFile pickedFile,
      @required BuildContext context,
      @required User loggedInUser}) async {
    List<firebase_storage.UploadTask> _uploadTasks = [];
    if (pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No file was selected'),
      ));
      return null;
    }

    firebase_storage.UploadTask uploadTask;

    //Create a reference to the location you want to upload to in firebase
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child("images")
        .child("/${loggedInUser.uid}/${basename(pickedFile.path)}");

    final metadata = firebase_storage.SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'picked-file-path': pickedFile.path});

    if (kIsWeb) {
      uploadTask = ref.putData(await pickedFile.readAsBytes(), metadata);
    } else {
      uploadTask = ref.putFile(io.File(pickedFile.path), metadata);
    }

    String url;
    await uploadTask.whenComplete(() async {
      url = await uploadTask.snapshot.ref.getDownloadURL();
    });

    return url;
  }

  Future<String> uploadProfilePic({
    @required PickedFile pickedFile,
    @required BuildContext context,
  }) async {
    List<firebase_storage.UploadTask> _uploadTasks = [];
    if (pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No file was selected'),
      ));
      return null;
    }

    firebase_storage.UploadTask uploadTask;

    //Create a reference to the location you want to upload to in firebase
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child("images")
        .child("/${_auth.currentUser.uid}/profile/profile-pic.jpg");

    final metadata = firebase_storage.SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'picked-file-path': pickedFile.path});

    if (kIsWeb) {
      uploadTask = ref.putData(await pickedFile.readAsBytes(), metadata);
    } else {
      uploadTask = ref.putFile(io.File(pickedFile.path), metadata);
    }

    String url;
    await uploadTask.whenComplete(() async {
      url = await uploadTask.snapshot.ref.getDownloadURL();
    });

    return url;
  }
}
