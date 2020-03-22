import 'dart:async';
import 'package:beacon_flutter/ui/LocationTracker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share/share.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:random_string/random_string.dart';

class ShareLocation extends StatefulWidget {
  final String uid;
  double latitude;
  double longitude;
  DateTime startAt;
  DateTime expiringAt;
  final int type; // 0 - sharing location , 1 - fetching location
  String name;
  var _firebaseRef = FirebaseDatabase().reference();
  ShareLocation(this.uid, this.latitude, this.longitude, this.startAt,
      this.expiringAt, this.type,this.name);

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
  StreamSubscription<LocationData> locationSubscription; //location sender
  StreamSubscription _locationSubscription; //Location Listener
  var _firebaseRef = FirebaseDatabase().reference();
  Location _locationTracker = Location();
  Location location = new Location();
  Map myData,checkData;

  final databaseInstance = FirebaseDatabase.instance;
  DateTime newExpiringAt;
  List<String> timeDuration = [
    '15 minutes',
    '30 minutes',
    '1 hour',
    '3 hour'
  ]; // Option 2
  String selectedTime;

  @override
  void initState() {
    super.initState();
    // getMyData();
    if(widget.type==0)
      sendCurrentLocation();
    else
      getCurrentLocation();
  }

  void updateMarkerAndCircle(double newLatitude, double newLongitude) {
    LatLng latlng = LatLng(newLatitude, newLongitude);
    //  LatLng latlng = LatLng(12.335642, 76.619103);
    latitude = newLatitude;
    longitude = newLongitude;
    this.setState(() {
      marker = Marker(
        markerId: MarkerId("home"),
        position: latlng,
        //  rotation: 180,
        draggable: true,
        // zIndex: 2,
        flat: true,
        anchor: Offset(0.5, 0.5),
        //icon: BitmapDescriptor.fromBytes(imageData)
      );
    });
  }

  void getCurrentLocation() async {
    try {
      //Uint8List imageData = await getMarker();
      var location = await _locationTracker.getLocation();
      print("Location Check" + '${location}');
      updateMarkerAndCircle(location.latitude, location.longitude);

      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }

      _locationSubscription =
          _firebaseRef.child('locations/' + widget.uid).onValue.listen((event) {
        if (_controller != null) {
          if (event != null) {
            Map locationData = event.snapshot.value;
            latitude = double.parse(locationData['latitude']);
            longitude = double.parse(locationData['longitude']);
            print('Location Data' + '${locationData}' + '\n');
            _controller.animateCamera(
                CameraUpdate.newCameraPosition(new CameraPosition(
                    //    bearing: 192.8334901395799,
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

  Future<String> getMyData() async {
    myData = (await FirebaseDatabase.instance
            .reference()
            .child("users/" + widget.uid)
            .once())
        .value;
  }

  Future<String> changeExpirationTime(BuildContext context) async {
    return showDialog<String>(
        context: context,
        // barrierDismissible: false, // dialog is dismissible with a tap on the barrier
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32.0))),
                contentPadding: EdgeInsets.only(top: 20.0),
                //  title: Text('PassKey for ${data['name']}'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Text(
                        'Add Duration ',
                        //  style: TextStyle(color: Colors.blue),
                      ),
                    ),
                    Container(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: DropdownButton(
                        value: selectedTime,
                        onChanged: (newValue) {
                          setState(() {
                            selectedTime = newValue;
                          });
                        },
                        items: timeDuration.map((location) {
                          return DropdownMenuItem(
                            child: new Text(location),
                            value: location,
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    InkWell(
                      onTap: () {
                        if (selectedTime == '15 minutes')
                          newExpiringAt =
                              widget.expiringAt.add(Duration(minutes: 15));
                        else if (selectedTime == '30 minutes')
                          newExpiringAt =
                              widget.expiringAt.add(Duration(minutes: 30));
                        else if (selectedTime == '1 hour')
                          newExpiringAt =
                              widget.expiringAt.add(Duration(hours: 1));
                        else
                          newExpiringAt =
                              widget.expiringAt.add(Duration(hours: 3));
                        widget.expiringAt = newExpiringAt;
                        databaseInstance
                            .reference()
                            .child('locations/' + widget.uid)
                            .update({
                          'expiringAt': '$newExpiringAt'
                        }).catchError((e) {
                          print('Error at Storing value ' + e + '\n\n');
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                        decoration: BoxDecoration(
                          color: Color(0xff6290c3),
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(32.0),
                              bottomRight: Radius.circular(32.0)),
                        ),
                        child: Text(
                          "Add Duration",
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        });
  }

  void sendCurrentLocation() async {
    var currentLocation = LocationData;
    var location = new Location();
    try {
      var location = new Location();
      var currentLocation = await location.getLocation();
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED')
      {
        // error = 'Permission denied';
      }
      currentLocation = null;
    }
    locationSubscription =
        location.onLocationChanged().listen((LocationData currentLocation) {
      print("Latitude:${currentLocation.latitude}\nLongitude:${currentLocation.longitude}");

      longitude = currentLocation.longitude;
      latitude = currentLocation.latitude;

      database.reference().child("locations/" + widget.uid).update(
          {"latitude": "$latitude", "longitude": "$longitude"}).catchError((e) {
        print(e);
      });
      setState(() {
//        if (widget.expiringAt.isBefore(DateTime.now())) {
//          print('Location Subscription apaused');
//          stopLocationUpdates();
//        }
//        print('Latitude $latitude Longitude $longitude');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double ht = MediaQuery.of(context).size.height;
    double wt = MediaQuery.of(context).size.width;
    return
      StreamBuilder<Event>(
      stream: _firebaseRef.child('groups/' + widget.uid+'/'+ widget.name).onValue ,
      builder:(BuildContext context, AsyncSnapshot<Event> event) {
        if (event.hasData) {
          checkData = event.data.snapshot.value;
          print(checkData);
          print('^^\n\n');
          try {
            if (checkData['sharing'] == '1') {

              sendCurrentLocation();

            }
          }catch(e)
        {
          print('error is '+ e);
        }
        }
        return SafeArea(
          child: Scaffold(
            floatingActionButton: FloatingActionButton(
              backgroundColor: Color(0xff172130),
              onPressed: stopLocationUpdates,
              child: Icon(
                Icons.location_off,
                color: Color(0xffa9eee6),
              ),
            ),
            endDrawer: Drawer(
                child: FirebaseAnimatedList(
                    defaultChild: Center(child: CircularProgressIndicator()),
                    //Center(child: CircularProgressIndicator()),
                    query: datab.reference().child('groups/' + widget.uid),
                    itemBuilder: (_, DataSnapshot snapshot,
                        Animation<double> animation, int index) {
                      return ListTile(
                        onLongPress: () {
                          stopLocationUpdates();
                          datab.reference().child('groups/' + widget.uid+'/'+ widget.name).update({"sharing":"1"});
                        },
                        title: Text(snapshot.value['name']),
                      );
                    })),
            appBar: AppBar(
              //automaticallyImplyLeading: false,
              title: Text('Beacon'),
              actions: <Widget>[
                InkWell(
                  child: Icon(Icons.person_add),
                  onTap: () {
                    Share.share('Follow me using the code ${widget.uid}');
                  },
                )
              ],
            ),
            body: Stack(
              children: <Widget>[
                Card(
                  child: Container(
                    width: wt,
                    height: ht,
                    child: GoogleMap(
                      myLocationEnabled: widget.type == 0+0 ?true:false,
                      mapType: MapType.normal,
                      markers: Set.of((marker != null) ? [marker] : []),
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
//          Row(
//            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//            crossAxisAlignment: CrossAxisAlignment.center,
//            children: <Widget>[
//              RaisedButton(
//                textColor: Colors.white,
//                color: Colors.green,
//                onPressed: sendLocationUpdates,
//                child: Text('Share my Location'),
//              ),
//              RaisedButton(
//                textColor: Colors.white,
//                color: Colors.red,
//                onPressed:stopLocationUpdates,
//                child: Text('Stop Sharing'),
//              ),
//            ],
//          ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: wt,
                    height: 100,
                    child: Card(
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Text(
                                  'Expiring At ${widget.expiringAt.toString().substring(11, 19)} '),
                              Spacer(),
                              RaisedButton(
                                onPressed: () {
                                  changeExpirationTime(context);
                                  setState(() {});
                                },
                                child: Icon(
                                  Icons.edit,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ),
        );
//      }
//        else
//          return Center(child: CircularProgressIndicator());
      }

    );
  }

//  sendLocationUpdates() {
//    getMyLocationData();
//    showPassKey = true;
//  }

  stopLocationUpdates() {
    locationSubscription.pause();
    showPassKey = false;
    print('Location Subscription Paused');
    database
        .reference()
        .child("locations/" + widget.uid)
        .update({"latitude": "0.0", "longitude": "0.0"}).catchError((e) {
      print(e);
    });
  }
}
