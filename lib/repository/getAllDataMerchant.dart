import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

class FireStoreServiceAllUser {
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference merchants =
      FirebaseFirestore.instance.collection('merchant');

  // Get the user data by user ID
  Future<DocumentSnapshot> getUserByUID(String uid) async {
    return await users.doc(uid).get();
  }

  // Get the merchant data by user ID
  Future<DocumentSnapshot> getMerchantByUID(String uid) async {
    return await merchants.doc(uid).get();
  }

  static Future<String> uploadImg(File imageFile) async {
    String fileName =
        basename(imageFile.path); // Get the file name using basename function
    Reference ref = FirebaseStorage.instance
        .ref()
        .child(fileName); // Use Reference instead of StorageReference
    UploadTask uploadTask = ref.putFile(imageFile);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => {});

    String url = await taskSnapshot.ref.getDownloadURL();
    return url;
  }
}
