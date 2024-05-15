import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gro_bak/repository/getAllDataMerchant.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FireStoreServiceAllUser fireStoreServiceUser =
      FireStoreServiceAllUser();
  User? currentUser;
  DocumentSnapshot? userData;
  DocumentSnapshot? merchantData;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (currentUser != null) {
      var userSnapshot =
          await fireStoreServiceUser.getUserByUID(currentUser!.uid);
      var merchantSnapshot =
          await fireStoreServiceUser.getMerchantByUID(currentUser!.uid);
      setState(() {
        userData = userSnapshot;
        merchantData = merchantSnapshot;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gro-bak"),
        actions: [
          IconButton(
            onPressed: () {
              // Tambahkan logika logout di sini
            },
            icon: Icon(
              Icons.logout,
            ),
          )
        ],
      ),
      body: userData == null || merchantData == null
          ? Center(child: CircularProgressIndicator())
          : _buildProfileContent(),
    );
  }

  Widget _buildProfileContent() {
    final userMap = userData!.data() as Map<String, dynamic>;
    final merchantMap = merchantData!.data() as Map<String, dynamic>;

    final email = userMap['email'] ?? 'Unknown';
    final role = userMap['role'] ?? 'Unknown';
    final namaUsaha = merchantMap['nama_usaha'] ?? 'Unknown';
    final nomorTelepon = merchantMap['nomor_telepon'] ?? 'Unknown';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            // You can use a network image or an asset image
            backgroundImage: AssetImage('assets/images/profile-none.jpg'),
            child: Icon(Icons.person, size: 50),
          ),
          SizedBox(height: 20),
          SizedBox(height: 10),
          Text(
            email,
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Role: $role',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'namaUsaha: $namaUsaha',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'telepon: $nomorTelepon',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
