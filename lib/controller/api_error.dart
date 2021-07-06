import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ApiError {
  String errorMessage(dynamic error) {
    final code = error.code;
    String errorText;
    if (code == 'ERROR_INVALID_EMAIL') {
      errorText = "Invalid Email";
    } else if (code == 'ERROR_WRONG_PASSWORD') {
      errorText = "Wrong Password";
    } else if (code == 'ERROR_USER_NOT_FOUND') {
      errorText = "User not Found";
    } else if (code == 'ERROR_TOO_MANY_REQUESTS') {
      errorText = "Too many request";
    } else if (code == 'ERROR_USER_DISABLED') {
      errorText = "User Disabled";
    } else if (code == 'ERROR_OPERATION_NOT_ALLOWED') {
      errorText = "Something Wrong";
    } else {
      errorText = "Connectivity error";
    }
    return errorText;
  }

  void showError(error, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        error.message.toString(),
        style: TextStyle(color: Colors.red),
      ),
    ));
    Navigator.pop(context);
  }
}
