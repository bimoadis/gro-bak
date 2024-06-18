import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:gro_bak/firebase_options.dart';
import 'package:gro_bak/services/fcm_message.dart';
import 'package:gro_bak/view/test_message.dart';
import 'package:gro_bak/view/pembeli/Pembeli.dart';
import 'package:gro_bak/view/test_message_loc.dart';
import 'package:gro_bak/view/widget/bottom_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  String? userRole = prefs.getString('userRole');

  runApp(MyApp(isLoggedIn: isLoggedIn, userRole: userRole));
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;
  final String? userRole;

  MyApp({required this.isLoggedIn, this.userRole});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    Widget home;
    if (widget.isLoggedIn) {
      if (widget.userRole == "Pedagang") {
        home = BottomNavBar();
      } else if (widget.userRole == "Pembeli") {
        home = Pembeli();
      } else {
        home = LoginPage(); // Fallback if userRole is unknown
      }
    } else {
      home = LoginPage();
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue[900],
      ),
      home: home,
    );
  }
}
