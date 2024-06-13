import 'dart:async';
import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:gro_bak/services/fcm_message.dart';
import 'package:gro_bak/view/login.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  final MessageNotifications _messageNotifications = MessageNotifications();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _messageNotifications.initNotification();
    _startSendingNotifications();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startSendingNotifications() {
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      // _messageNotifications.sendFCMMessage();
    });
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
                // _messageNotifications.sendFCMMessage();
              },
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(Colors.lightBlue[100]),
                foregroundColor: MaterialStateProperty.all(Colors.white),
              ),
              child: const Text("Send"),
            ),
          ],
        ),
      ),
    );
  }
}
