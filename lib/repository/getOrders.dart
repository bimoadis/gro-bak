import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<DocumentSnapshot>> getOrders() {
    String? loggedInUserId = _auth.currentUser?.uid;

    return _firestore.collection('orders').snapshots().map((snapshot) {
      return snapshot.docs.where((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return data.containsKey('merch_id') &&
            data.containsKey('user_id') &&
            (data['merch_id'] == loggedInUserId ||
                data['user_id'] == loggedInUserId);
      }).toList();
    });
  }
}
