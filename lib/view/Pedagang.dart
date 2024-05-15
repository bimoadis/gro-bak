import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gro_bak/helpers/gps.dart';
import 'package:gro_bak/view/widget/bottom_bar.dart';
import 'login.dart';

class Pedagang extends StatefulWidget {
  const Pedagang({Key? key}) : super(key: key);

  @override
  State<Pedagang> createState() => _PedagangState();
}

class _PedagangState extends State<Pedagang> {
  final _auth = FirebaseAuth.instance;
  final GPS _gps = GPS();
  Position? _userPosition;
  int _selectedIndex = 0;

  void _handlePositionStream(Position position) {
    setState(() {
      _userPosition = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gro-bak"),
        actions: [
          IconButton(
            onPressed: () {
              logout(context);
            },
            icon: Icon(
              Icons.logout,
            ),
          )
        ],
      ),
      body: Center(),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> logout(BuildContext context) async {
    CircularProgressIndicator();
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
  }

  Future<void> postDetailsToFirestore(double latitude, double longitude) async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    var user = _auth.currentUser;
    if (user != null) {
      CollectionReference ref = FirebaseFirestore.instance.collection('users');
      ref.doc(user.uid).update({
        'latitude': _userPosition?.latitude,
        'longitude': _userPosition?.longitude,
      });
      print('Full Name: $_userPosition,');
    }
  }

  @override
  void initState() {
    super.initState();
    _gps.startPositionStream(_handlePositionStream);
    startTimer(); // Memanggil fungsi startTimer saat initState dipanggil
  }

  void startTimer() {
    Timer.periodic(Duration(seconds: 30), (timer) {
      postDetailsToFirestore(
          _userPosition?.latitude ?? 0.0, _userPosition?.longitude ?? 0.0);
    });
  }
}
