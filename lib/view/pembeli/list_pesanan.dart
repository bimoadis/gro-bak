import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  Stream<List<DocumentSnapshot>> getWaitingConfirmationStream() {
    return FirebaseFirestore.instance
        .collection('orders')
        .where('status', isEqualTo: 'Menunggu Konfirmasi')
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  Stream<List<DocumentSnapshot>> getConfirmedStream() {
    return FirebaseFirestore.instance
        .collection('orders')
        .where('status', isEqualTo: 'Dikonfirmasi')
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) {
    return FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .update({'status': newStatus});
  }

  void updateTerjual(String documentId, int indexProduk) async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('merchant')
        .doc(documentId)
        .get();
    if (snapshot.exists) {
      // Mendapatkan data menu dari merchant
      List<dynamic> menu = snapshot['menu'];

      menu[indexProduk]['terjual'] += 1;

      print(menu.toList());

      // Memperbarui data di Firestore
      await FirebaseFirestore.instance
          .collection('merchant')
          .doc(documentId)
          .update({
        'menu': menu,
      });
      print('Data terjual berhasil diperbarui.');
    } else {
      print('Dokumen tidak ditemukan.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Orders'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Menunggu Konfirmasi'),
              Tab(text: 'Dikonfirmasi'),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: TabBarView(
            children: [
              Container(
                color: Colors.orange.shade100.withOpacity(0.05),
                child: StreamBuilder<List<DocumentSnapshot>>(
                  stream: getWaitingConfirmationStream(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          var order = snapshot.data![index];
                          // var data = order.data() as Map<String, dynamic>;

                          // Format tanggal menjadi string
                          String formattedDate = DateFormat('d MMMM yyyy')
                              .format(order['timestamp'].toDate());
                          return OrderItem(
                            onBatal: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Konfirmasi'),
                                    content: const Text(
                                        'Apakah Anda yakin ingin membatalkan pesanan ini?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          updateOrderStatus(
                                              order.id, 'Dibatalkan');
                                          Navigator.pop(context);
                                        },
                                        child: const Text(
                                          'Ya',
                                          style: TextStyle(color: Colors.green),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text(
                                          'Tidak',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            order: order,
                            formattedDate: formattedDate,
                            status: 'Menunggu Konfirmasi',
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    return const SizedBox(
                        width: 70,
                        height: 70,
                        child: CircularProgressIndicator());
                  },
                ),
              ),
              StreamBuilder<List<DocumentSnapshot>>(
                stream: getConfirmedStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          var order = snapshot.data![index];

                          String formattedDate = DateFormat('d MMMM yyyy')
                              .format(order['timestamp'].toDate());
                          return OrderItem(
                              order: order,
                              formattedDate: formattedDate,
                              status: 'Dikonfirmasi',
                              changeToSuccess: () {
                                setState(() {
                                  updateTerjual(
                                    order['merch_id'],
                                    int.parse(order['productIndex']),
                                  );
                                  showDialog(
                                    context: context,
                                    builder: (context) => Dialog(
                                      child: RatingDialog(
                                          productIndex: order['productIndex'],
                                          merchId: order['merch_id']),
                                    ),
                                  );
                                  updateOrderStatus(order.id, 'Selesai');
                                });
                              });
                        });
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  return const CircularProgressIndicator();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrderItem extends StatelessWidget {
  const OrderItem({
    super.key,
    this.onBatal,
    required this.order,
    required this.formattedDate,
    required this.status,
    this.changeToSuccess,
  });

  final DocumentSnapshot<Object?> order;
  final String formattedDate;
  final String status;
  final void Function()? changeToSuccess;
  final void Function()? onBatal;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
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
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  order['imageURL'],
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order['product_name'],
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    order['delivery_option'],
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Divider(color: Colors.grey[300]),
          const SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rp. ${order['price']}',
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (status == 'Menunggu Konfirmasi')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Text(
                    //   status,
                    //   style: TextStyle(
                    //     color: Colors.yellow.shade700,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),

                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          textStyle:
                              const TextStyle(fontWeight: FontWeight.bold),
                          backgroundColor: Colors.red.shade100.withOpacity(0.5),
                        ),
                        onPressed: onBatal,
                        child: const Text(
                          'Batal',
                          style: TextStyle(color: Colors.red),
                        ))
                  ],
                ),
              if (status == 'Dikonfirmasi')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                        backgroundColor: Colors.green.shade100.withOpacity(0.5),
                      ),
                      onPressed: changeToSuccess,
                      child: Text(
                        "Pesanan Selesai",
                        style: TextStyle(
                          color: Colors.green.shade900,
                        ),
                      ),
                    )
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class RatingDialog extends StatefulWidget {
  const RatingDialog(
      {super.key, required this.merchId, required this.productIndex});
  final String merchId;
  final String productIndex;

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  List<Map<String, dynamic>> _ratings = [];
  var _rating = 1.0;

  getMerchantRating(String merchantId) async {
    await FirebaseFirestore.instance
        .collection('merchant')
        .doc(merchantId)
        .get()
        .then(
      (merchantData) {
        var merchantRatings = merchantData.data()?['ratings'];
        if (merchantRatings != null) {
          for (var rating in merchantRatings) {
            _ratings.add({
              'produkIndex': rating['produkIndex'],
              'rating': rating['rating'],
            });
          }
        }
      },
    );
  }

  Future<void> updateRating(
    String merchantId,
    List<Map<String, dynamic>> ratings,
  ) async {
    await FirebaseFirestore.instance
        .collection('merchant')
        .doc(merchantId)
        .update({'ratings': ratings});

    //update average rating
    await FirebaseFirestore.instance
        .collection('merchant')
        .doc(merchantId)
        .update({'average_rating': getAverageRating(ratings)});
  }

  getAverageRating(List<Map<String, dynamic>> ratings) {
    double totalRating = 0;
    for (var rating in ratings) {
      totalRating += rating['rating'];
    }
    return totalRating / ratings.length;
  }

  @override
  void initState() {
    super.initState();
    getMerchantRating(widget.merchId);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Beri rating yuk!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(
              height: 20,
            ),
            RatingBar(
              initialRating: 3,
              minRating: 1,
              maxRating: 5,
              ratingWidget: RatingWidget(
                  full: const Icon(
                    Icons.star_rounded,
                    color: Colors.yellow,
                  ),
                  half: const Icon(Icons.star_half_rounded),
                  empty: const Icon(
                    Icons.star_border_rounded,
                    color: Colors.grey,
                  )),
              onRatingUpdate: (value) {
                setState(() {
                  _rating = value;
                  print(_rating);
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _ratings.add({
                      'produkIndex': widget.productIndex,
                      'rating': _rating,
                    });
                    // updateRating(widget.merchId, _ratings);
                    Navigator.pop(context);
                  },
                  child: const Text('Kirim'),
                )
              ],
            )
          ],
        ));
  }
}
