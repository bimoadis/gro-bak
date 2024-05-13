import 'package:cloud_firestore/cloud_firestore.dart';

class FireStoreServiceUser {
  // Get the user
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  // get users => null;

  //Add the user
  Future<void> addUser(String user, String longitude, String latitude) {
    return users.add({
      'user': user,
      'longitude': longitude,
      'latitude': latitude,
      'time': Timestamp.now(),
    });
  }

  //Read the user
  Stream<QuerySnapshot> getUsersStream() {
    final usersStream =
        FirebaseFirestore.instance.collection('users').orderBy('timestamp');
    return usersStream.snapshots();
  }
  //Update the user

  //Delete the user
}
