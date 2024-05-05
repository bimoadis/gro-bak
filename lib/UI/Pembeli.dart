import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gro_bak/helpers/gps.dart';
import 'package:gro_bak/service/getLongLat.dart';

import 'login.dart';

class Pembeli extends StatefulWidget {
  const Pembeli({Key? key}) : super(key: key);

  @override
  State<Pembeli> createState() => _PembeliState();
}

class _PembeliState extends State<Pembeli> {
  final user = FirebaseAuth.instance.currentUser;
  final GPS _gps = GPS();
  Position? _userPosition;
  Exception? _exception;

  Completer<GoogleMapController> _controller = Completer();
  List<Marker> _markers = []; // Change to List<Marker>

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
        initialCameraPosition: CameraPosition(
          target: LatLng(-7.27562362979344, 112.79377717822462),
          zoom: 15,
        ),
        markers:
            Set<Marker>.from(_markers), // Set the markers for the GoogleMap
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        myLocationEnabled: true,
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

  @override
  void initState() {
    super.initState();
    _gps.startPositionStream(_handlePositionStream);
    _addMarkersFromFirestore(); // Call directly here
  }

  void _handlePositionStream(Position position) async {
    setState(() {
      _userPosition = position;
    });
    if (_controller.isCompleted) {
      GoogleMapController controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 18,
          ),
        ),
      );
    }
  }

  void _addMarkersFromFirestore() {
    final getLongLat = GetLongLat();
    getLongLat.getUsersStream().listen((List<Map<String, dynamic>> users) {
      print('Received users data from Firestore: $users');
      users.forEach((user) {
        final String fullName = user['fullName'];
        final double latitude = user['latitude'];
        final double longitude = user['longitude'];

        if (latitude != null && longitude != null) {
          bool markerExists =
              _markers.any((marker) => marker.markerId.value == fullName);
          if (!markerExists) {
            setState(() {
              _markers.add(
                Marker(
                  markerId: MarkerId(fullName),
                  position: LatLng(latitude, longitude),
                  onTap: () {
                    _showBottomSheet(fullName);
                  },
                ),
              );
            });
          }
        }
      });
    });
  }

  void _showBottomSheet(String fullName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    fullName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 20),
                  // Add a ListView for scrollable content
                  ListView(
                    shrinkWrap: true,
                    physics:
                        NeverScrollableScrollPhysics(), // Prevent ListView from scrolling
                    children: [
                      Text('Additional information can be displayed here.'),
                    ],
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Close'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
