import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gro_bak/services/gps.dart';
import 'package:gro_bak/services/logout.dart';
import 'package:gro_bak/repository/getLongLat.dart';
import 'package:gro_bak/view/pembeli/list_menu_pembeli.dart';
import 'package:gro_bak/view/pembeli/list_pesanan.dart';
import 'package:gro_bak/view/widget/bottom_sheet.dart';

import '../login.dart';

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
  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrdersPage(),
                ),
              );
            },
            icon: Icon(
              Icons.shopping_bag,
              color: Color(0xFF060100),
            ),
          ),
          IconButton(
            onPressed: () {
              AuthService.logout(context);
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

  @override
  void initState() {
    super.initState();
    _gps.startPositionStream(_handlePositionStream);
    setCustomMarkerIcon();
    _addMarkersFromFirestore();
    _setupFirebaseMessaging();

    // _startPeriodicDataLoad();
  }

  void _setupFirebaseMessaging() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(notification.title ?? 'No Title'),
            content: Text(notification.body ?? 'No Body'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      // Handle the notification opening event here
    });

    _firebaseMessaging.subscribeToTopic("merchant_nearby");
  }

  void _startPeriodicLocationCheck() {
    _timer = Timer.periodic(Duration(seconds: 10), (timer) async {
      if (_userPosition != null) {
        await _checkNearbyMerchants();
      }
    });
  }

  Future<void> _checkNearbyMerchants() async {
    List<Map<String, dynamic>> merchants = await readMerchantData();
    for (var merchant in merchants) {
      if (merchant['latitude'] != '' && merchant['longitude'] != '') {
        double distance = Geolocator.distanceBetween(
          _userPosition!.latitude,
          _userPosition!.longitude,
          merchant['latitude'],
          merchant['longitude'],
        );
        if (distance <= 100) {
          _sendNotification(merchant['nama_usaha'], merchant['nama']);
        }
      }
    }
  }

  void _sendNotification(String title, String body) {
    // Logic to send a notification to the topic "merchant_nearby" should be implemented on the server side.
    // Here we are just subscribing to the topic and handling incoming notifications.
  }

  void _startPeriodicDataLoad() {
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      _addMarkersFromFirestore();
    });
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

  void _addMarkersFromFirestore() {
    setState(() {
      _combinedDataFuture = readMerchantData();
    });

    _combinedDataFuture!.then((combinedData) {
      Set<Marker> markers = Set<Marker>();
      for (var data in combinedData) {
        if (data['latitude'] != '' && data['longitude'] != '') {
          try {
            LatLng position = LatLng(data['latitude'], data['longitude']);
            markers.add(
              Marker(
                markerId: MarkerId(data['email']),
                icon: sourceIcon, // Use the custom icon here
                position: position,
                onTap: () {
                  _showBottomSheet(
                      data['nama_usaha'],
                      data['nama'],
                      data['rute'],
                      data['menu'],
                      data['latitude'],
                      data['longitude'],
                      data['uid'],
                      user!.uid);
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
      List<dynamic> menu,
      double latitude,
      double longitude,
      String uidPedagang,
      String uidPembeli) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return BottomSheetWidget(
          nameMerchant: nameMerchant,
          name: name,
          seluruhRute: seluruhRute,
          menu: menu,
          latitude: latitude,
          longitude: longitude,
          uidPedagang: uidPedagang,
          uidPembeli: uidPembeli,
        );
      },
    );
  }

  void setCustomMarkerIcon() async {
    final ByteData data =
        await rootBundle.load("assets/images/shopping_cart.png");
    final ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: 100, // Set a slightly larger width
      targetHeight: 100, // Set a slightly larger height
    );
    final ui.FrameInfo fi = await codec.getNextFrame();

    final ByteData? resizedData =
        await fi.image.toByteData(format: ui.ImageByteFormat.png);
    if (resizedData != null) {
      final Uint8List resizedBytes = resizedData.buffer.asUint8List();
      setState(() {
        sourceIcon = BitmapDescriptor.fromBytes(resizedBytes);
      });
    }
  }
}
