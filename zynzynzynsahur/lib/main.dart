import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:zynzynzynsahur/home.dart';
import 'app_config.dart';
import './login.dart';


// Main function that initializes the app and calls runApp.
void main() {
  //AppConfig.validate();
  runApp(MyApp());
}

// Root widget of the application.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Disables the debug banner.
      home: Login(),
    );
  }
}