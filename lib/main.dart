import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:gro_bak/firebase_options.dart';
import 'package:gro_bak/services/fcm_message.dart';
import 'package:gro_bak/view/test_message.dart';
import 'package:gro_bak/view/pembeli/Pembeli.dart';
import 'package:gro_bak/view/test_message_loc.dart';
import 'package:gro_bak/view/widget/bottom_bar.dart';
import 'firebase_options.dart';
import 'view/login.dart';
import 'view/pedagang/Pedagang.dart';
import 'package:gro_bak/services/gps.dart';
import 'package:flutter/material.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await MessageNotifications().initNotification();
  await GPS();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue[900],
      ),
      home: LoginPage(),
      // home: Pembeli(),
      // home: BottomNavBar(),
      // home: HomePage(),
      // home: LocationNotificationScreen(),
    );
  }
}
