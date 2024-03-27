import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'login.dart';

class Student extends StatefulWidget {
  const Student({super.key});

  @override
  State<Student> createState() => _StudentState();
}

class _StudentState extends State<Student> {
  final user = FirebaseAuth.instance.currentUser;

  //documentID
  List<String> getDocument = [];

  //ger=t DoctId
  Future getDoctId() async {
    await FirebaseFirestore.instance
        .collection('users')
        .get()
        .then((snapshot) => snapshot.docs.forEach((element) {
              print(element.reference);
            }));
  }

  static const LatLng _pGooglePlex =
      LatLng(-7.27562362979344, 112.79377717822462);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pembeli"),
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
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: _pGooglePlex, zoom: 15),
        markers: {
          Marker(
              markerId: MarkerId("_sourceLocation"),
              icon: BitmapDescriptor.defaultMarker,
              position: _pGooglePlex),
        },
      ),
    );
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
}
