import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gro_bak/helpers/gps.dart';
import 'package:gro_bak/repository/getOrders.dart';
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
  final FirestoreService _firestoreService = FirestoreService();
  late final Stream<List<DocumentSnapshot>> _ordersStream;

  void _handlePositionStream(Position position) {
    setState(() {
      _userPosition = position;
    });
  }

  @override
  void initState() {
    super.initState();
    _gps.startPositionStream(_handlePositionStream);
    _ordersStream = _firestoreService.getOrders();
    // startTimer(); // Start the timer to post location periodically
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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Selamat Datang di Gro-bak",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "Silahkan pilih menu yang ingin anda lakukan",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Expanded(
                child: StreamBuilder<List<DocumentSnapshot>>(
                  stream: _ordersStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Text('No orders found');
                    }
                    List<DocumentSnapshot> orders = snapshot.data!;
                    return ListView.builder(
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        var order = orders[index];
                        var data = order.data() as Map<String, dynamic>;
                        return ListTile(
                          title: Text('Order ID: ${order.id}'),
                          subtitle: Text(
                              'Details: ${data['details'] ?? 'No details'}'),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> logout(BuildContext context) async {
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
      print('Updated user location: $_userPosition');
    }
  }

  void startTimer() {
    Timer.periodic(Duration(seconds: 10), (timer) {
      postDetailsToFirestore(
          _userPosition?.latitude ?? 0.0, _userPosition?.longitude ?? 0.0);
    });
  }
}
