import 'dart:async';
import 'dart:typed_data';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/rendering.dart';
import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

final FirebaseDatabase database = FirebaseDatabase.instance;

class _DashboardState extends State<Dashboard> {
  GoogleMapController _controller;
  Marker marker;
  Circle circle;
  double latitude = 12.9716;
  double longitude = 77.5946;
  Map<String, double> currentLocation;
  StreamSubscription<LocationData> locationSubscription;
  Location location = new Location();

  @override
  void initState() {
    super.initState();
//    currentLocation['latitude'] = 12.311212399999999;
//    currentLocation['longitude'] = 76.61367419999999;
//    initPlatformState();
//    locationSubscription =
//        location.onLocationChanged();
   // getMyLocationData();
  }

  void getMyLocationData() async {
    var currentLocation = LocationData;

    var location = new Location();

// Platform messages may fail, so we use a try/catch PlatformException.
    try {
      var location = new Location();
      var currentLocation = await location.getLocation();
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        // error = 'Permission denied';
      }
      currentLocation = null;
    }
    locationSubscription=location.onLocationChanged().listen((LocationData currentLocation) {
      print("Latitude : ${currentLocation.latitude} \n Longitude : ${currentLocation.longitude}");
      longitude = currentLocation.longitude;
      latitude = currentLocation.latitude;
      Map data = {
        "timestamp": "${DateTime.now()}",
        "latitude": "$latitude",
        "longitude": "$longitude"
      };
      database
          .reference()
          .child("locations/" + 'uid')
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
                  target: LatLng(latitude, longitude),
                  zoom: 10,
                ),
//                markers: Set.of((marker != null) ? [marker] : []),
//                circles: Set.of((circle != null) ? [circle] : []),
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
//                  database
//                      .reference()
//                      .child("complaints/")
//                      .set(data)
//                      .catchError((e) {
//                    print('ERROR ho gya $e\n\n');
//                  });

                },
                child: Text('Share my Location'),
              ),
              RaisedButton(
                textColor: Colors.white,
                color: Colors.red,
                onPressed: () {
                  print('Location Subscription Cancelled');
                  locationSubscription.cancel();

                },
                child: Text('Stop Sharing'),
              ),
            ],
          )
        ],
      ),
    );
  }
}

//
//class LocationTracker extends StatefulWidget {
//
//  @override
//  _LocationTrackerState createState() => _LocationTrackerState();
//}
//
//class _LocationTrackerState extends State<LocationTracker> {
//  StreamSubscription _locationSubscription;
//  Location _locationTracker = Location();
//  Marker marker;
//  Circle circle;
//  GoogleMapController _controller;
//
//  static final CameraPosition initialLocation = CameraPosition(
//    target: LatLng(12.335642, 76.619103),
//    zoom: 14.4746,
//  );
//
//  Future<Uint8List> getMarker() async {
//    ByteData byteData = await DefaultAssetBundle.of(context).load("assets/car_icon.png");
//    return byteData.buffer.asUint8List();
//  }
//
//  void updateMarkerAndCircle(LocationData newLocalData, Uint8List imageData) {
//    LatLng latlng = LatLng(newLocalData.latitude, newLocalData.longitude);
//    //  LatLng latlng = LatLng(12.335642, 76.619103);
//    this.setState(() {
//      marker = Marker(
//
//          markerId: MarkerId("home"),
//          position: latlng,
//          rotation: newLocalData.heading,
//          draggable: true,
//          zIndex: 2,
//          flat: true,
//          anchor: Offset(0.5, 0.5),
//          icon: BitmapDescriptor.fromBytes(imageData));
//      circle = Circle(
//          circleId: CircleId("car"),
//          radius: newLocalData.accuracy,
//          zIndex: 1,
//          strokeColor: Colors.blue,
//          center: latlng,
//          fillColor: Colors.blue.withAlpha(70));
//    });
//  }
//
//  void getCurrentLocation() async {
//    try {
//
//      Uint8List imageData = await getMarker();
//      var location = await _locationTracker.getLocation();
//
//      updateMarkerAndCircle(location, imageData);
//
//      if (_locationSubscription != null) {
//        _locationSubscription.cancel();
//      }
//
//
//      _locationSubscription = _locationTracker.onLocationChanged().listen((newLocalData) {
//        if (_controller != null) {
//          _controller.animateCamera(CameraUpdate.newCameraPosition(new CameraPosition(
//              bearing: 192.8334901395799,
//              target:  LatLng(newLocalData.latitude, newLocalData.longitude),
//              tilt: 0,
//              zoom: 14.00)));
//          updateMarkerAndCircle(newLocalData, imageData);
//        }
//      });
//
//    } on PlatformException catch (e) {
//      if (e.code == 'PERMISSION_DENIED') {
//        debugPrint("Permission Denied");
//      }
//    }
//  }
//
//  @override
//  void dispose() {
//    if (_locationSubscription != null) {
//      _locationSubscription.cancel();
//    }
//    super.dispose();
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
////      appBar: AppBar(
////        title: Text('Location Tracking'),
////      ),
//      body: GoogleMap(
//        mapType: MapType.normal,
//        initialCameraPosition: initialLocation,
//        markers: Set.of((marker != null) ? [marker] : []),
//        circles: Set.of((circle != null) ? [circle] : []),
//        onMapCreated: (GoogleMapController controller) {
//          _controller = controller;
//        },
//
//      ),
//      floatingActionButton: FloatingActionButton(
//          child: Icon(Icons.location_searching),
//          onPressed: () {
//            getCurrentLocation();
//          }),
//    );
//  }
//}
