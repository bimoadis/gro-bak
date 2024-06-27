import 'package:flutter/material.dart';
import 'package:gro_bak/view/pembeli/list_menu_pembeli.dart';
import 'package:gro_bak/view/pembeli/rute_pedagang.dart';
import 'package:url_launcher/url_launcher.dart';

class BottomSheetWidget extends StatelessWidget {
  final String nameMerchant;
  final String name;
  final List<dynamic> seluruhRute;
  final List<dynamic> menu;
  final double latitude;
  final double longitude;
  final String uidPedagang;
  final String imageURL;
  final String uidPembeli;
  final List<Map<String, dynamic>> rute;
  final List<Map<String, dynamic>>? ratings;
  final String phone_number;

  const BottomSheetWidget({
    super.key,
    required this.phone_number,
    required this.rute,
    required this.ratings,
    required this.imageURL,
    required this.nameMerchant,
    required this.name,
    required this.seluruhRute,
    required this.menu,
    required this.latitude,
    required this.longitude,
    required this.uidPedagang,
    required this.uidPembeli,
  });

  void openWhatsApp(String phoneNumber) async {
    final String whatsappUrl = "whatsapp://send?phone=+$phoneNumber";
    await launchUrl(Uri.parse(whatsappUrl));
    // if (await launchUrl(Uri.encodeFull(whatsappUrl))) {
    //   await launch(whatsappUrl);
    // } else {
    //   throw "Could not launch $whatsappUrl";
    // }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            // // crossAxisAlignment: CrossAxisAlignment.stretch,
            // mainAxisAlignment: MainAxisAlignment.start,
            // // mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Detail Pedagang',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Card(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        imageURL,
                        width: 120,
                        height: 130,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nameMerchant,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => RutePedagang(
                                          seluruhRute: rute,
                                          namaPemilik: name,
                                          namaUsaha: nameMerchant,
                                          uidPedagang: uidPedagang,
                                          uidPembeli: uidPembeli,
                                          menu: menu,
                                        ),
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: const Color(0xFFFEC901),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(50, 30),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 18.0, vertical: 4.0),
                                    child: Text(
                                      'Rute',
                                      style: TextStyle(
                                        color: Color(0xFF060100),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ListMenuPesanan(
                                          ratings: ratings,
                                          menu: menu,
                                          uidPedagang: uidPedagang,
                                          uidPembeli: uidPembeli,
                                        ),
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: const Color(0xFFFEC901),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(50, 30),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 18.0, vertical: 4.0),
                                    child: Text(
                                      'Menu',
                                      style: TextStyle(
                                        color: Color(0xFF060100),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              openWhatsApp(phone_number);
                            },
                            child: Container(
                              width: 150,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(10)),
                              child: const Center(
                                child: Text(
                                  'Kirim Pesan',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
