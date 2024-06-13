import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gro_bak/repository/getLongLat.dart';
import 'package:gro_bak/services/fcm_message.dart';

class LocationNotificationScreen extends StatefulWidget {
  @override
  _LocationNotificationScreenState createState() =>
      _LocationNotificationScreenState();
}

class _LocationNotificationScreenState
    extends State<LocationNotificationScreen> {
  Position? _currentPosition;
  Timer? _timer;
  final MessageNotifications _messageNotifications = MessageNotifications();

  @override
  void initState() {
    super.initState();
    _messageNotifications.initNotification();
    _getCurrentLocation();
    _startPeriodicDataLoad();
    // _startSendingNotifications();
  }

  void _startSendingNotifications(String vendorName) {
    _timer = Timer.periodic(Duration(seconds: 40), (timer) {
      _messageNotifications.sendFCMMessage(vendorName);
      print('Sending notification to $vendorName');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startPeriodicDataLoad() {
    _timer = Timer.periodic(Duration(seconds: 15), (timer) async {
      await _getCurrentLocation();
      await _checkNearbyVendors();
      print('Checking nearby vendors...');
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      print('Error: ${e.toString()}');
    }
  }

  Future<void> _checkNearbyVendors() async {
    if (_currentPosition == null) return;

    final double thresholdDistance = 100.0;

    try {
      List<Map<String, dynamic>> merchantData = await readMerchantData();

      for (var merchant in merchantData) {
        double vendorLatitude = merchant['latitude'];
        double vendorLongitude = merchant['longitude'];
        String vendorName = merchant['nama_usaha'];

        double distance = Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          vendorLatitude,
          vendorLongitude,
        );

        if (distance <= thresholdDistance) {
          _startSendingNotifications(vendorName);
        }
      }
    } catch (e) {
      print('Error checking nearby vendors: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vendor Notifications'),
      ),
      body: Center(
        child: _currentPosition != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Current Location:',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Latitude: ${_currentPosition!.latitude}',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Longitude: ${_currentPosition!.longitude}',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              )
            : CircularProgressIndicator(),
      ),
    );
  }
}
