import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class MessageNotifications {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Function(RemoteMessage message, bool inForeground)? onMessageReceived;

  Future<void> initNotification() async {
    // Request permission to receive notifications
    await _firebaseMessaging.requestPermission();

    // Get the FCM token
    final fCMToken = await _firebaseMessaging.getToken();

    print('token: $fCMToken');

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleMessage(message, inForeground: true);
    });

    // Handle messages when the app is opened from a background state
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessage(message, inForeground: false);
    });

    // Handle messages when the app is launched from a terminated state
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        _handleMessage(message, inForeground: false);
      }
    });
  }

  void _handleMessage(RemoteMessage message, {required bool inForeground}) {
    if (inForeground) {
      // Show a dialog or a Snackbar
      _showMessageDialog(message);
    } else {
      // Navigate to a specific screen
      _navigateToScreen(message);
    }
  }

  void _showMessageDialog(RemoteMessage message) {
    // Implement your logic to show a dialog or Snackbar
    print('Message received in foreground: ${message.notification?.title}');
  }

  void _navigateToScreen(RemoteMessage message) {
    // Implement your logic to navigate to a specific screen
    print('Message clicked with data: ${message.data}');
  }

  Future initPushNotifications() async {
    // This function is now redundant, initialization is done in initNotification
    await initNotification();
  }

  Future whenNotificationReceived(BuildContext context) async {
    // Implement any additional logic when notification is received, if needed
  }

  Future<String> getAccessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "gro-bak",
      "private_key_id": "1a86b9764d82956f8c566808c40fb1cf4c70581a",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQCBvcl2zwABV6oH\nmHkrSZq0+6kC8G942+cpe6bsdNUlwaYGKHK3GsHEUQn2hNltvEQ1Eg7jqF2f8Y6L\nF20WnjjCVFVZQLWixosgRdwWWTXNut1eZFbsqO53x6hs/BQ8rtMyYhyhQK74g0Xl\nb5HyMmGikILnKXcXY6eTf6fgm75mnDCReTkmStTheaxxADSv3dLZPdOne8L7aYyb\nFbewIfR6BmVi/Wnlupls1zNALnhOzGcqThcAzjRcgGt3nYSPckvBig3wn3oIcuUE\ns5u6EnvjPgxWeRgkZcwKVlHxq8Bc2mymtFwAlJKv07ggv8V/gVWlw/bq3kVx8aUq\nEbvnAuJnAgMBAAECggEAI0lbgHlHTpYps/wnxHq13ZBuxNJg9xWUFwe+/CPAjw7O\nmXEp1hwsZDkIRSiXvE1OncKGEywJHsXDl5fs/xBUbqIiPm6nmBh44XOuqtNjm0s+\nBvyyWZaOmTxP1ihvVpvT7CmcEM13aTbG7WJ9ZsqGHIFCYR25er6LZsX7Ak9Jpz1j\no50p7Pi7dLbLeTqD95J02fCPDXkvC03j98hfRGerHkRGdSyMThC4CQMwLvD+A6pa\n081SUUg8eE8Rkd5sqSNuvrP6/i7wLe2eCa1r36v3JBmIkiWcwUgvDkJ4R4TAug6c\nJRGjbG09Fbj+zageDTSRZI3sjM1z5W+KdD1ywmPleQKBgQC2znZ5+eUIKwWjDOIw\n4iREEZpBUceBEhYZ3+QjBWKaBuxLebOTCYBR0Gfb5nANdi/zTXmz1U0W6saKw8Wm\nSVmuqAAyB5HVvD2fJKHNJUDKx2KGBkoJKhf1XCmnBmvCGf4wjfCt3iwZ0SxmEKKM\nJOKuCd518blvLEnuyaYZc4SELwKBgQC1sC9E6azv26BZRgr3uxrzA/gJQPgEsUc4\n08qUw3dBJO4DV3uVUQVrAr3BnXHpB9fiOiOZxhPM3xC8N1KUNO6R4YIUPJ0mwlcu\nxsrmV6NiKJgmHLxQDCZoy6rA2auMcWr6cb3dFWwbCqw5krfsj8IkdykVecWvKHjQ\nZaKmMeCfSQKBgQCNrtNwklgKzp1d1BxzWrJU93eg7Ks9xDDQ+RAufHwBeSAnFzow\n2gpUXrxAWQe7x0A+yGttEALhojEjV7yWtv8FOTx9ihRjnbP85j1pbFgdUg9wZOt4\n0uEiz72QsI9QLyktpLVHbIytrctFh9sT13rA/PEoZKMeIStkIXHVBA1PDQKBgQCC\nbmEAz+BesQSEEkx9W80U+JxvyDxE4h+HJEQiV9Cc664SqBMINon1MJqZDDZiXEcX\nGTXFhvVf9iNFe1HFI9rAz2taq8kFsi50XjH6+p9IMGxJsAdgT9ijEtMabylAQYvT\nDySGOoLJRvgsvK9dHDb7hq/vwuOvwxY4RT5moRfoQQKBgQCIYj8/wgr+Q4rKfd2t\npoJ67G5IBTPqryXOyWXTslW/3fgdxZQ1vhOg9qVTEHmguPToKPV1fsyu01R8eL8B\njz3K8lzyj3KM0G5XtuSctw3gmKtutltnz58h0ENAL+PmaJHD79ckEek9cR4lgGXU\nPUsYnucpLiNF9WNUMbRBDXrEtQ==\n-----END PRIVATE KEY-----\n",
      "client_email": "firebase-adminsdk-t4iaz@gro-bak.iam.gserviceaccount.com",
      "client_id": "101176758637701479017",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-t4iaz%40gro-bak.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

    auth.AccessCredentials credentials =
        await auth.obtainAccessCredentialsViaServiceAccount(
            auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
            scopes,
            client);

    var accountCredentials =
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson);
    var authClient =
        await auth.clientViaServiceAccount(accountCredentials, scopes);

    // Dapatkan token akses
    var accessToken = (await authClient.credentials).accessToken.data;
    // print('Akses Token: $accessToken');
    authClient.close();
    return accessToken;
  }

  Future<void> sendFCMMessage(String vendorName) async {
    final String serverKey = await getAccessToken();
    final String fcmEndpoint =
        'https://fcm.googleapis.com/v1/projects/gro-bak/messages:send';
    final currentFCMToken = await FirebaseMessaging.instance.getToken();

    final Map<String, dynamic> message = {
      'message': {
        'token': currentFCMToken,
        'notification': {
          'body': '$vendorName berada di sekitar anda coba cek menunya!',
          'title': 'Lihat Pedagang Sekitar'
        },
        'data': {
          'current_user_fcm_token': currentFCMToken,
        },
      }
    };

    final http.Response response = await http.post(
      Uri.parse(fcmEndpoint),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverKey',
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      print('FCM message sent successfully');
    } else {
      print('Failed to send FCM message: ${response.statusCode}');
    }
    print("Message: $message");
  }
}
