import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:women_safety/models/user.dart';
import 'package:women_safety/screens/authenticate/authenticate.dart';
import 'package:women_safety/screens/home/home.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    if(user == null){
      return Authenticate();
    } else {
      return Home();
    }
  }
}
