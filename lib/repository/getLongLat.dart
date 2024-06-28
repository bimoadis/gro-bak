import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<Map<String, dynamic>>> readMerchantData() async {
  List<Map<String, dynamic>> combinedData = [];

  try {
    // Membaca data dari tabel 'users'
    QuerySnapshot usersQuery = await FirebaseFirestore.instance
        .collection("merchant")
        .where("status", isEqualTo: 'buka')
        .get();
    List<DocumentSnapshot> usersDocs = usersQuery.docs;

    for (var userDoc in usersDocs) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      String uid = userDoc.id;
      String role = userData['role'];

      if (role == 'Pedagang') {
        DocumentSnapshot merchantDoc = await FirebaseFirestore.instance
            .collection('merchant')
            .doc(uid)
            .get();
        if (merchantDoc.exists) {
          Map<String, dynamic> merchantData =
              merchantDoc.data() as Map<String, dynamic>;
          merchantData['uid'] = uid;
          userData.addAll(merchantData);
          combinedData.add(userData);
        }
      }
    }
  } catch (e) {
    print('Error reading data: $e');
  }

  return combinedData;
}
