import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Main extends StatelessWidget {
  static const MethodChannel _channel = MethodChannel("service_channel");
  @override
  Widget build(BuildContext context) {

    return Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
        ),
        child: ConstrainedBox(
        constraints: BoxConstraints.expand(),
        child: FlatButton(
            onPressed: () {
              _channel.invokeMethod("on_off").then((value){});
            },
            padding: EdgeInsets.all(0.0),
            child: Image.asset('assets/images/playdark.png'))));

  }
}