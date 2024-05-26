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
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: ruteList.length,
              itemBuilder: (context, index) {
                var rute = ruteList[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(rute['name'] ?? 'No Name'),
                    subtitle: Text(
                        'Address: ${rute['address']}\nLatitude: ${rute['latitude']}\nLongitude: ${rute['longitude']}'),
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
