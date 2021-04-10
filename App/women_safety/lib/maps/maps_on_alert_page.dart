import 'package:flutter/material.dart';
import 'api.dart'; // Stores the Google Maps API Key
import 'dart:async';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'dart:math' show cos, sqrt, asin;

LatLng userDestination;
String email;
// Example to open this page
// LatLng userDestination = new LatLng(26.852174, 80.938358);
//               Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => MapOnCall(userDestination)));

class MapOnCall extends StatelessWidget {
  MapOnCall(LatLng p,String em) {
    email=em;
    userDestination = p;
    print(userDestination);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Maps',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MapView(),
    );
  }
}

class MapView extends StatefulWidget {
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  CameraPosition _initialLocation = CameraPosition(target: LatLng(0.0, 0.0));
  GoogleMapController mapController;

  int decimalPlacesToCompare = 3;
  Position _currentPosition;
  String _currentAddress;

  final startAddressController = TextEditingController();
  final destinationAddressController = TextEditingController();

  final startAddressFocusNode = FocusNode();
  final desrinationAddressFocusNode = FocusNode();

  String _startAddress = '';
  String _destinationAddress = '';
  String _destinationAddress2 = '';
  String _placeDistance;

  Set<Marker> markers = {};

  PolylinePoints polylinePoints;
  PolylinePoints polylinePoints2;
  int score1 = 0, score2 = 0;
  Map<PolylineId, Polyline> polylines = {};
  Map<PolylineId, Polyline> polylines2 = {};
  List<LatLng> finalPolylineCoor = [];
  List<LatLng> polylineCoordinates = [];
  List<LatLng> polylineCoordinates2 = [];
  List<LatLng> notSafePoints = [
    LatLng(26.8541536, 80.9491995),
    LatLng(26.8541536, 80.94478269999999),
    LatLng(26.8541546, 80.9481995),
  ];

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget _textField({
    TextEditingController controller,
    FocusNode focusNode,
    String label,
    String hint,
    double width,
    Icon prefixIcon,
    Widget suffixIcon,
    Function(String) locationCallback,
  }) {
    return Container(
      width: width * 0.8,
      child: TextField(
        onChanged: (value) {
          locationCallback(value);
        },
        controller: controller,
        focusNode: focusNode,
        decoration: new InputDecoration(
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            borderSide: BorderSide(
              color: Colors.grey[400],
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            borderSide: BorderSide(
              color: Colors.blue[300],
              width: 2,
            ),
          ),
          contentPadding: EdgeInsets.all(15),
          hintText: hint,
        ),
      ),
    );
  }

  // Method for retrieving the current location
  _getCurrentLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        _currentPosition = position;
        print('Here is the Correct Position of the ');
        print('CURRENT POS: $_currentPosition');
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 18.0,
            ),
          ),
        );
      });
      await _getAddress();
    }).catchError((e) {
      print(e);
    });
  }

  void onButtonPressed() async {
    if (_startAddress != '' && _destinationAddress != '') {
      startAddressFocusNode.unfocus();
      desrinationAddressFocusNode.unfocus();
      setState(() {
        if (markers.isNotEmpty) markers.clear();
        if (polylines.isNotEmpty) polylines.clear();
        if (polylineCoordinates.isNotEmpty) polylineCoordinates.clear();
        _placeDistance = null;
      });

      _calculateDistance().then((isCalculated) {
        if (isCalculated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Distance Calculated Sucessfully'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error Calculating Distance'),
            ),
          );
        }
      });
    } else {
      return null;
    }
  }

  // Method for retrieving the address
  _getAddress() async {
    try {
      List<Placemark> p = await placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      setState(() {
        _currentAddress =
            "${place.name}, ${place.locality}, ${place.postalCode}, ${place.country}";
        startAddressController.text = _currentAddress;
        _startAddress = _currentAddress;
      });

      List<Placemark> pp = await placemarkFromCoordinates(
          userDestination.latitude, userDestination.longitude);
      Placemark place2 = pp[0];
      setState(() {
        _destinationAddress =
            "${place2.name}, ${place2.locality}, ${place2.postalCode}, ${place2.country}";
        destinationAddressController.text = _destinationAddress;
        print('Here Destination Address 2 is get');
        onButtonPressed();
      });
    } catch (e) {
      print(e);
    }
  }

  // Method for calculating the distance between two places
  Future<bool> _calculateDistance() async {
    try {
      // Retrieving placemarks from addresses
      List<Location> startPlacemark = await locationFromAddress(_startAddress);
      List<Location> destinationPlacemark =
          await locationFromAddress(_destinationAddress);

      if (startPlacemark != null && destinationPlacemark != null) {
        // Use the retrieved coordinates of the current position,
        // instead of the address if the start position is user's
        // current position, as it results in better accuracy.
        Position startCoordinates = _startAddress == _currentAddress
            ? Position(
                latitude: _currentPosition.latitude,
                longitude: _currentPosition.longitude)
            : Position(
                latitude: startPlacemark[0].latitude,
                longitude: startPlacemark[0].longitude);
        Position destinationCoordinates = Position(
            latitude: destinationPlacemark[0].latitude,
            longitude: destinationPlacemark[0].longitude);

        // Start Location Marker
        Marker startMarker = Marker(
          markerId: MarkerId('$startCoordinates'),
          position: LatLng(
            startCoordinates.latitude,
            startCoordinates.longitude,
          ),
          infoWindow: InfoWindow(
            title: 'Start',
            snippet: _startAddress,
          ),
          icon: BitmapDescriptor.defaultMarker,
        );

        // Destination Location Marker
        Marker destinationMarker = Marker(
          markerId: MarkerId('$destinationCoordinates'),
          position: LatLng(
            destinationCoordinates.latitude,
            destinationCoordinates.longitude,
          ),
          infoWindow: InfoWindow(
            title: 'Destination',
            snippet: _destinationAddress,
          ),
          icon: BitmapDescriptor.defaultMarker,
        );

        // Adding the markers to the list
        markers.add(startMarker);
        markers.add(destinationMarker);
        print('This is the Start and the end cooordinates');
        print('START COORDINATES: $startCoordinates');
        print('DESTINATION COORDINATES: $destinationCoordinates');

        Position _northeastCoordinates;
        Position _southwestCoordinates;

        // Calculating to check that the position relative
        // to the frame, and pan & zoom the camera accordingly.
        double miny =
            (startCoordinates.latitude <= destinationCoordinates.latitude)
                ? startCoordinates.latitude
                : destinationCoordinates.latitude;
        double minx =
            (startCoordinates.longitude <= destinationCoordinates.longitude)
                ? startCoordinates.longitude
                : destinationCoordinates.longitude;
        double maxy =
            (startCoordinates.latitude <= destinationCoordinates.latitude)
                ? destinationCoordinates.latitude
                : startCoordinates.latitude;
        double maxx =
            (startCoordinates.longitude <= destinationCoordinates.longitude)
                ? destinationCoordinates.longitude
                : startCoordinates.longitude;

        _southwestCoordinates = Position(latitude: miny, longitude: minx);
        _northeastCoordinates = Position(latitude: maxy, longitude: maxx);

        // Accommodate the two locations within the
        // camera view of the map
        mapController.animateCamera(
          CameraUpdate.newLatLngBounds(
            LatLngBounds(
              northeast: LatLng(
                _northeastCoordinates.latitude,
                _northeastCoordinates.longitude,
              ),
              southwest: LatLng(
                _southwestCoordinates.latitude,
                _southwestCoordinates.longitude,
              ),
            ),
            100.0,
          ),
        );

        // Calculating the distance between the start and the end positions
        // with a straight path, without considering any route
        // double distanceInMeters = await Geolocator().bearingBetween(
        //   startCoordinates.latitude,
        //   startCoordinates.longitude,
        //   destinationCoordinates.latitude,
        //   destinationCoordinates.longitude,
        // );

        await _createPolylines(startCoordinates, destinationCoordinates);
        await _createPolylines2(startCoordinates, destinationCoordinates);
        double totalDistance = 0.0;

        // Calculating the total distance by adding the distance
        // between small segments
        if (score1 < score2) {
          print(polylineCoordinates.length - 1);
          print('This is the calculated distance');
          for (int i = 0; i < polylineCoordinates.length - 1; i++) {
            totalDistance += _coordinateDistance(
              polylineCoordinates[i].latitude,
              polylineCoordinates[i].longitude,
              polylineCoordinates[i + 1].latitude,
              polylineCoordinates[i + 1].longitude,
            );
          }
        } else {
          print(polylineCoordinates2.length - 1);
          print('This is the calculated distance');
          for (int i = 0; i < polylineCoordinates2.length - 1; i++) {
            totalDistance += _coordinateDistance(
              polylineCoordinates2[i].latitude,
              polylineCoordinates2[i].longitude,
              polylineCoordinates2[i + 1].latitude,
              polylineCoordinates2[i + 1].longitude,
            );
          }
        }
        setState(() {
          _placeDistance = totalDistance.toStringAsFixed(2);
          print('DISTANCE: $_placeDistance km');
        });

        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  // Formula for calculating distance between two coordinates
  // https://stackoverflow.com/a/54138876/11910277
  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  // Create the polylines for showing the route between two places
  _createPolylines(Position start, Position destination) async {
    // First Path is Build Here
    polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      Secrets.API_KEY, // Google Maps API Key
      PointLatLng(start.latitude, start.longitude),
      PointLatLng(destination.latitude, destination.longitude),
      travelMode: TravelMode.driving,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        for (int i = 0; i < notSafePoints.length - 1; i++) {
          if (double.parse(notSafePoints[i]
                      .latitude
                      .toStringAsFixed(decimalPlacesToCompare)) ==
                  double.parse(
                      point.latitude.toStringAsFixed(decimalPlacesToCompare)) ||
              double.parse(notSafePoints[i]
                      .longitude
                      .toStringAsFixed(decimalPlacesToCompare)) ==
                  double.parse(point.longitude
                      .toStringAsFixed(decimalPlacesToCompare))) {
            score1 += 1;
          }
        }
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print('Path is not calculated properly');
    }

    // PolylineId id = PolylineId('poly');
    // Polyline polyline = Polyline(
    //   polylineId: id,
    //   color: Colors.red,
    //   points: polylineCoordinates,
    //   width: 3,
    // );
    // polylines[id] = polyline;
  }

  _createPolylines2(Position start, Position destination) async {
    // First Path is Build Here
    polylinePoints2 = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      Secrets.API_KEY, // Google Maps API Key
      PointLatLng(start.latitude, start.longitude),
      PointLatLng(destination.latitude, destination.longitude),
      travelMode: TravelMode.bicycling,
      avoidHighways: true,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        for (int i = 0; i < notSafePoints.length - 1; i++) {
          if (double.parse(notSafePoints[i]
                      .latitude
                      .toStringAsFixed(decimalPlacesToCompare)) ==
                  double.parse(
                      point.latitude.toStringAsFixed(decimalPlacesToCompare)) ||
              double.parse(notSafePoints[i]
                      .longitude
                      .toStringAsFixed(decimalPlacesToCompare)) ==
                  double.parse(point.longitude
                      .toStringAsFixed(decimalPlacesToCompare))) {
            score2 += 1;
          }
        }
        polylineCoordinates2.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print('Path is not calculated properly');
    }

    // PolylineId id = PolylineId('poly2');
    // Polyline polyline = Polyline(
    //   polylineId: id,
    //   color: Colors.blue,
    //   points: polylineCoordinates2,
    //   width: 3,
    // );
    // polylines2[id] = polyline;
    print('Both Scores Are Here');
    print(score1);
    print(score2);
    if (score1 < score2) {
      PolylineId id = PolylineId('poly');
      Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.red,
        points: polylineCoordinates,
        width: 3,
      );
      polylines[id] = polyline;
    } else {
      PolylineId id = PolylineId('poly');
      Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.red,
        points: polylineCoordinates2,
        width: 3,
      );
      polylines[id] = polyline;
    }
  }

  @override
  void initState() {
    super.initState();
  }
  void updateLocation() async{
    userDestination=new LatLng(26.852174, 80.938358);
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    // void onButtonPressed() async {
    //   if (_startAddress != '' && _destinationAddress != '') {
    //     startAddressFocusNode.unfocus();
    //     desrinationAddressFocusNode.unfocus();
    //     setState(() {
    //       if (markers.isNotEmpty) markers.clear();
    //       if (polylines.isNotEmpty) polylines.clear();
    //       if (polylineCoordinates.isNotEmpty) polylineCoordinates.clear();
    //       _placeDistance = null;
    //     });

    //     _calculateDistance().then((isCalculated) {
    //       if (isCalculated) {
    //         ScaffoldMessenger.of(context).showSnackBar(
    //           SnackBar(
    //             content: Text('Distance Calculated Sucessfully'),
    //           ),
    //         );
    //       } else {
    //         ScaffoldMessenger.of(context).showSnackBar(
    //           SnackBar(
    //             content: Text('Error Calculating Distance'),
    //           ),
    //         );
    //       }
    //     });
    //   } else {
    //     return null;
    //   }
    // }

    return Container(
      height: height,
      width: width,
      child: Scaffold(
        key: _scaffoldKey,
        body: Stack(
          children: <Widget>[
            // Map View
            GoogleMap(
              markers: markers != null ? Set<Marker>.from(markers) : null,
              initialCameraPosition: _initialLocation,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              mapType: MapType.normal,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: false,
              polylines: Set<Polyline>.of(polylines.values),
              onMapCreated: (GoogleMapController controller) {
                // mapController.complete(controller);
                mapController = controller;
                _getCurrentLocation();
                Timer.periodic(Duration(seconds: 10), (timer) async {
                  updateLocation();
                  _getCurrentLocation();
                });
              },
            ),
            // Show zoom buttons
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ClipOval(
                      child: Material(
                        color: Colors.blue[100], // button color
                        child: InkWell(
                          splashColor: Colors.blue, // inkwell color
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: Icon(Icons.add),
                          ),
                          onTap: () {
                            mapController.animateCamera(
                              CameraUpdate.zoomIn(),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    ClipOval(
                      child: Material(
                        color: Colors.blue[100], // button color
                        child: InkWell(
                          splashColor: Colors.blue, // inkwell color
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: Icon(Icons.remove),
                          ),
                          onTap: () {
                            mapController.animateCamera(
                              CameraUpdate.zoomOut(),
                            );
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            // Show the place input fields & button for
            // showing the route
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.all(
                        Radius.circular(20.0),
                      ),
                    ),
                    width: width * 0.9,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            'Places',
                            style: TextStyle(fontSize: 20.0),
                          ),
                          SizedBox(height: 10),
                          _textField(
                              label: 'Start',
                              hint: 'Choose starting point',
                              prefixIcon: Icon(Icons.looks_one),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.my_location),
                                onPressed: () {
                                  startAddressController.text = _currentAddress;
                                  _startAddress = _currentAddress;
                                },
                              ),
                              controller: startAddressController,
                              focusNode: startAddressFocusNode,
                              width: width,
                              locationCallback: (String value) {
                                setState(() {
                                  _startAddress = value;
                                });
                              }),
                          SizedBox(height: 10),
                          _textField(
                              label: 'Destination',
                              hint: 'Choose destination',
                              prefixIcon: Icon(Icons.looks_two),
                              controller: destinationAddressController,
                              focusNode: desrinationAddressFocusNode,
                              width: width,
                              locationCallback: (String value) {
                                setState(() {
                                  print(value);
                                  _destinationAddress = value;
                                });
                              }),
                          SizedBox(height: 10),
                          Visibility(
                            visible: _placeDistance == null ? false : true,
                            child: Text(
                              'DISTANCE: $_placeDistance km',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: 5),
                          ElevatedButton(
                            onPressed: onButtonPressed,
                            // onPressed: (_startAddress != '' &&
                            //         _destinationAddress != '')
                            //     ? () async {
                            //         startAddressFocusNode.unfocus();
                            //         desrinationAddressFocusNode.unfocus();
                            //         setState(() {
                            //           if (markers.isNotEmpty) markers.clear();
                            //           if (polylines.isNotEmpty)
                            //             polylines.clear();
                            //           if (polylineCoordinates.isNotEmpty)
                            //             polylineCoordinates.clear();
                            //           _placeDistance = null;
                            //         });

                            //         _calculateDistance().then((isCalculated) {
                            //           if (isCalculated) {
                            //             ScaffoldMessenger.of(context)
                            //                 .showSnackBar(
                            //               SnackBar(
                            //                 content: Text(
                            //                     'Distance Calculated Sucessfully'),
                            //               ),
                            //             );
                            //           } else {
                            //             ScaffoldMessenger.of(context)
                            //                 .showSnackBar(
                            //               SnackBar(
                            //                 content: Text(
                            //                     'Error Calculating Distance'),
                            //               ),
                            //             );
                            //           }
                            //         });
                            //       }
                            //     : null,
                            // color: Colors.red,
                            // shape: RoundedRectangleBorder(
                            //   borderRadius: BorderRadius.circular(20.0),
                            // ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Refresh Route',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Show current location button
            SafeArea(
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10.0, bottom: 10.0),
                  child: ClipOval(
                    child: Material(
                      color: Colors.orange[100], // button color
                      child: InkWell(
                        splashColor: Colors.orange, // inkwell color
                        child: SizedBox(
                          width: 56,
                          height: 56,
                          child: Icon(Icons.my_location),
                        ),
                        onTap: () {
                          mapController.animateCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(
                                target: LatLng(
                                  _currentPosition.latitude,
                                  _currentPosition.longitude,
                                ),
                                zoom: 18.0,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
