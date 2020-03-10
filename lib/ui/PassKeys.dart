import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PassKeys extends StatefulWidget {
  @override
  _PassKeysState createState() => _PassKeysState();
}

class _PassKeysState extends State<PassKeys> {
  final datab = FirebaseDatabase.instance;
  Map data;
  final key = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      appBar: AppBar(title: Text('PassKeys')),
      body: firebaseList(),
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
          String gid;
          Map myData;

          return ListTile(
            onTap: () async {
              Clipboard.setData(ClipboardData(text: snapshot.value['passkey']));
              key.currentState.showSnackBar(new SnackBar(duration: Duration(milliseconds: 500),
                content: Text("Copied to Clipboard"),
              ));
              ClipboardData clip = await Clipboard.getData('text/plain');
              print(clip.text);
            },
            trailing: Icon(Icons.content_copy),
            title: Text(data['name']),
            subtitle: Text(data['passkey']),
          );
        });
  }

  Widget contactCard(String name, String passKey) {
    return ListTile(
      onTap: () async {
        Clipboard.setData(ClipboardData(text: '${data['passkey']}'));
        key.currentState.showSnackBar(new SnackBar(
          content: Text("Copied to Clipboard"),
        ));
        ClipboardData clip = await Clipboard.getData('text/plain');
        print(clip.text);
      },
      trailing: Icon(Icons.content_copy),
      title: Text(name),
      subtitle: Text(passKey),
    );
  }
}
