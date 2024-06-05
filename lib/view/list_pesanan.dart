import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gro_bak/repository/getOrders.dart';

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
              child: Text('No orders found 123567890.'),
            );
          }

          return ListView(
            children: documents.map((doc) {
              return ListTile(
                title: Text('Product: ${doc['product_name']}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Address: ${doc['address']}'),
                    Text('Delivery Option: ${doc['delivery_option']}'),
                    Text('Notes: ${doc['notes']}'),
                    Text('Price: ${doc['price']}'),
                    Text('Status: ${doc['status']}'),
                    Text('Timestamp: ${doc['timestamp']}'),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
