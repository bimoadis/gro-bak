import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gro_bak/view/add_menu_pedagang.dart';

class ListMenuPage extends StatefulWidget {
  @override
  _ListMenuPageState createState() => _ListMenuPageState();
}

class _ListMenuPageState extends State<ListMenuPage> {
  final _auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<dynamic> menuList = [];

  @override
  void initState() {
    super.initState();
    _fetchMenu();
  }

  Future<void> _fetchMenu() async {
    var user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot docSnapshot =
          await firestore.collection('merchant').doc(user.uid).get();

      if (docSnapshot.exists) {
        setState(() {
          menuList = docSnapshot['menu'] ?? [];
        });
      } else {
        print('Document does not exist');
      }
    } else {
      print('User is not logged in');
    }
  }

  void _navigateToAddMenuPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MenuPedagang(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List Menu'),
        centerTitle: true,
      ),
      body: menuList.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    Text(
                      "Tambahkan Menu ",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ])),
            )
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
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddMenuPage,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
