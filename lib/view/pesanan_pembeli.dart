import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderForm extends StatefulWidget {
  final Map<String, dynamic> menu;
  final String uidPedagang;
  final String uidPembeli;

  const OrderForm({
    Key? key,
    required this.menu,
    required this.uidPedagang,
    required this.uidPembeli,
  }) : super(key: key);

  @override
  _OrderFormState createState() => _OrderFormState();
}

class _OrderFormState extends State<OrderForm> {
  final _formKey = GlobalKey<FormState>();
  String? _address;
  String? _notes;
  String _deliveryOption = 'Jemput';

  Future<void> createOrder(String productName, String productDescription,
      String price, String deliveryOption) async {
    CollectionReference orderRef =
        FirebaseFirestore.instance.collection('orders');
    await orderRef.add({
      'product_name': productName,
      'price': price,
      'address': _address,
      'notes': _notes,
      'delivery_option': deliveryOption,
      'user_id': widget.uidPembeli,
      'merch_id': widget.uidPedagang,
      'status': 'Menunggu Konfirmasi',
      'timestamp': Timestamp.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Konfirmasi Pesanan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Nama Produk: ${widget.menu['nama_produk']}'),
                SizedBox(height: 8),
                Text('Deskripsi: ${widget.menu['deskripsi_produk']}'),
                SizedBox(height: 8),
                Text('Harga: ${widget.menu['harga']}'),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Alamat'),
                  onSaved: (value) {
                    _address = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Mohon masukkan alamat';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Catatan'),
                  onSaved: (value) {
                    _notes = value;
                  },
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Opsi Pengantaran'),
                  value: _deliveryOption,
                  onChanged: (String? newValue) {
                    setState(() {
                      _deliveryOption = newValue!;
                    });
                  },
                  items: <String>['Jemput', 'Antar']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextButton(
                      child: Text('Batal'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    ElevatedButton(
                      child: Text('Pesan'),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          await createOrder(
                            widget.menu['nama_produk'],
                            widget.menu['deskripsi_produk'],
                            widget.menu['harga'],
                            _deliveryOption, // Pass the delivery option
                          );
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Pesanan untuk ${widget.menu['nama_produk']} telah dilakukan.')),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
