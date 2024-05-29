import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gro_bak/helpers/gps.dart';
import 'package:gro_bak/repository/getLongLat.dart';
import 'package:gro_bak/view/rute_pedagang.dart';

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
  Timer? _timer;

  Completer<GoogleMapController> _controller = Completer();
  Future<List<Map<String, dynamic>>>? _combinedDataFuture;
  Set<Marker> _markers = Set<Marker>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Gro-bak",
          style: TextStyle(
            fontSize: 32,
            color: Color(0xFFFEC901),
            fontWeight: FontWeight.bold,
            shadows: [
              const Shadow(
                offset: Offset(1.0, 1.0), // position of the shadow
                blurRadius: 1.0, // blur effect
                color: Color(0xFF060100), // semi-transparent black color
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              logout(context);
            },
            icon: Icon(
              Icons.logout,
              color: Color(0xFF060100),
            ),
          )
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(-7.27562362979344, 112.79377717822462),
          zoom: 15,
        ),
        markers: Set<Marker>.from(_markers),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        myLocationEnabled: true,
        zoomControlsEnabled: false,
        compassEnabled: false,
        myLocationButtonEnabled: false,
        mapToolbarEnabled: false,
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
    _addMarkersFromFirestore();
    // _startPeriodicDataLoad();
  }

  void _handlePositionStream(Position position) async {
    if (_userPosition == null ||
        _calculateDistance(_userPosition!, position) >= 10) {
      setState(() {
        _userPosition = position;
      });
      if (_controller.isCompleted) {
        if (_userPosition != null) {
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
    }
  }

  double _calculateDistance(Position pos1, Position pos2) {
    return Geolocator.distanceBetween(
      pos1.latitude,
      pos1.longitude,
      pos2.latitude,
      pos2.longitude,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startPeriodicDataLoad() {
    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      _addMarkersFromFirestore();
    });
  }

  void _addMarkersFromFirestore() {
    setState(() {
      _combinedDataFuture = readMerchantData();
    });

    _combinedDataFuture!.then((combinedData) {
      Set<Marker> markers = Set<Marker>();
      for (var data in combinedData) {
        if (data['latitude'] != '' && data['longitude'] != '') {
          print(combinedData);
          try {
            LatLng position = LatLng(data['latitude'], data['longitude']);
            markers.add(
              Marker(
                markerId: MarkerId(data['email']),
                position: position,
                onTap: () {
                  _showBottomSheet(
                      data['nama_usaha'],
                      data['nama'],
                      data['rute'],
                      data['latitude'],
                      data['longitude'],
                      data['uid']);
                },
              ),
            );
          } catch (e) {
            print('Error parsing latitude/longitude: $e');
          }
        }
      }
      setState(() {
        _markers = markers;
      });
    });
  }

  void _showBottomSheet(
      String nameMerchant,
      String name,
      List<dynamic> seluruhRute,
      double latitude,
      double longitude,
      String uid) {
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Detail Pedagang',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Card(
                        child: Container(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.asset(
                              'assets/images/bakso.jpeg',
                              width: 120,
                              height: 90,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Text(
                                nameMerchant,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20,
                                ),
                              ),
                              Text(
                                name,
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Spacer(), // Add Spacer here
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => RutePedagang(
                                                seluruhRute: seluruhRute,
                                                namaPemilik: name,
                                                namaUsaha: nameMerchant,
                                                uid: uid),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFFFEC901),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16.0),
                                        ),
                                        elevation: 0,
                                        shadowColor: Colors.transparent,
                                      ),
                                      child: Text(
                                        'Track',
                                        style: TextStyle(
                                          color: Color(0xFF060100),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
