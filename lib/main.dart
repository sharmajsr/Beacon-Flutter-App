import 'package:beacon_flutter/ui/Dashboard.dart';
import 'package:beacon_flutter/ui/Login.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Color(0xff1A1B41),
        //primarySwatch: Colors.blue,
      ),
      home: Dashboard(),
    );
  }
}
