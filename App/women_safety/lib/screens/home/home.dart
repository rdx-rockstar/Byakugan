import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:women_safety/maps/maps_on_alert_page.dart';
import 'package:women_safety/services/auth.dart';
import 'package:women_safety/screens/show_pages.dart';

class Home extends StatelessWidget {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        title: Text('Women Empowerment'),
        backgroundColor: Colors.brown[400],
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
              onPressed: () {
                LatLng userDestination = new LatLng(26.852174, 80.938358);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MapOnCall(userDestination)));
              },
              icon: Icon(Icons.notification_important)),
          TextButton.icon(
            icon: Icon(Icons.person),
            label: Text('logout'),
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
