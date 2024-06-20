import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gro_bak/view/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static Future<void> logout(BuildContext context) async {
    const CircularProgressIndicator();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
  }
}
