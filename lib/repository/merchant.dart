import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart'; // Import path.dart for basename function

class ServiceMerchant {
  static CollectionReference merchantCollection =
      FirebaseFirestore.instance.collection('merchant');

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
