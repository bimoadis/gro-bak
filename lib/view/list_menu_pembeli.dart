import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gro_bak/view/add_menu_pedagang.dart';

class ListMenuPesanan extends StatefulWidget {
  final List<dynamic> menu;
  final String uid;

  const ListMenuPesanan({
    Key? key,
    required this.menu,
    required this.uid,
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
          : ListView.builder(
              itemCount: menuList.length,
              itemBuilder: (context, index) {
                var menu = menuList[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(menu['nama_produk'] ?? 'No Name'),
                    subtitle: Text(
                      'Deskripsi: ${menu['deskripsi_produk']}\nHarga: ${menu['harga']}',
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }
}
