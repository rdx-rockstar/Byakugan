import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:women_safety/maps/maps_on_alert_page.dart';
import 'package:women_safety/services/auth.dart';
import 'package:women_safety/models/user.dart';
import 'package:women_safety/screens/show_pages.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class Home extends StatelessWidget {
  static MethodChannel _channel = MethodChannel("service_channel");
  final AuthService _auth = AuthService();
  Home(User user){
    _channel.invokeMethod("setEmail",<String, dynamic>{
    'email': user.phone,
    }).then((value){});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[600],
      appBar: AppBar(
        title: Text('Byakugan'),
        backgroundColor: Colors.amber[800],
        elevation: 0.2,
        actions: <Widget>[
          IconButton(
              onPressed: () async {
                _channel.invokeMethod("victim").then((value) async {
                    if(value!="-"){
                        LatLng userDestination;
                      _channel.invokeMethod("getLat",<String, dynamic>{
                      'email': value}).then((val){
                        var jsonResponse = convert.jsonDecode(val);
                        userDestination=new LatLng(double.parse(jsonResponse['latitude']), double.parse(jsonResponse['longitude']));
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MapOnCall(userDestination, value)
                            )
                        );
                      });
                    }
                    else{
                      Fluttertoast.showToast(
                          msg: "Everyone nearby is safe",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                      );
                    }
                });

              },
              icon: Icon(Icons.notification_important)),
          TextButton.icon(
            icon: Icon(Icons.person,color: Colors.white,),
            label: Text('logout',style:TextStyle(color: Colors.white)),
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
