import 'package:flutter/material.dart';

import '../a.dart';
import 'browser.dart';

void main()=>runApp(MyApp());


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PureBrowser',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          inputDecorationTheme: InputDecorationTheme(
              labelStyle: TextStyle(color: Colors.blue[200]), hintStyle: TextStyle(color: Colors.grey[400]))),
      home: new Browser(),
    );
  }
}
