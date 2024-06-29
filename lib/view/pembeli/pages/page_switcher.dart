import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:gro_bak/services/logout.dart';
import 'package:gro_bak/view/pembeli/list_pesanan.dart';
import 'package:gro_bak/view/pembeli/pages/Pembeli.dart';
import 'package:gro_bak/view/pembeli/pages/home.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PageSwitcherPembeli extends StatefulWidget {
  const PageSwitcherPembeli({super.key});

  @override
  State<PageSwitcherPembeli> createState() => _PageSwitcherPembeliState();
}

class _PageSwitcherPembeliState extends State<PageSwitcherPembeli> {
  int index = 0;

  String getTimeOfDay() {
    var hour = DateTime.now().hour;
    if (hour >= 4 && hour < 12) {
      return 'Pagi';
    } else if (hour >= 12 && hour < 15) {
      return 'Siang';
    } else if (hour >= 15 && hour < 18) {
      return 'Sore';
    } else {
      return 'Malam';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(90),
          child: AppBar(
            bottom: PreferredSize(
                preferredSize: const Size.fromHeight(90),
                child: Container(
                  color: Colors.orange.shade100.withOpacity(0.05),
                  child: SafeArea(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                          color: Colors.orange.shade100.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(23)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Selamat ${getTimeOfDay()}!",
                                      style: TextStyle(
                                        fontSize: 25,
                                        color: Colors.black.withOpacity(0.7),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      // Text widget
                                      "Mau beli apa hari ini ?",
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.black.withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  OrdersPage(),
                                            ),
                                          );
                                        },
                                        icon: const Icon(
                                            Icons.shopping_bag_rounded)),
                                    const SizedBox(width: 10),
                                    IconButton(
                                        onPressed: () {
                                          AuthService.logout(context);
                                        },
                                        icon: const Icon(Icons.logout_rounded)),
                                  ],
                                ),
                                // SvgPicture.asset('assets/images/profile8.svg',
                                //     height: 50, fit: BoxFit.cover),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )),
          )),
      // AppBar(
      //   title: const Text(
      //     "Gro-bak",
      //     style: TextStyle(
      //       fontSize: 32,
      //       color: Color(0xFFFEC901),
      //       fontWeight: FontWeight.bold,
      //       shadows: [
      //         Shadow(
      //           offset: Offset(1.0, 1.0), // position of the shadow
      //           blurRadius: 1.0, // blur effect
      //           color: Color(0xFF060100), // semi-transparent black color
      //         ),
      //       ],
      //     ),
      //   ),
      //   actions: [
      //     IconButton(
      //       onPressed: () {
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => OrdersPage(),
      //   ),
      // );
      //       },
      //       icon: const Icon(
      //         Icons.shopping_bag,
      //         color: Color(0xFF060100),
      //       ),
      //     ),
      //     IconButton(
      //       onPressed: () {
      // AuthService.logout(context);
      //       },
      //       icon: const Icon(
      //         Icons.logout,
      //         color: Color(0xFF060100),
      //       ),
      //     )
      //   ],
      // ),

      body: Stack(
        children: [
          IndexedStack(
            index: index,
            children: [
              Home(),
              const Pembeli(),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                    width: 220,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 20,
                          color: Colors.black.withOpacity(0.1),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: GNav(
                      iconSize: 20,
                      tabBackgroundColor: Colors.orange.shade200,
                      tabBorderRadius: 100,
                      tabs: [
                        GButton(
                          icon: Icons.home_rounded,
                          text: 'Home',
                          onPressed: () {
                            setState(() {
                              index = 0;
                            });
                          },
                        ),
                        GButton(
                          icon: Icons.map,
                          text: 'eksplore',
                          onPressed: () {
                            setState(
                              () {
                                index = 1;
                              },
                            );
                          },
                        )
                      ],
                    ))),
          ),
        ],
      ),
    );
  }
}
