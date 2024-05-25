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
    final userMap = userData?.data() as Map<String, dynamic>? ?? {};
    final merchantMap = merchantData?.data() as Map<String, dynamic>? ?? {};

    final email = userMap['email'] ?? 'Unknown';
    final role = userMap['role'] ?? 'Unknown';
    final namaUsaha = merchantMap['nama_usaha'] ?? 'Unknown';
    final nomorTelepon = merchantMap['nomor_telepon'] ?? 'Unknown';

    return Scaffold(
      appBar: AppBar(
        title: Text("Gro-bak"),
        actions: [
          IconButton(
            onPressed: () {
              // Tambahkan logika logout di sini
            },
            icon: Icon(Icons.logout),
          )
        ],
      ),
      body: userData == null || merchantData == null
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 100),
                  CircleAvatar(
                    radius: 50,
                    // You can use a network image or an asset image
                    backgroundImage:
                        AssetImage('assets/images/profile-none.jpg'),
                    child: Icon(Icons.person, size: 50),
                  ),
                  SizedBox(height: 20),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 40),
                  buildProfileRow(Icons.work, role),
                  SizedBox(height: 30),
                  buildProfileRow(Icons.business, namaUsaha),
                  SizedBox(height: 30),
                  buildProfileRow(Icons.phone, nomorTelepon),
                  SizedBox(height: 30),
                  buildProfileRow(
                      Icons.add_location_alt_outlined, 'Rute Dagang'),
                ],
              ),
            ),
    );
  }

  Widget buildProfileRow(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(icon),
          SizedBox(width: 20),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
