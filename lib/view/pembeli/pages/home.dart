import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gro_bak/repository/getLongLat.dart';
import 'package:gro_bak/view/widget/bottom_sheet.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Rx<List<Map<String, dynamic>>?> _combinedDataFuture =
      Rx<List<Map<String, dynamic>>?>(null);
  Position? _currentUserPosition;

  Future<void> getCombinedData() async {
    _combinedDataFuture.value = await readMerchantData();
    _currentUserPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    _combinedDataFuture.value = _combinedDataFuture.value!
        .where((merchant) =>
            Geolocator.distanceBetween(
                _currentUserPosition!.latitude,
                _currentUserPosition!.longitude,
                merchant['latitude'].toDouble(),
                merchant['longitude'].toDouble()) <=
            5000) // 5000 meters (5 km)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    getCombinedData();
  }

  double calculateDistance(double startLatitude, double startLongitude,
      double endLatitude, double endLongitude) {
    double distanceInMeters = Geolocator.distanceBetween(
        startLatitude, startLongitude, endLatitude, endLongitude);
    return distanceInMeters / 1000; // convert to kilometers
  }

  void _showBottomSheet(
    String profileImage,
    String nameMerchant,
    String name,
    List<dynamic> seluruhRute,
    List<dynamic> menu,
    double latitude,
    double longitude,
    String uidPedagang,
    String uidPembeli,
    List<Map<String, dynamic>> ratings,
    List<Map<String, dynamic>> rute,
    String phone_number
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return BottomSheetWidget(
          currentUserPosition: _currentUserPosition!,
          phone_number: phone_number,
          rute: rute,
          ratings: ratings,
          imageURL: profileImage,
          nameMerchant: nameMerchant,
          name: name,
          seluruhRute: seluruhRute,
          menu: menu,
          latitude: latitude.toDouble(),
          longitude: longitude.toDouble(),
          uidPedagang: uidPedagang,
          uidPembeli: uidPembeli,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade100.withOpacity(0.05),
      body: Obx(
        () => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Pedagang terdekat',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 10),
              (_combinedDataFuture.value == null)
                  ? const Center(child: CircularProgressIndicator())
                  : Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _combinedDataFuture.value!.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              _showBottomSheet(
                                  _combinedDataFuture.value![index]
                                      ['profileImage'],
                                  _combinedDataFuture.value![index]
                                      ['nama_usaha'],
                                  _combinedDataFuture.value![index]['nama'],
                                  _combinedDataFuture.value![index]['rute'],
                                  _combinedDataFuture.value![index]['menu'],
                                  _combinedDataFuture.value![index]['latitude'],
                                  _combinedDataFuture.value![index]
                                      ['longitude'],
                                  _combinedDataFuture.value![index]['uid'],
                                  FirebaseAuth.instance.currentUser!.uid,
                                  _combinedDataFuture.value![index]['ratings']
                                      .cast<Map<String, dynamic>>(),
                                  _combinedDataFuture.value![index]['rute']
                                      .cast<Map<String, dynamic>>(),
                                      
                                  _combinedDataFuture.value![index]['phone_number']);
                            },
                            child: Column(
                              children: [
                                const SizedBox(height: 15),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color:
                                        Colors.orange.shade100.withOpacity(0.5),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 100,
                                        height: 120,
                                        clipBehavior: Clip.hardEdge,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: Image.network(
                                          _combinedDataFuture.value![index]
                                                  ['profileImage'] ??
                                              'https://via.placeholder.com/100x90',
                                          width: 100,
                                          height: 120,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 10),
                                          Text(
                                            _combinedDataFuture.value![index]
                                                ['nama_usaha'],
                                            style: TextStyle(
                                              fontSize: 20,
                                              color:
                                                  Colors.black.withOpacity(0.7),
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Text(_combinedDataFuture.value![index]
                                              ['nama']),
                                          const SizedBox(height: 5),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.location_on,
                                                color: Colors.black
                                                    .withOpacity(0.7),
                                                size: 15,
                                              ),
                                              const SizedBox(width: 5),
                                              Text(
                                                '${_currentUserPosition != null ? calculateDistance(
                                                    _currentUserPosition!
                                                        .latitude,
                                                    _currentUserPosition!
                                                        .longitude,
                                                    _combinedDataFuture
                                                            .value![index]
                                                        ['latitude'],
                                                    _combinedDataFuture
                                                            .value![index]
                                                        ['longitude'],
                                                  ).toStringAsFixed(2) : 'Calculating'} km',
                                                style: TextStyle(
                                                  color: Colors.black
                                                      .withOpacity(0.7),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          RatingBar(
                                            itemSize: 20,
                                            initialRating: _combinedDataFuture
                                                        .value![index]
                                                    ['average_rating'] ??
                                                0.0,
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
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
