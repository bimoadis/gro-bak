import 'package:cloud_firestore/cloud_firestore.dart';

class GetLongLat {
  // Stream untuk mendapatkan data dari koleksi 'users' di Firestore
  final Stream<QuerySnapshot> _usersStream =
      FirebaseFirestore.instance.collection('users').snapshots();

  // Metode untuk mendapatkan stream pengguna yang memiliki 'role = Pedagang'
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    // Map untuk mengubah stream QuerySnapshot menjadi stream List<Map<String, dynamic>>
    return _usersStream.map((snapshot) {
      // Memfilter dokumen-dokumen yang memiliki 'role' = 'Pedagang'
      return snapshot.docs.where((doc) {
        final userData = doc.data() as Map<String, dynamic>;
        return userData['role'] == 'Pedagang';
      }).map((doc) {
        final userData = doc.data() as Map<String, dynamic>;
        final fullName = userData['email'] ?? 'Unknown';
        final company = userData['role'] ?? 'Unknown';

        // Mendapatkan latitude dan longitude dalam bentuk double
        final latitude = userData['latitude'] is double
            ? userData['latitude']
            : userData['latitude'] != null
                ? double.tryParse(userData['latitude'].toString())
                : null;
        final longitude = userData['longitude'] is double
            ? userData['longitude']
            : userData['longitude'] != null
                ? double.tryParse(userData['longitude'].toString())
                : null;

        // Mengembalikan data pengguna dalam bentuk Map
        return {
          'fullName': fullName,
          'company': company,
          'latitude': latitude,
          'longitude': longitude,
        };
      }).toList();
    });
  }
}
