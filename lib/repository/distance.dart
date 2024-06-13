import 'package:cloud_firestore/cloud_firestore.dart';

class LocationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DocumentSnapshot<Map<String, dynamic>>> getLocationData(
      String documentId) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _firestore.collection('merchant').doc(documentId).get();
    return snapshot;
  }
}
