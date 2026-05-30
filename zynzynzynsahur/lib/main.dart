import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:zynzynzynsahur/home.dart';
import 'app_config.dart';
import './login.dart';
import 'package:zynzynzynsahur/services/zynyo_service.dart';


// Main function that initializes the app and calls runApp.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.validate();
  // Initialize the service and authenticate
  final zynyo = ZynyoService();
  await zynyo.authenticate();

  runApp(MyApp());

  //api tests
  await zynyo.getDocumentCount();
}

// Root widget of the application.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Disables the debug banner.
      home: HomePage(),
    );
  }
}