import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class MessageNotifications {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotification() async {
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    print('FCM Token: $fCMToken');
  }

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;

    // navigatorKey.currentState?.pushNamed('/');
  }

  Future initPushNotifications() async {
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessage.listen(handleMessage);
  }

  Future whenNitoficationReceived(BuildContext context) async {}
}
