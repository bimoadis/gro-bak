import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gro_bak/view/widget/bottom_bar.dart';

class MenuPedagang extends StatefulWidget {
  @override
  State<MenuPedagang> createState() => _MenuPedagangState();
}

class _MenuPedagangState extends State<MenuPedagang> {
  final _auth = FirebaseAuth.instance;

  final TextEditingController _namaProductController = TextEditingController();
  final TextEditingController _detailProductController =
      TextEditingController();
  final TextEditingController _hargaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambahkan Menu'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _namaProductController,
                decoration: InputDecoration(
                  hintText: 'Nama Produk',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _detailProductController,
                decoration: InputDecoration(
                  hintText: 'Detail Produk',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _hargaController,
                decoration: InputDecoration(
                  hintText: 'Harga',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveMenu,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFEC901),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  'Simpan Menu',
                  style: TextStyle(
                    color: Color(0xFF060100),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveMenu() async {
    if (_namaProductController.text.isEmpty ||
        _detailProductController.text.isEmpty ||
        _hargaController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please fill all fields')));
      return;
    }

    String nama = _namaProductController.text;
    try {
      if (nama.isNotEmpty) {
        FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
        var user = _auth.currentUser;
        if (user != null) {
          CollectionReference ref =
              FirebaseFirestore.instance.collection('merchant');
          DocumentSnapshot docSnapshot = await ref.doc(user.uid).get();

          List<dynamic> rute = docSnapshot['menu'] ?? [];

          rute.add({
            "nama_produk": _namaProductController.text,
            "deskripsi_produk": _detailProductController.text,
            "harga": _hargaController.text,
            "foto_produk": '',
          });

          await ref.doc(user.uid).update({'menu': rute});
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => BottomNavBar(),
            ),
            (Route<dynamic> route) =>
                false, // Menghapus semua halaman sebelumnya
          );
        } else {
          print('User is not logged in');
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('User is not logged in')));
        }
      } else {
        print('Failed to find location for the address');
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to find location')));
      }
    } catch (e) {
      print('Failed to save address: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to save address')));
    }
  }
}
