import 'package:flutter/material.dart';
import 'package:gro_bak/view/widget/card_widget.dart';
import 'package:intl/intl.dart';
import 'package:gro_bak/repository/getOrders.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrdersPage extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders'),
      ),
      body: StreamBuilder<List<DocumentSnapshot>>(
        stream: _firestoreService.getOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          List<DocumentSnapshot>? documents = snapshot.data;

          if (documents == null || documents.isEmpty) {
            return Center(
              child: Text('No orders found.'),
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: documents.map((doc) {
                  // Format tanggal menjadi string
                  String formattedDate = DateFormat('d MMMM yyyy')
                      .format(doc['timestamp'].toDate());

                  return CardHistory(
                    productName: doc['product_name'],
                    timestamp: formattedDate,
                    deliveryOption: doc['delivery_option'],
                    imageUrl: 'assets/images/bakso.jpeg',
                    price: doc['price'].toString(),
                    status: doc['status'],
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
