import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:women_safety/models/user.dart';
import 'package:women_safety/screens/wrapper.dart';
import 'package:provider/provider.dart';
import 'package:women_safety/services/auth.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static MethodChannel _channel = MethodChannel("service_channel");
  @override
  Widget build(BuildContext context) {
    _channel.invokeMethod("perm");
    return MultiProvider(
      providers: [
        StreamProvider<User>(create: (_) => AuthService().user),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Wrapper(),
      ),
    );
  }
}
