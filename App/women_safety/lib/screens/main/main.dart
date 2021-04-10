import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Main extends StatelessWidget {
  static const MethodChannel _channel = MethodChannel("service_channel");
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          SizedBox(width: 100),
          GestureDetector(
            child: Icon(Icons.call),
            onTap: () {
              _channel.invokeMethod("on_off").then((value){});
              print('This is the button which is pressed');
            },
          ),
          SizedBox(width: 10),
          GestureDetector(
            child: Icon(Icons.people),
            onTap: () {
              _channel.invokeMethod("on_off").then((value){});
              print('This is the button which is pressed');
            },
          ),
        ],
      ),
    );
  }
}