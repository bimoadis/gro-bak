import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gro_bak/repository/getLongLat.dart';
import 'package:gro_bak/services/fcm_message.dart';
import 'package:gro_bak/services/gps.dart';
import 'package:gro_bak/view/widget/bottom_sheet.dart';
import 'package:widget_to_marker/widget_to_marker.dart';

class Pembeli extends StatefulWidget {
  const Pembeli({super.key});

  @override
  State<Pembeli> createState() => _PembeliState();
}

class _PembeliState extends State<Pembeli> {
  final user = FirebaseAuth.instance.currentUser;
  final GPS _gps = GPS();
  Position? _userPosition;
  Timer? _timer;
  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  final MessageNotifications _messageNotifications = MessageNotifications();

  final Completer<GoogleMapController> _controller = Completer();
  Future<List<Map<String, dynamic>>>? _combinedDataFuture;
  Set<Marker> _markers = <Marker>{};
  String? _currentAddress;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _gps.startPositionStream(_handlePositionStream);
    _addMarkersFromFirestore();
    _messageNotifications.initNotification();
    _getCurrentLocation();
    _startPeriodicNotification();
    _startPeriodicDataLoad();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade100.withOpacity(0.05),
      body: FutureBuilder(
        future: _getCurrentLocation(),
        builder: (context, snapshot) {
          if (_userPosition != null) {
            return Container(
              clipBehavior: Clip.hardEdge,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    _userPosition!.latitude,
                    _userPosition!.longitude,
                  ),
                  zoom: 15,
                ),
                markers: _markers,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
                myLocationEnabled: true,
                zoomControlsEnabled: false,
                compassEnabled: true,
                myLocationButtonEnabled: true,
                mapToolbarEnabled: false,
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  void _startSendingNotifications(String vendorName) {
    _messageNotifications.sendFCMMessage(vendorName);
  }

  void _startPeriodicDataLoad() {
    _timer = Timer.periodic(const Duration(seconds: 20), (timer) {
      _addMarkersFromFirestore();
      print('update data pedagng');
    });
  }

  void _startPeriodicNotification() {
    _timer = Timer.periodic(const Duration(seconds: 20), (timer) async {
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
      if (_controller.isCompleted && _userPosition != null) {
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

    _combinedDataFuture!.then((combinedData) async {
      Set<Marker> markers = <Marker>{};
      for (var data in combinedData) {
        if (data['latitude'] != null && data['longitude'] != null) {
          print('data: $data');
          try {
            LatLng position = LatLng(data['latitude'], data['longitude']);
            markers.add(
              Marker(
                infoWindow: InfoWindow(
                  title: data['nama_usaha'],
                  snippet: data['nama'],
                ),
                markerId: MarkerId(position.toString()),
                icon: await CustomMarker(data: data).toBitmapDescriptor(
                    logicalSize: const Size(150, 50),
                    imageSize: const Size(400, 200)),
                position: position,
                onTap: () {
                  _showBottomSheet(
                    data['profileImage'],
                    data['nama_usaha'],
                    data['nama'],
                    data['rute'],
                    data['menu'],
                    data['latitude'],
                    data['longitude'],
                    data['uid'],
                    user!.uid,
                    data['ratings'].cast<Map<String, dynamic>>(),
                    data['rute'].cast<Map<String, dynamic>>(),
                    data['phone_number'],
                  );
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
    String imageProfile,
    String nameMerchant,
    String name,
    List<dynamic> seluruhRute,
    List<dynamic> menu,
    double latitude,
    double longitude,
    String uidPedagang,
    String uidPembeli,
    List<Map<String, dynamic>> ratings,
    List<Map<String, dynamic>> rute,
    String phone_number,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return BottomSheetWidget(
          currentUserPosition: _userPosition!,
          phone_number: phone_number,
          rute: rute,
          ratings: ratings,
          imageURL: imageProfile,
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

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
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
          break;
        }
      }
    } catch (e) {
      print('Error checking nearby vendors: $e');
    }
  }
}

class CustomMarker extends StatelessWidget {
  const CustomMarker({
    super.key,
    required this.data,
  });

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.shopping_cart,
          color: Colors.orange.shade800,
        ),
        const SizedBox(
          height: 2,
        ),
        SizedBox(
          width: 200,
          child: Text(
            data['nama_usaha'],
            maxLines: 2,
            style: const TextStyle(
              color: Colors.black,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}
