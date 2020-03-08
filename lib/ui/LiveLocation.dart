import 'dart:async';
import 'dart:typed_data';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class LiveLocation extends StatefulWidget {
  @override
  _LiveLocationState createState() => _LiveLocationState();
}

class _LiveLocationState extends State<LiveLocation> {
  StreamSubscription _locationSubscription;
  Location _locationTracker = Location();
  Marker marker;
  Circle circle;
  double latitude;
  double longitude;
  var _firebaseRef = FirebaseDatabase().reference();
  GoogleMapController _controller;

  static final CameraPosition initialLocation = CameraPosition(
    target: LatLng(12.335642, 76.619103),
    zoom: 14.4746,
  );

//  Future<Uint8List> getMarker() async {
//    ByteData byteData = await DefaultAssetBundle.of(context).load("assets/car_icon.png");
//    return byteData.buffer.asUint8List();
//  }

  void updateMarkerAndCircle(double newLatitude, double newLongitude) {
    LatLng latlng = LatLng(newLatitude, newLongitude);
    //  LatLng latlng = LatLng(12.335642, 76.619103);
    latitude=newLatitude;
    longitude=newLongitude;
    this.setState(() {
      marker = Marker(
        markerId: MarkerId("home"),
        position: latlng,
         rotation: 180,
        draggable: true,
       // zIndex: 2,
        flat: true,
        anchor: Offset(0.5, 0.5),
        //icon: BitmapDescriptor.fromBytes(imageData)
      );
//      circle = Circle(
//          circleId: CircleId("car"),
//          radius: newLocalData.accuracy,
//          zIndex: 1,
//          strokeColor: Colors.blue,
//          center: latlng,
//          fillColor: Colors.blue.withAlpha(70)
//      );
    });
  }

  void getCurrentLocation() async {
    try {
      //Uint8List imageData = await getMarker();
      var location = await _locationTracker.getLocation();
      print("Location Check" + '${location}');
       updateMarkerAndCircle(location.latitude,location.longitude);

      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }

      _locationSubscription =
          _firebaseRef.child('locations/' + 'uid').onValue.listen((event) {
        if (_controller != null) {
          if (event != null) {
            Map locationData = event.snapshot.value;
            latitude = double.parse(locationData['latitude']);
            longitude = double.parse(locationData['longitude']);
            print('Location Data' + '${locationData}' + '\n');
            _controller.animateCamera(CameraUpdate.newCameraPosition(
                new CameraPosition(
                    bearing: 192.8334901395799,
                    target: LatLng(latitude, longitude),
                    tilt: 0,
                    zoom: 13.00)));
            updateMarkerAndCircle(double.parse(locationData['latitude']),
                double.parse(locationData['longitude']));
          }
        }
      });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint("Permission Denied");
      }
    }
  }

  @override
  void dispose() {
    if (_locationSubscription != null) {
      _locationSubscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location Tracker'),
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: initialLocation,
        markers: Set.of((marker != null) ? [marker] : []),
        circles: Set.of((circle != null) ? [circle] : []),
        onMapCreated: (GoogleMapController controller) {
          _controller = controller;
        },
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.location_searching),
          onPressed: () {
            getCurrentLocation();
          }),
    );
  }
}