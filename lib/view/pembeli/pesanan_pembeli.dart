import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gro_bak/view/pembeli/pages/locationPick.dart';
import 'package:gro_bak/view/pembeli/pages/location_pick_controller.dart';
import 'package:intl/intl.dart';

class OrderForm extends StatefulWidget {
  final Map<String, dynamic> menu;
  final String uidPedagang;
  final String uidPembeli;
  final String productIndex;

  const OrderForm({
    super.key,
    required this.productIndex,
    required this.menu,
    required this.uidPedagang,
    required this.uidPembeli,
  });

  @override
  _OrderFormState createState() => _OrderFormState();
}

class _OrderFormState extends State<OrderForm> {
  final _formKey = GlobalKey<FormState>();
  String? _address;
  String? _notes;
  String? _namaPembeli;
  String _deliveryOption = 'Jemput';
  int _quantity = 1; // Jumlah awal item
  late num _totalPrice;
  LocationPickController locationPickController =
      Get.put(LocationPickController());

  @override
  void initState() {
    super.initState();
    // Set total harga awal
    _totalPrice = widget.menu['harga'];
    locationPickController.getCurrentLocation();
  }

  Future<void> createOrder(
      String addressFromMaps,
      num latitude,
      num longitude,
      String namaPembeli,
      String productName,
      String productDescription,
      num price,
      String deliveryOption,
      String imageURL,
      String productIndex) async {
    CollectionReference orderRef =
        FirebaseFirestore.instance.collection('orders');
    await orderRef.add({
      'nama_pembeli': namaPembeli,
      'product_name': productName,
      'price': price,
      'imageURL': imageURL,
      'address': _address,
      'address_from_maps': addressFromMaps,
      'latitude': latitude,
      'longitude': longitude,
      'notes': _notes,
      'delivery_option': deliveryOption,
      'user_id': widget.uidPembeli,
      'merch_id': widget.uidPedagang,
      'status': 'Menunggu Konfirmasi',
      'timestamp': Timestamp.now(),
      'productIndex': productIndex,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konfirmasi Pesanan'),
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
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: const [
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
                            child: Image.network(
                              widget.menu['imageURL'],
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${widget.menu['nama_produk']}',
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                NumberFormat.currency(
                                        locale: 'id',
                                        symbol: 'Rp ',
                                        decimalDigits: 0)
                                    .format(widget.menu['harga']),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                              Row(
                                children: [
                                  const Text('Jumlah: '),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        if (_quantity > 1) {
                                          _quantity--;
                                          _totalPrice -= widget.menu['harga'];
                                        }
                                      });
                                    },
                                    icon: const Icon(Icons.remove),
                                  ),
                                  const SizedBox(width: 6.0),
                                  Text('$_quantity'),
                                  const SizedBox(width: 6.0),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _quantity++;
                                        _totalPrice += widget
                                            .menu['harga']; // Tambah harga
                                      });
                                    },
                                    icon: const Icon(Icons.add),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      Divider(color: Colors.grey[300]),
                      Text(
                        '${widget.menu['deskripsi_produk']}',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
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
                                NumberFormat.currency(
                                        locale: 'id',
                                        symbol: 'Rp ',
                                        decimalDigits: 0)
                                    .format(
                                        _totalPrice), // Tampilkan total harga
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
                        decoration:
                            const InputDecoration(labelText: 'Nama Pembeli'),
                        onSaved: (value) {
                          _namaPembeli = value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Mohon masukan nama';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Obx(() {
                        return Column(
                          children: [
                            SizedBox(
                              height: 200,
                              child: GoogleMap(
                                markers: {
                                  Marker(
                                    markerId: const MarkerId('1'),
                                    position: locationPickController
                                        .selectedPosition.value,
                                  ),
                                },
                                myLocationEnabled: true,
                                zoomGesturesEnabled: false,
                                zoomControlsEnabled: false,
                                scrollGesturesEnabled: false,
                                onMapCreated:
                                    locationPickController.onMapCreated,
                                initialCameraPosition: CameraPosition(
                                  target: locationPickController
                                      .selectedPosition.value,
                                  zoom: 18,
                                ),
                                onTap: (argument) => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LocationPick(),
                                  ),
                                ),
                              ),
                            ),
                            Text(
                                'Alamat: ${locationPickController.addressMaps.value}'),
                            const SizedBox(height: 16),
                            TextFormField(
                              decoration: const InputDecoration(
                                  labelText: 'Detail Alamat'),
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
                            const SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              decoration:
                                  const InputDecoration(labelText: 'Catatan'),
                              onSaved: (value) {
                                _notes = value;
                              },
                            ),
                          ],
                        );
                      }),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                            labelText: 'Opsi Pengantaran'),
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
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    ElevatedButton(
                      child: const Text('Pesan'),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          await createOrder(
                              locationPickController.addressMaps.value,
                              locationPickController.latitude.value,
                              locationPickController.longitude.value,
                              _namaPembeli ?? 'null',
                              widget.menu['nama_produk'],
                              widget.menu['deskripsi_produk'],
                              _totalPrice,
                              _deliveryOption,
                              widget.menu['imageURL'],
                              widget.productIndex);
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
