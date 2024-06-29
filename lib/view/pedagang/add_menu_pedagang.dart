import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:gro_bak/view/pedagang/currency.dart';
import 'package:gro_bak/view/widget/bottom_bar.dart';
import 'package:image_picker/image_picker.dart';

class AddMenuPedagang extends StatefulWidget {
  const AddMenuPedagang({super.key});

  @override
  State<AddMenuPedagang> createState() => _AddMenuPedagangState();
}

class _AddMenuPedagangState extends State<AddMenuPedagang> {
  final _auth = FirebaseAuth.instance;

  final TextEditingController _namaProductController = TextEditingController();
  final TextEditingController _detailProductController =
      TextEditingController();
  TextEditingController _hargaController = TextEditingController();

  // void _removeDots(String text = '') {
  //   String newText = text.replaceAll(',', '');
  //   // if (text != newText) {
  //   //   _hargaController.value = TextEditingValue(
  //   //     text: newText,
  //   //     selection: TextSelection.fromPosition(
  //   //       TextPosition(offset: newText.length),
  //   //     ),
  //   //   );
  //   // }
  // }

  final ImagePicker _picker = ImagePicker();
  Rx<XFile?> _imageFile = Rx<XFile?>(null);
  var downloadURL = ''.obs;

  Rx<File?> compressedImage = Rx<File?>(null);

  Future<void> _uploadImageToFirebase(File file) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('uploads/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await storageRef.putFile(file);
      downloadURL.value = await storageRef.getDownloadURL();
      print('Upload complete. Download URL: $downloadURL');
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

      Navigator.pop(context);
    }
  }

  myShowDialog() {
    return showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                _pickImage(1, context);
                setState(() {});
              },
              child: Container(
                height: 50,
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text('ambil foto'),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () {
                _pickImage(2, context);
                setState(() {});
              },
              child: Container(
                height: 50,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text('ambil dari galeri'),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambahkan Menu'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => (compressedImage.value == null)
                    ? GestureDetector(
                        onTap: () {
                          myShowDialog();
                        },
                        child: Container(
                          height: 300,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            border: Border.all(
                                color: Colors.grey.shade300.withOpacity(0.8)),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt_rounded,
                                    size: 40, color: Colors.grey.shade400),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Text('tambahkan foto produk')
                              ],
                            ),
                          ),
                        ),
                      )
                    : Image.file(
                        File(compressedImage.value!.path),
                        height: 300,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(
                height: 10,
              ),
              Obx(
                () => (compressedImage.value != null)
                    ? Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              _uploadImageToFirebase(compressedImage.value!);
                            },
                            child: Container(
                              width: 80,
                              height: 35,
                              decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(5)),
                              child: Center(
                                child: (downloadURL.value.isEmpty)
                                    ? const Text('Upload')
                                    : const Text(
                                        'Uploaded',
                                        style: TextStyle(color: Colors.green),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 30),
                          (downloadURL.value.isEmpty)
                              ? GestureDetector(
                                  onTap: () {
                                    myShowDialog();
                                  },
                                  child: Container(
                                    width: 80,
                                    height: 35,
                                    decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                        borderRadius: BorderRadius.circular(5)),
                                    child: const Center(
                                      child: Text('Ganti'),
                                    ),
                                  ),
                                )
                              : Container(
                                  width: 80,
                                  height: 35,
                                  decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      border: Border.all(
                                          color: Colors.grey.shade200
                                              .withOpacity(0.8)),
                                      borderRadius: BorderRadius.circular(5)),
                                  child: const Center(
                                    child: Text('Ganti',
                                        style: TextStyle(color: Colors.grey)),
                                  ),
                                ),
                        ],
                      )
                    : const SizedBox(),
              ),
              const SizedBox(
                height: 30,
              ),
              TextField(
                controller: _namaProductController,
                decoration: InputDecoration(
                  hintText: 'Nama Produk',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _detailProductController,
                decoration: InputDecoration(
                  hintText: 'Detail Produk',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CurrencyFormat()
                ],
                onChanged: (value) {
                  print(_hargaController.text.replaceAll(',', ''));
                },
                controller: _hargaController,
                decoration: InputDecoration(
                  hintText: 'Harga',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveMenu,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFEC901),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
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
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields')));
      return;
    }
    if (downloadURL.value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please upload image'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    String nama = _namaProductController.text;
    try {
      if (nama.isNotEmpty || downloadURL.value.isNotEmpty) {
        FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
        var user = _auth.currentUser;
        if (user != null) {
          CollectionReference ref =
              FirebaseFirestore.instance.collection('merchant');
          DocumentSnapshot docSnapshot = await ref.doc(user.uid).get();

          List<dynamic> rute = docSnapshot['menu'] ?? [];

          rute.add({
            "imageURL": downloadURL.value,
            "nama_produk": _namaProductController.text,
            "deskripsi_produk": _detailProductController.text,
            "harga": int.parse(_hargaController.text.replaceAll(',', '')),
            "terjual": 0
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
