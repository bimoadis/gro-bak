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
  int _quantity = 1; // Jumlah awal item
  late int _totalPrice;

  @override
  void initState() {
    super.initState();
    // Set total harga awal
    _totalPrice = int.parse(widget.menu['harga']);
  }

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
                Container(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6.0,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.asset(
                              'assets/images/bakso.jpeg',
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 16.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${widget.menu['nama_produk']}',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4.0),
                              Text(
                                'Harga: Rp.${widget.menu['harga']}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                              Row(
                                children: [
                                  Text('Jumlah: '),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        if (_quantity > 1) {
                                          _quantity--;
                                          _totalPrice -=
                                              int.parse(widget.menu['harga']);
                                        }
                                      });
                                    },
                                    icon: Icon(Icons.remove),
                                  ),
                                  SizedBox(width: 6.0),
                                  Text('$_quantity'),
                                  SizedBox(width: 6.0),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _quantity++;
                                        _totalPrice += int.parse(widget
                                            .menu['harga']); // Tambah harga
                                      });
                                    },
                                    icon: Icon(Icons.add),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 8.0),
                      Divider(color: Colors.grey[300]),
                      Text(
                        '${widget.menu['deskripsi_produk']}',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Harga:',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Rp. $_totalPrice', // Tampilkan total harga
                                style: TextStyle(
                                  color: Colors.green[500],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
                        decoration:
                            InputDecoration(labelText: 'Opsi Pengantaran'),
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
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    ElevatedButton(
                      child: Text('Pesan'),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          await createOrder(
                            widget.menu['nama_produk'],
                            widget.menu['deskripsi_produk'],
                            widget.menu['harga'].toString(),
                            _deliveryOption, // Pass the delivery option
                          );
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Pesanan untuk ${widget.menu['nama_produk']} telah dilakukan.',
                              ),
                            ),
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
