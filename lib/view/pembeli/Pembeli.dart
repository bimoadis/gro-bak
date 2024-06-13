import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gro_bak/repository/getLongLat.dart';
import 'package:gro_bak/services/fcm_message.dart';
import 'package:gro_bak/services/gps.dart';
import 'package:gro_bak/services/logout.dart';
import 'package:gro_bak/view/pembeli/list_menu_pembeli.dart';
import 'package:gro_bak/view/pembeli/list_pesanan.dart';
import 'package:gro_bak/view/pembeli/rute_pedagang.dart';
import 'package:gro_bak/view/widget/bottom_sheet.dart';
import '../login.dart';

class Pembeli extends StatefulWidget {
  const Pembeli({Key? key}) : super(key: key);

  @override
  State<Pembeli> createState() => _PembeliState();
}

class _PembeliState extends State<Pembeli> {
  final user = FirebaseAuth.instance.currentUser;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GPS _gps = GPS();
  Position? _userPosition;
  Exception? _exception;
  Timer? _timer;
  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  // Position? _currentPosition;
  // User? _currentUser;
  final MessageNotifications _messageNotifications = MessageNotifications();

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
    _messageNotifications.initNotification();
    _getCurrentLocation();
    _startPeriodicNotification();

    _startPeriodicDataLoad();
  }

  void _startSendingNotifications(String vendorName) {
    // _timer = Timer.periodic(Duration(seconds: 10), (timer) {
    _messageNotifications.sendFCMMessage(vendorName);
    print(' haloo ini bnjdbfenfceb');
    // });
  }

  void _startPeriodicDataLoad() {
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      _addMarkersFromFirestore();
      print('update data pedagng');
    });
  }

  void _startPeriodicNotification() {
    _timer = Timer.periodic(Duration(seconds: 10), (timer) async {
      await _getCurrentLocation();
      await _checkNearbyVendors();
      print('Checking nearby vendors...');
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

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      setState(() {
        _userPosition = position;
      });
    } catch (e) {
      print('Error: ${e.toString()}');
    }
  }

  Future<void> _checkNearbyVendors() async {
    if (_userPosition == null) return;

    final double thresholdDistance = 100.0;

    // Get the current user

    try {
      List<Map<String, dynamic>> merchantData = await readMerchantData();

      for (var merchant in merchantData) {
        double vendorLatitude = merchant['latitude'];
        double vendorLongitude = merchant['longitude'];
        String vendorName = merchant['nama_usaha'];

        double distance = Geolocator.distanceBetween(
          _userPosition!.latitude,
          _userPosition!.longitude,
          vendorLatitude,
          vendorLongitude,
        );

        if (distance <= thresholdDistance) {
          _startSendingNotifications(vendorName);
          break; // Send notification for the first nearby vendor found
        }
      }
    } catch (e) {
      print('Error checking nearby vendors: $e');
    }
  }
}
