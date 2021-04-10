import 'package:flutter/material.dart';
import 'package:women_safety/services/auth.dart';

class SignIn extends StatefulWidget {

  final Function toggelView;
  SignIn({ this.toggelView });

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  String number = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[100],
      appBar: AppBar(
        backgroundColor: Colors.amber[800],
        elevation: 0.0,
        title: Text('Login'),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: Column(
          children: <Widget>[
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  SizedBox(height: 20.0,),
                  TextFormField(
                    obscureText: true,
                    validator: (val) => val.length < 10 ? 'Enter a valid Phone Number': null,
                    onChanged: (val) {
                      setState(() => number = val);
                    },
                  ),
                  SizedBox(height: 20.0,),
                  RaisedButton(
                    color: Colors.pink[400],
                    child: Text(
                        'Sign in',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        dynamic result = await _auth.signInWithPhoneNumber(number, context);
                      }
                    },
                  ),
                  SizedBox(height: 12.0,),
                  Text(
                    error,
                    style: TextStyle(color: Colors.red, fontSize: 14.0),
                  )
                ],
              ),
            ),
            SizedBox(height: 50.0,),
            RaisedButton(
              child: Text('Sign in anom'),
              onPressed: () async {
                dynamic result = await _auth.signInAnom();
                if(result == null){
                  print('Sign in Failed');
                }
                else{
                  print('Sign in successful');
                }
              },
            ),
          ],
        )
      ),
    );
  }
}
