import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:gro_bak/repository/getAllDataMerchant.dart';
import 'package:gro_bak/view/pedagang/list_rute_pedagang.dart';
import 'package:image_picker/image_picker.dart';
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

  final ImagePicker _picker = ImagePicker();
  Rx<XFile?> _imageFile = Rx<XFile?>(null);
  var downloadURL = ''.obs;

  Rx<File?> compressedImage = Rx<File?>(null);

  Future<void> _uploadImageToFirebase(File file) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await storageRef.putFile(file);
      downloadURL.value = await storageRef.getDownloadURL();
      print('Upload complete. Download URL: $downloadURL');
      _updateUserDetails();
      Navigator.pop(context);
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future<void> _pickImage(int option, BuildContext context) async {
    final XFile? pickedFile = (option == 1)
        ? await _picker.pickImage(source: ImageSource.camera)
        : await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      compressedImage.value = await _compressImage(File(pickedFile.path));
      _uploadImageToFirebase(compressedImage.value!);
    }
  }

  Future<File?> _compressImage(File file) async {
    final filePath = file.absolute.path;
    final lastIndex = filePath.lastIndexOf(RegExp(r'.jp'));

    final splitted = filePath.substring(0, (lastIndex));
    final outPath = "${splitted}_out${filePath.substring(lastIndex)}";

    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      outPath,
      quality: 50,
    );
    print(file.lengthSync());

    return File(result!.path);
  }

  _updateUserDetails() async {
    if (currentUser != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .update({
        'profileImage': downloadURL.value,
      });
      _fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userMap = userData?.data() as Map<String, dynamic>? ?? {};
    final merchantMap = merchantData?.data() as Map<String, dynamic>? ?? {};

    final nama = userMap['nama'] ?? 'Unknown';
    final role = userMap['role'] ?? 'Unknown';
    final namaUsaha = merchantMap['nama_usaha'] ?? 'Unknown';
    final nomorTelepon = userMap['phone_number'] ?? 'Unknown';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Gro-bak"),
      ),
      body: userData == null || merchantData == null
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 50),
                  SizedBox(
                    child: Stack(
                      children: [
                        Obx(() {
                          if (userData!['profileImage'] != null) {
                            downloadURL.value = userData!['profileImage'];
                          }
                          return (downloadURL.value == '')
                              ? const CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.deepPurple,
                                  backgroundImage: AssetImage(
                                      'assets/images/profile-none.jpg'),
                                  child: Icon(Icons.person, size: 50),
                                )
                              : CircleAvatar(
                                  radius: 50,
                                  backgroundImage:
                                      Image.network(userData!['profileImage'])
                                          .image,
                                  child: const SizedBox(),
                                );
                        }),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return Container(
                                    height: 150,
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      children: [
                                        const Text(
                                          "Pilih sumber gambar",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                _pickImage(1, context);
                                              },
                                              child: const Column(
                                                children: [
                                                  Icon(Icons.camera),
                                                  Text("Kamera"),
                                                ],
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                _pickImage(2, context);
                                              },
                                              child: const Column(
                                                children: [
                                                  Icon(Icons.image),
                                                  Text("Galeri"),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black,
                                    blurRadius: 5,
                                  ),
                                ],
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit,
                                  color: Colors.black, size: 20),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    nama,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 20),
                  buildProfileRow(Icons.work, role),
                  const SizedBox(height: 10),
                  buildProfileRow(Icons.business, namaUsaha),
                  const SizedBox(height: 10),
                  buildProfileRow(Icons.phone, nomorTelepon),
                  const SizedBox(height: 10),
                  buildRuteDagangButton(
                      context), // Modified button for "Rute Dagang"
                  const SizedBox(height: 10),
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
            const SizedBox(width: 20),
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



        // 'timestamp': userData!['timestamp'],
        // 'phone_number': userData!['phoneNumber'],
        // 'longitude': userData!['longitude'],
        // 'latitude': userData!['latitude'],
        // 'nama': userData!['nama'],
        // 'role': userData!['role'],
        // 'nama': userData!['email'],
        // 'profileImage': downloadURL.value,