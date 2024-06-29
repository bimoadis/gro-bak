import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gro_bak/services/gps.dart';
import 'package:gro_bak/services/logout.dart';
import 'package:gro_bak/repository/getOrders.dart';
import 'package:gro_bak/view/pedagang/detail_pesanan.dart';
import 'package:intl/intl.dart';

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
  late StreamSubscription<List<DocumentSnapshot>> _ordersSubscription;
  List<DocumentSnapshot> _menungguKonfirmasiOrders = [];
  List<DocumentSnapshot> _dikonfirmasiOrders = [];
  // List<DocumentSnapshot> _allOrders = [];

  void _handlePositionStream(Position position) {
    setState(() {
      _userPosition = position;
    });
  }

  @override
  void initState() {
    super.initState();
    _gps.startPositionStream(_handlePositionStream);

    _ordersSubscription = _firestoreService.getOrders().listen((orders) {
      setState(() {
        _menungguKonfirmasiOrders = orders
            .where((order) =>
                (order.data() as Map<String, dynamic>)['status'] ==
                'Menunggu Konfirmasi')
            .toList();
        _dikonfirmasiOrders = orders
            .where((order) =>
                (order.data() as Map<String, dynamic>)['status'] ==
                'Dikonfirmasi')
            .toList();
      });
    });
    startTimer();
  }

  @override
  void dispose() {
    _ordersSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.amber.shade100.withOpacity(0.1),
        appBar: AppBar(
          backgroundColor: Colors.amber.shade100.withOpacity(0.3),
          title: const Text(
            "Gro-bak",
            style: TextStyle(
              fontSize: 32,
              color: Color(0xFFFEC901),
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  offset: Offset(1.0, 1.0),
                  blurRadius: 1.0,
                  color: Color(0xFF060100),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                AuthService.logout(context);
              },
              icon: const Icon(
                Icons.logout,
              ),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: "Pesanan Masuk"),
              Tab(text: "Dikonfirmasi"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOrderList(_menungguKonfirmasiOrders, 'Menunggu Konfirmasi'),
            _buildOrderList(_dikonfirmasiOrders, 'Dikonfirmasi'),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(List<DocumentSnapshot> orders, String status) {
    if (orders.isEmpty) {
      return const Center(child: Text('No orders found'));
    }
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          var order = orders[index];
          var data = order.data() as Map<String, dynamic>;
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Container(
                          constraints: const BoxConstraints(maxHeight: 130),
                          child: Image.network(
                            data['imageURL'],
                            width: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data['product_name'] ?? 'No Name'),
                            Text(
                              'Deskripsi: ${data['notes']}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            Text(
                              'Pembeli: ${data['nama_pembeli']}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            Text(
                              NumberFormat.currency(
                                      locale: 'id',
                                      symbol: 'Rp ',
                                      decimalDigits: 0)
                                  .format(data['price']),
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 10),
                            if (status == 'Menunggu Konfirmasi')
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => DetailPesanan(
                                              order: data,
                                            ),
                                          ));
                                    },
                                    child: const Text('Detail'),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                            255, 233, 253, 234)),
                                    onPressed: () {
                                      _updateOrderStatus(
                                          order.id, 'Dikonfirmasi');
                                    },
                                    child: const Text('Konfirmasi'),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
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
    Timer.periodic(const Duration(seconds: 20), (timer) {
      postDetailsToFirestore(
          _userPosition?.latitude ?? 0.0, _userPosition?.longitude ?? 0.0);
    });
  }

  Future<void> _updateOrderStatus(String orderId, String status) async {
    await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'status': status,
    });
  }
}
