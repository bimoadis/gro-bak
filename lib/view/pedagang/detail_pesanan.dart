import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gro_bak/view/pedagang/LocationController.dart';
import 'package:gro_bak/view/pembeli/pages/location_pick_controller.dart';

class DetailPesanan extends StatefulWidget {
  const DetailPesanan({super.key, required this.order});
  final Map<String, dynamic> order;

  @override
  State<DetailPesanan> createState() => _DetailPesananState();
}

class _DetailPesananState extends State<DetailPesanan> {
  LocationController _locationPickController = Get.put(LocationController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _locationPickController.getCurrentLocation(
        LatLng(widget.order['latitude'], widget.order['longitude']));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 400,
            child: GoogleMap(
              onMapCreated: _locationPickController.onMapCreated,
              markers: {
                Marker(
                  markerId: const MarkerId('1'),
                  position: LatLng(
                      widget.order['latitude'], widget.order['longitude']),
                ),
              },
              myLocationEnabled: true,
              initialCameraPosition: CameraPosition(
                target:
                    LatLng(widget.order['latitude'], widget.order['longitude']),
                zoom: 18,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 5,
                ),
                Text('Alamat pembeli',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.7),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 7,
                            offset: const Offset(0, 3))
                      ],
                      color: const Color.fromARGB(255, 255, 252, 238),
                      borderRadius: BorderRadius.circular(15)),
                  child: Text(
                    widget.order['address_from_maps'],
                    style: const TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text('detail alamat',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.7),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 7,
                            offset: const Offset(0, 3))
                      ],
                      color: const Color.fromARGB(255, 255, 252, 238),
                      borderRadius: BorderRadius.circular(15)),
                  child: Text(
                    widget.order['address'],
                    style: const TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text('pesanan',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.7),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(width: 10),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Container(
                                constraints:
                                    const BoxConstraints(maxHeight: 120),
                                child: Image.network(
                                  widget.order['imageURL'],
                                  width: 120,
                                  // height: 90,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(widget.order['product_name'] ??
                                      'No Name'),
                                  Text(
                                    'Deskripsi: ${widget.order['notes']}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  Text(
                                    'Pembeli: ${widget.order['nama_pembeli']}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  Text(
                                    'Harga: ${widget.order['price']}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
