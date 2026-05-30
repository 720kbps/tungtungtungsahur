import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:zynzynzynsahur/home.dart';
import 'package:zynzynzynsahur/models/signRequest.dart';
import 'app_config.dart';
import './login.dart';
import 'package:zynzynzynsahur/services/zynyo_service.dart';


// Main function that initializes the app and calls runApp.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.validate();

  final zynyo = ZynyoService();
  await zynyo.authenticate();

  runApp(MyApp(zynyoService: zynyo));
}

class MyApp extends StatelessWidget {
  final ZynyoService zynyoService;
  const MyApp({super.key, required this.zynyoService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Login(zynyoService: zynyoService),
    );
  }
}