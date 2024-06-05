import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gro_bak/view/pesanan_pembeli.dart';

class ListMenuPesanan extends StatefulWidget {
  final List<dynamic> menu;
  final String uidPedagang;
  final String uidPembeli;

  const ListMenuPesanan({
    Key? key,
    required this.menu,
    required this.uidPedagang,
    required this.uidPembeli,
  }) : super(key: key);

  @override
  _ListMenuPesananState createState() => _ListMenuPesananState();
}

class _ListMenuPesananState extends State<ListMenuPesanan> {
  final _auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<dynamic> menuList = [];

  @override
  void initState() {
    super.initState();
    // Ambil menu dari properti menu yang dilewatkan
    menuList = widget.menu;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List Menu'),
        centerTitle: true,
      ),
      body: menuList.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: menuList.length,
                itemBuilder: (context, index) {
                  var menu = menuList[index];
                  return Card(
                    margin: EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.asset(
                                  'assets/images/bakso.jpeg',
                                  width: 120,
                                  height: 90,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(menu['nama_produk'] ?? 'No Name'),
                                    Text(
                                      'Deskripsi: ${menu['deskripsi_produk']}',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                    Text(
                                      'Harga: ${menu['harga']}',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                    SizedBox(height: 10),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => OrderForm(
                                              menu: menu,
                                              uidPedagang: widget.uidPedagang,
                                              uidPembeli: widget.uidPembeli,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Text('Pesan'),
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
            ),
    );
  }
}
