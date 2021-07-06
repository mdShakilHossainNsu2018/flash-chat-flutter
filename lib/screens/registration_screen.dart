import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/constants.dart';
import 'package:flash_chat/controller/api_error.dart';
import 'package:flash_chat/controller/loading_indicator.dart';
import 'package:flash_chat/controller/user_controller.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flash_chat/widgets/rounded_button.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class RegistrationScreen extends StatefulWidget {
  static const String routeName = "registration_screen";

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  String email;
  String password;

  final _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  bool _isObscureText = true;
  final UserController _userController = UserController();
  final LoadingIndicator _loadingIndicator = LoadingIndicator();
  final ApiError _apiError = ApiError();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: _isLoading,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    height: 200.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  email = value;
                },
                decoration: kTextFiledDecoration.copyWith(
                  hintText: 'Enter your email',
                  suffixIcon: Icon(
                    Icons.email,
                    color: Colors.lightBlueAccent,
                  ),
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                textAlign: TextAlign.center,
                obscureText: _isObscureText,
                onChanged: (value) {
                  password = value;
                },
                decoration: kTextFiledDecoration.copyWith(
                  hintText: 'Enter your password',
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _isObscureText = !_isObscureText;
                      });
                    },
                    icon: Icon(
                      _isObscureText
                          ? Icons.remove_red_eye
                          : Icons.remove_red_eye_outlined,
                      color: Colors.lightBlueAccent,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                onPressed: () async {
                  setState(() {
                    _isLoading = true;
                  });
                  _loadingIndicator.showLoadingIndicator(
                      context: context, text: "Loading...");
                  _userController
                      .createUserWithEmailAndPassword(
                          context: context, email: email, password: password)
                      .then((value) => _onSuccessfullyRegister())
                      .catchError(
                          (error) => _apiError.showError(error, context));
                  setState(() {
                    _isLoading = false;
                  });
                },
                text: 'Register',
                color: Colors.blueAccent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSuccessfullyRegister() {
    Navigator.pop(context);
    Navigator.popAndPushNamed(context, ChatScreen.routeName);
  }
}
