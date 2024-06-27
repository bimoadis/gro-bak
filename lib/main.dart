import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:gro_bak/firebase_options.dart';
import 'package:gro_bak/services/fcm_message.dart';
import 'package:gro_bak/view/pembeli/pages/Pembeli.dart';
import 'package:gro_bak/view/pembeli/pages/page_switcher.dart';
import 'package:gro_bak/view/widget/bottom_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'view/login.dart';
import 'package:gro_bak/services/gps.dart';

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   // await Firebase.initializeApp();
//   print("Handling a background message: ${message.messageId}");
// }

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  // Log the message details
  print("Handling a background message: ${message.messageId}");

  if (message.notification != null) {
    print("Title: ${message.notification!.title}");
    print("Body: ${message.notification!.body}");
  }

  // Handle data message
  if (message.data.isNotEmpty) {
    print("Data: ${message.data}");
    // Handle data message. For example, you can save the data to local storage, show a local notification, etc.
  }
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

  const MyApp({required this.isLoggedIn, this.userRole});

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
        home = const PageSwitcherPembeli();
      } else {
        home = LoginPage(); // Fallback if userRole is unknown
      }
    } else {
      home = LoginPage();
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // primaryColor: Colors.blue[900],
      ),
      home: home,
    );
  }
}
