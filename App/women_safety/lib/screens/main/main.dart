import 'package:flutter/material.dart';

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          SizedBox(width: 100),
          GestureDetector(
            child: Icon(Icons.call),
            onTap: () {
              print('This is the button which is pressed');
            },
          ),
          SizedBox(width: 10),
          GestureDetector(
            child: Icon(Icons.people),
            onTap: () {
              print('This is the button which is pressed');
            },
          ),
        ],
      ),
    );
  }
}