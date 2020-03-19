import 'package:beacon_flutter/ui/ShareLocation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:location/location.dart';
import 'package:random_string/random_string.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Map data;
  String code;
  final databaseInstance = FirebaseDatabase.instance;
  DateTime _dateTime;
  DateTime expiringAt;
  LocationData currentLocation;
  String uid;
  TextEditingController nameController=TextEditingController();
  List<String> timeDuration = ['15 minutes', '30 minutes' , '1 hour', '3 hour']; // Option 2
  String selectedTime; //
  @override
  void initState() {
    super.initState();

    getMyLcoation();
  }

  void getMyLcoation() async {
    try {
      var location = new Location();
      currentLocation = await location.getLocation();
      print('Got the Location $currentLocation \n\n');
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        // error = 'Permission denied';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body: Column(
        children: <Widget>[
          RaisedButton(
            onPressed: () {
              choiceDialog(context);
            },
            child: Text('Create Beacon'),
          ),
          RaisedButton(
            onPressed: () {
              // _asyncInputDialog(context)
            },
            child: Text('Follow A Beacon'),
          ),
        ],
      ),
    );
  }

  Future<String> choiceDialog(BuildContext context) async {
    String passKey = '';
    bool validateKey = false;

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
                    child: TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: 'Enter your Name',
                        errorText:
                            validateKey ? "Please enter your name" : null,
                      ),
                     controller: nameController,
                    ),
                  ),
                  Container(
                    height: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Text(
                      'Select Expiration Time',
                      //  style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  Container(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal:24.0),
                    child: DropdownButton(
                      hint: Text('Please choose a Time'), // Not necessary for Option 1
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
//                  Flexible(
//                    flex: 3,
//                    child: TimePickerSpinner(
//                      is24HourMode: false,
//                      normalTextStyle:
//                          TextStyle(fontSize: 24, color: Colors.black12),
//                      highlightedTextStyle:
//                          TextStyle(fontSize: 24, color: Colors.black),
//                      spacing: 30,
//                      itemHeight: 60,
//                      isForce2Digits: true,
//                      onTimeChange: (time) {
//                        setState(() {
//                          _dateTime = time;
//                        });
//                      },
//                    ),
//                  ),
                  SizedBox(
                    height: 20,
                  ),
                  InkWell(
                    onTap: () {

                       code=randomAlphaNumeric(10);
                       if( selectedTime=='15 minutes')
                        expiringAt=DateTime.now().add(Duration(minutes:15));
                       else if( selectedTime=='30 minutes')
                         expiringAt=DateTime.now().add(Duration(minutes:30));
                       else if( selectedTime=='1 hour')
                         expiringAt=DateTime.now().add(Duration(hours:1));
                       else
                         expiringAt=DateTime.now().add(Duration(hours:3));
                        data={
                         'name':'${nameController.text}',
                          'latitude':'${currentLocation.latitude}',
                          'longitude':'${currentLocation.longitude}',
                          'startAt':'${DateTime.now()}',
                          'expiringAt':'$expiringAt'
                       };
                        print(data);
                      databaseInstance
                          .reference()
                          .child('locations/' + code)
                          .set(data)
                          .catchError((e) {
                        print('Error at Storing value ' + e + '\n\n');
                      });
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ShareLocation(
                                  code,
                                  currentLocation.latitude,
                                  currentLocation.longitude,DateTime.now(),expiringAt)));
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(32.0),
                            bottomRight: Radius.circular(32.0)),
                      ),
                      child: Text(
                        "Create a Beacon",
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
      },
    );
  }
}

Future<String> _asyncInputDialog(BuildContext context, Map data) async {
  String passKey = '';
  bool validateKey = false;

  return showDialog<String>(
    context: context,
    // barrierDismissible: false, // dialog is dismissible with a tap on the barrier
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            //  title: Text('PassKey for ${data['name']}'),
            content: new Row(
              children: <Widget>[
                new Expanded(
                    child: new TextField(
                  autofocus: true,
                  decoration: new InputDecoration(
                    labelText: 'Enter the PassKey',
                    hintText: 'e.g. 34ZK2',
                    errorText: validateKey ? "Incorrect PassKey" : null,
                  ),
                  onChanged: (value) {
                    passKey = value;
                  },
                ))
              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () {
                  print('PassKey from Database ${data['passkey']}');
                  if (passKey == data['passkey']) {
                    Navigator.of(context).pop(passKey);
//                    Navigator.push(
//                        context,
//                        MaterialPageRoute(
//                            builder: (context) =>
//                                LocationTracker(data['uid'])));
                  } else {
                    validateKey = true;
                    setState(() {});
                  }
                },
              ),
            ],
          );
        },
      );
    },
  );
}
