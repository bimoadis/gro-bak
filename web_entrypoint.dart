import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gro_bak/services/fcm_message.dart';
import 'package:gro_bak/view/login.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _configureFCM();
    _startSendingNotifications();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _configureFCM() {
    _firebaseMessaging.requestPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a foreground message: ${message.messageId}');
      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked!');
    });
  }

  void _startSendingNotifications() {
    // _timer = Timer.periodic(Duration(seconds: 30), (timer) {
    //   sendFCMMessage();
    // });
  }

  void _handleSignOut(BuildContext context) async {
    try {
      await _auth.signOut();
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginPage()));
    } catch (error) {
      print("Error signing out: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
        automaticallyImplyLeading: false,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.lightBlue[200],
          fontWeight: FontWeight.w800,
          fontSize: 28,
        ),
      ),
      body: Container(
        margin: EdgeInsets.only(left: 160),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // MessageNotifications().sendFCMMessage();
              },
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(Colors.lightBlue[100]),
                foregroundColor: MaterialStatePropertyAll(Colors.white),
              ),
              child: const Text("Send"),
            ),
            ElevatedButton(
              onPressed: () {
                _handleSignOut(context);
              },
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(Colors.lightBlue[100]),
                foregroundColor: MaterialStatePropertyAll(Colors.white),
              ),
              child: const Text("Log Out"),
            ),
          ],
        ),
      ),
    );
  }
}
