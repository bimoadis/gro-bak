import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<Map<String, dynamic>>> readMerchantData() async {
  List<Map<String, dynamic>> combinedData = [];

  try {
    // Membaca data dari tabel 'users'
    QuerySnapshot usersQuery =
        await FirebaseFirestore.instance.collection('users').get();
    List<DocumentSnapshot> usersDocs = usersQuery.docs;

    // Mengambil data dari setiap dokumen pada tabel 'users'
    for (var userDoc in usersDocs) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      String uid = userDoc.id;
      String role = userData['role'];

      // Jika peran pengguna adalah "Pedagang", baca data pedagang dari tabel 'merchant'
      if (role == 'Pedagang') {
        DocumentSnapshot merchantDoc = await FirebaseFirestore.instance
            .collection('merchant')
            .doc(uid)
            .get();
        if (merchantDoc.exists) {
          Map<String, dynamic> merchantData =
              merchantDoc.data() as Map<String, dynamic>;
          // Menggabungkan data pedagang dengan data pengguna
          userData.addAll(merchantData);
          // Menambahkan data pengguna (dan jika ada, data pedagang) ke dalam daftar gabungan
          combinedData.add(userData);
        }
      }
    }
  } catch (e) {
    print('Error reading data: $e');
  }

  return combinedData;
}
