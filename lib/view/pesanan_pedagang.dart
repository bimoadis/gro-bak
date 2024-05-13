import 'package:flutter/material.dart';

class OrderPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pedagang"),
        actions: [
          IconButton(
            onPressed: () {
              // logout(context);
            },
            icon: Icon(
              Icons.logout,
            ),
          )
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Order #12345'),
            subtitle: Text('Product: Product A\nQuantity: 2\nTotal: \$50'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Implement onTap action
            },
          ),
          ListTile(
            title: Text('Order #67890'),
            subtitle: Text('Product: Product B\nQuantity: 1\nTotal: \$30'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Implement onTap action
            },
          ),
          // Add more ListTiles for other orders
        ],
      ),
    );
  }
}
