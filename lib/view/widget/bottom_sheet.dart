import 'package:flutter/material.dart';
import 'package:gro_bak/view/pembeli/list_menu_pembeli.dart';
import 'package:gro_bak/view/pembeli/rute_pedagang.dart';

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

  BottomSheetWidget({
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'Detail Pedagang',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                children: [
                  Card(
                    child: Container(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          imageURL,
                          width: 120,
                          height: 90,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            nameMerchant,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 4.0),
                            child: Row(
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => RutePedagang(
                                          seluruhRute: seluruhRute,
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
                                    backgroundColor: Color(0xFFFEC901),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size(50, 30),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
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
                                SizedBox(
                                  width: 10,
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ListMenuPesanan(
                                          menu: menu,
                                          uidPedagang: uidPedagang,
                                          uidPembeli: uidPembeli,
                                        ),
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: Color(0xFFFEC901),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size(50, 30),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
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
