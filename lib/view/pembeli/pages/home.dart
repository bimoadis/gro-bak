import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gro_bak/repository/getLongLat.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gro_bak/view/widget/bottom_sheet.dart';

class Home extends StatefulWidget {
  Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Rx<List<Map<String, dynamic>>?> _combinedDataFuture =
      Rx<List<Map<String, dynamic>>?>(null);
  Position? _currentUserPosition;

  getCombinedData() async {
    _combinedDataFuture.value = await readMerchantData();
    _currentUserPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    _combinedDataFuture.value = _combinedDataFuture.value!.where((merchant) {
      final distance = Geolocator.distanceBetween(
          _currentUserPosition!.latitude,
          _currentUserPosition!.longitude,
          merchant['latitude'],
          merchant['longitude']);
      return distance <= 100000; // 100 kilometers
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    getCombinedData();
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
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return BottomSheetWidget(
          imageURL: profileImage,
          nameMerchant: nameMerchant,
          name: name,
          seluruhRute: seluruhRute,
          menu: menu,
          latitude: latitude,
          longitude: longitude,
          uidPedagang: uidPedagang,
          uidPembeli: uidPembeli,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Obx(() {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pedagang terdekat',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(
              height: 10,
            ),
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
                                _combinedDataFuture.value![index]['nama_usaha'],
                                _combinedDataFuture.value![index]['nama'],
                                _combinedDataFuture.value![index]['rute'],
                                _combinedDataFuture.value![index]['menu'],
                                _combinedDataFuture.value![index]['latitude'],
                                _combinedDataFuture.value![index]['longitude'],
                                _combinedDataFuture.value![index]['uid'],
                                FirebaseAuth.instance.currentUser!.uid);
                          },
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  clipBehavior: Clip.hardEdge,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Image.network(
                                    _combinedDataFuture.value![index]
                                        ['profileImage'],
                                    width: 100,
                                    height: 90,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      _combinedDataFuture.value![index]
                                          ['nama_usaha'],
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.black.withOpacity(0.7),
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Text(_combinedDataFuture.value![index]
                                        ['nama']),
                                    Text(
                                      'telfon : ${_combinedDataFuture.value![index]['nomor_telepon']}',
                                      maxLines: 2,
                                    ),
                                  ],
                                )
                              ]),
                        );
                      },
                    ),
                  )
          ],
        ),
      );
    }));
  }
}
