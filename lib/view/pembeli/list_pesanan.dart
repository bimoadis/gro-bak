import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gro_bak/view/widget/card_widget.dart';
import 'package:intl/intl.dart';
import 'package:gro_bak/repository/getOrders.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrdersPage extends StatefulWidget {
  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final FirestoreService _firestoreService = FirestoreService();
  List<DocumentSnapshot> _menungguKonfirmasiOrders = [];
  List<DocumentSnapshot> _dikonfirmasiOrders = [];
  late StreamSubscription<List<DocumentSnapshot>> _ordersSubscription;

  @override
  void initState() {
    super.initState();
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
        appBar: AppBar(
          title: Text('Orders'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Menunggu Konfirmasi'),
              Tab(text: 'Dikonfirmasi'),
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
      return Center(child: Text('No orders found'));
    }
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          var order = orders[index];
          var data = order.data() as Map<String, dynamic>;

          // Format tanggal menjadi string
          String formattedDate =
              DateFormat('d MMMM yyyy').format(data['timestamp'].toDate());

          return CardHistory(
            productName: data['product_name'],
            timestamp: formattedDate,
            deliveryOption: data['delivery_option'],
            imageUrl: 'assets/images/bakso.jpeg',
            price: data['price'].toString(),
            status: data['status'],
          );
        },
      ),
    );
  }
}
