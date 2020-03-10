import 'package:beacon_flutter/ui/LocationTracker.dart';
import 'package:beacon_flutter/ui/PassKeys.dart';
import 'package:beacon_flutter/ui/ShareLocation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';

class Users extends StatefulWidget {
  final String uid;

  Users(this.uid);

  @override
  _UsersState createState() => _UsersState();
}

class _UsersState extends State<Users> {
  final datab = FirebaseDatabase.instance;
  Map data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Beacons'),
        actions: <Widget>[
          GestureDetector(
            child: Icon(Icons.map),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ShareLocation(
                            widget.uid,
                          )));
            },
          )
        ],
      ),
      body: firebaseList(),
      floatingActionButton: FloatingActionButton(
        child: RotatedBox(

          child: Icon(Icons.vpn_key),
          quarterTurns: 1,
        ),
        onPressed: () {

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PassKeys()));
        },
      ),
    );
  }

  Widget contactCard(Map data, String status) {
    return InkWell(
      onTap: () {
        print('Data Passkey ' + data['passkey'] + '\n\n');
        _asyncInputDialog(context, data);
      },
      child: ListTile(
        trailing: CircleAvatar(
          child: data['location'] == 'on'
              ? Icon(
                  Icons.location_on,
                  color: Colors.green,
                )
              : Icon(
                  Icons.location_off,
                  color: Colors.red,
                ),
          backgroundColor: Colors.transparent,
        ),
        leading: CircleAvatar(
          child: Text(data['name'][0].toString().toUpperCase()),
        ),
        title: Text(data['name']),
      ),
    );
  }

  Widget firebaseList() {
    return FirebaseAnimatedList(
        defaultChild: Center(child: CircularProgressIndicator()),
        //Center(child: CircularProgressIndicator()),
        query: datab.reference().child('users/'),
        itemBuilder:
            (_, DataSnapshot snapshot, Animation<double> animation, int index) {
          data = snapshot.value;
          print(data);
          //  print('${data['sender']} ${data['message']}');
          //print(widget.myuid);

          if (data['uid'] == widget.uid) {
            return Container();
          }
          String gid;
          Map myData;

          return contactCard(data, data['status']);
        });
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
            title: Text('PassKey for ${data['name']}'),
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
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                LocationTracker(data['uid'])));
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
