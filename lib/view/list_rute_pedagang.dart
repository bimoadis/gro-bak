import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gro_bak/view/add_rute_pedagang.dart';

class ListRutePage extends StatefulWidget {
  @override
  _ListRutePageState createState() => _ListRutePageState();
}

class _ListRutePageState extends State<ListRutePage> {
  final _auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<dynamic> ruteList = [];

  @override
  void initState() {
    super.initState();
    _fetchRute();
  }

  Future<void> _fetchRute() async {
    var user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot docSnapshot =
          await firestore.collection('merchant').doc(user.uid).get();

      if (docSnapshot.exists) {
        setState(() {
          ruteList = docSnapshot['rute'] ?? [];
        });
      } else {
        print('Document does not exist');
      }
    } else {
      print('User is not logged in');
    }
  }

  void _navigateToAddRutePedagang() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddRutePedagang(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List Rute'),
        centerTitle: true,
      ),
      body: ruteList.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Tambahkan Rute ",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              itemCount: ruteList.length,
              itemBuilder: (context, index) {
                var rute = ruteList[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text('Rute Dagang ${index + 1}.'),
                    subtitle: Text(
                      'Alamat : ${rute['address']}\n'
                      'Perkiraan Waktu : ${rute['time']}\n',
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddRutePedagang,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
