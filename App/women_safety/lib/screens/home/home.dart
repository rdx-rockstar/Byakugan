import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:women_safety/services/auth.dart';
import 'package:women_safety/models/user.dart';
import 'package:women_safety/screens/show_pages.dart';

class Home extends StatelessWidget {
  static MethodChannel _channel = MethodChannel("service_channel");
  final AuthService _auth = AuthService();
  Home(User user){
    _channel.invokeMethod("setEmail",<String, dynamic>{
    'email': user.email,
    }).then((value){});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        title: Text('Byakugan'),
        backgroundColor: Colors.blue[400],
        elevation: 0.2,
        actions: <Widget>[
          FlatButton.icon(
            icon: Icon(Icons.person,color: Colors.white),
            label: Text('logout',style:TextStyle(color: Colors.white),),
            onPressed: () async {
              await _auth.signOut();
            },
          )
        ],
      ),
      body: ShowPages(),
    );
  }
}
