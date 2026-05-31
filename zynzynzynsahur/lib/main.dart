import 'package:flutter/material.dart';
import 'app_config.dart';
import './login.dart';
import 'package:zynzynzynsahur/services/zynyo_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:zynzynzynsahur/services/notif.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  AppConfig.validate();

  final zynyo = ZynyoService();
  await zynyo.authenticate();
  
  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.startPolling(zynyo);
  print("Startup complete, launching app");


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