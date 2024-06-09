import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gro_bak/view/pedagang/add_menu_pedagang.dart';

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
        builder: (context) => AddMenuPedagang(),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddMenuPage,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
