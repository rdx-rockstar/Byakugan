import 'package:flutter/material.dart';
import 'package:women_safety/screens/authenticate/sign_in.dart';
import 'package:women_safety/screens/authenticate/register.dart';

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {

  bool showSignIn = true;
  void toggelView() {
    setState(() => showSignIn = !showSignIn);
  }

  @override
  Widget build(BuildContext context) {
    if( showSignIn ) {
      return SignIn(toggelView: toggelView);
    } else {
      return Register(toggelView: toggelView);
    }
  }
}
