import 'package:cloud_firestore/cloud_firestore.dart';

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
}
