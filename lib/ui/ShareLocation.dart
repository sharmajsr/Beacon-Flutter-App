import 'dart:async';
import 'package:beacon_flutter/ui/LocationTracker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/rendering.dart';
import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:random_string/random_string.dart';

class ShareLocation extends StatefulWidget {
  final String uid;
  double latitude;
  double longitude;

  ShareLocation(this.uid, this.latitude, this.longitude);

  @override
  _ShareLocationState createState() => _ShareLocationState();
}

final FirebaseDatabase database = FirebaseDatabase.instance;

class _ShareLocationState extends State<ShareLocation> {
  final datab = FirebaseDatabase.instance;
  String generatedCode = '';
  bool showPassKey = false;
  GoogleMapController _controller;
  Marker marker;
  Circle circle;
  Map updateData;
  double latitude = 12.9716;
  double longitude = 77.5946;
  Map<String, double> currentLocation;
  StreamSubscription<LocationData> locationSubscription;
  Location location = new Location();
  Map myData;

  @override
  void initState() {
    super.initState();
    getMyData();
  }

  Future<String> getMyData() async {
    myData = (await FirebaseDatabase.instance
            .reference()
            .child("users/" + widget.uid)
            .once())
        .value;
  }

  void getMyLocationData() async {
    var currentLocation = LocationData;
    var location = new Location();
    try {
      var location = new Location();
      var currentLocation = await location.getLocation();
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        // error = 'Permission denied';
      }
      currentLocation = null;
    }
    locationSubscription =
        location.onLocationChanged().listen((LocationData currentLocation) {
      print(
          "Latitude : ${currentLocation.latitude} \n Longitude : ${currentLocation.longitude}");
      longitude = currentLocation.longitude;
      latitude = currentLocation.latitude;
      Map data = {
        "timestamp": "${DateTime.now()}",
        "latitude": "$latitude",
        "longitude": "$longitude"
      };
      database
          .reference()
          .child("locations/" + widget.uid)
          .set(data)
          .catchError((e) {
        print(e);
      });
      setState(() {
        print('Latitude $latitude\nLongitude $longitude');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Beacon'),
        leading: GestureDetector(
          child: Icon(Icons.keyboard_backspace),
          onTap: () {
            //locationSubscription.pause();
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: <Widget>[
          Card(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 2,
              child: GoogleMap(
                myLocationEnabled: true,
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                  target: LatLng(widget.latitude, widget.longitude),
                  zoom: 13,
                ),
                onMapCreated: (GoogleMapController controller) {
                  _controller = controller;
                },
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                textColor: Colors.white,
                color: Colors.green,
                onPressed: () {
                  getMyLocationData();
                  showPassKey = true;
                  generatedCode = randomAlphaNumeric(10);
                  updateData = {
                    "name": "${myData['name']}",
                    "email": "${myData['email']}",
                    "location": "on",
                    "uid": "${myData['uid']}",
                    "passkey": "$generatedCode",
                    "location": "on"
                  };
                  datab
                      .reference()
                      .child('users/' + widget.uid)
                      .set(updateData)
                      .catchError((e) {
                    print('Error at Storing value ' + e + '\n\n');
                  });
                },
                child: Text('Share my Location'),
              ),
              RaisedButton(
                textColor: Colors.white,
                color: Colors.red,
                onPressed: () {
                  locationSubscription.pause();
                  showPassKey = false;
                  print('Location Subscription Paused');

                  generatedCode = randomAlphaNumeric(10);
                  updateData = {
                    "name": "${myData['name']}",
                    "email": "${myData['email']}",
                    "location": "on",
                    "uid": "${myData['uid']}",
                    "passkey": "$generatedCode",
                    "location": "off"
                  };
                  datab
                      .reference()
                      .child('users/' + widget.uid)
                      .set(updateData)
                      .catchError((e) {
                    print('Error at Storing value ' + e + '\n\n');
                  });
                },
                child: Text('Stop Sharing'),
              ),
            ],
          ),
          showPassKey == true ? Text('PassKey :  $generatedCode') : Container(),
        ],
      ),
    );
  }
}
