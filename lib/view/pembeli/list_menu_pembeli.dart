import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:gro_bak/view/pembeli/pesanan_pembeli.dart';

class ListMenuPesanan extends StatefulWidget {
  final List<dynamic> menu;
  final String uidPedagang;
  final String uidPembeli;
  // final List<Map<String, dynamic>>? combinedDataFuture;
  final List<Map<String, dynamic>>? ratings;

  const ListMenuPesanan({
    Key? key,
    required this.menu,
    required this.uidPedagang,
    required this.uidPembeli,
    this.ratings,
  }) : super(key: key);

  @override
  _ListMenuPesananState createState() => _ListMenuPesananState();
}

class _ListMenuPesananState extends State<ListMenuPesanan> {
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<dynamic> menuList = [];

  @override
  void initState() {
    super.initState();
    // Ambil menu dari properti menu yang dilewatkan
    menuList = widget.menu;
  }

  double getAveragePerMenu(int menuIndex) {
    // Ambil semua ratings untuk menu dengan index tertentu
    List<double> ratings = [];

    widget.ratings?.forEach((data) {
      if (data['produkIndex'] == menuIndex.toString()) {
        print('ratings : ${data['rating']}');
        ratings.add(data['rating']);
      }
    });

    print('to List : ${ratings.toList()}');
    // Hitung rata-rata
    if (ratings.isNotEmpty) {
      double averageRating = ratings.reduce((a, b) => a + b) / ratings.length;
      return averageRating;
    } else {
      return 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List Menu'),
        centerTitle: true,
      ),
      body: menuList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: menuList.length,
                itemBuilder: (context, index) {
                  var menu = menuList[index];
                  int menuIndex = index;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderForm(
                            productIndex: menuIndex.toString(),
                            menu: menu,
                            uidPedagang: widget.uidPedagang,
                            uidPembeli: widget.uidPembeli,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6.0,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.network(
                                    '${menu['imageURL']}',
                                    width: 120,
                                    height: 90,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4.0),
                                    Text(
                                      menu['nama_produk'] ?? 'No Name',
                                      style: const TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4.0),
                                    Text(
                                      'Harga: ${menu['harga']}',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        RatingBar(
                                          itemSize: 20,
                                          initialRating:
                                              getAveragePerMenu(menuIndex),
                                          minRating: 1,
                                          maxRating: 5,
                                          ignoreGestures: true,
                                          ratingWidget: RatingWidget(
                                              full: Icon(
                                                Icons.star_rounded,
                                                color: Colors.yellow.shade700,
                                              ),
                                              half: const Icon(
                                                  Icons.star_half_rounded),
                                              empty: const Icon(
                                                Icons.star_border_rounded,
                                                color: Colors.grey,
                                              )),
                                          onRatingUpdate: (_) {},
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                            '${menu['terjual'].toString()} terjual')
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
