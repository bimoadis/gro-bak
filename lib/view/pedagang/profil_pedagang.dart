import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gro_bak/repository/getAllDataMerchant.dart';
import 'package:gro_bak/view/pedagang/list_rute_pedagang.dart';
import '../login.dart';

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
      ),
      body: userData == null || merchantData == null
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 50),
                  CircleAvatar(
                    radius: 50,
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
                  SizedBox(height: 20),
                  buildProfileRow(Icons.work, role),
                  SizedBox(height: 10),
                  buildProfileRow(Icons.business, namaUsaha),
                  SizedBox(height: 10),
                  buildProfileRow(Icons.phone, nomorTelepon),
                  SizedBox(height: 10),
                  buildRuteDagangButton(
                      context), // Modified button for "Rute Dagang"
                  SizedBox(height: 10),
                  buildLogoutButton(context), // Added logout button
                ],
              ),
            ),
    );
  }

  Widget buildProfileRow(IconData icon, String value, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          alignment: Alignment.centerLeft,
        ),
        child: Row(
          children: [
            Icon(icon),
            SizedBox(width: 20),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                decoration: onTap != null
                    ? TextDecoration.underline
                    : TextDecoration.none,
                color: onTap != null ? Colors.blue : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRuteDagangButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ListRutePage()),
          );
        },
        child: Container(
          width: double.infinity,
          height: 45,
          decoration: BoxDecoration(
            color: Color(0xFFFEC901),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              "Rute Dagang",
              style: TextStyle(
                color: Color(0xFF060100),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: GestureDetector(
        onTap: () {
          _showLogoutConfirmationDialog(context);
        },
        child: Container(
          width: double.infinity,
          height: 45,
          decoration: BoxDecoration(
            color: Color(0xFFFEC901),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              "Logout",
              style: TextStyle(
                color: Color(0xFF060100),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Logout"),
          content: Text("Apakah Anda yakin ingin logout?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: Text("Batal"),
            ),
            TextButton(
              onPressed: () async {
                // Logout jika tombol "Logout" ditekan
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Text("Logout"),
            ),
          ],
        );
      },
    );
  }
}
