import 'package:flutter/material.dart';

class LoadingIndicator{
  void showLoadingIndicator({
   @required BuildContext context,
   @required String text,
  }) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
              child: Container(
                width: 300,
                height: 300,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      strokeWidth: 6,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(text),
                  ],
                ),
              ));
        });
  }
}