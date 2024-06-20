import 'package:flutter/material.dart';
import 'package:flutter_lazy_indexed_stack/flutter_lazy_indexed_stack.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:gro_bak/services/logout.dart';
import 'package:gro_bak/view/pembeli/list_pesanan.dart';
import 'package:gro_bak/view/pembeli/pages/Pembeli.dart';
import 'package:gro_bak/view/pembeli/pages/home.dart';

class PageSwitcherPembeli extends StatefulWidget {
  const PageSwitcherPembeli({super.key});

  @override
  State<PageSwitcherPembeli> createState() => _PageSwitcherPembeliState();
}

class _PageSwitcherPembeliState extends State<PageSwitcherPembeli> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Gro-bak",
          style: TextStyle(
            fontSize: 32,
            color: Color(0xFFFEC901),
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(1.0, 1.0), // position of the shadow
                blurRadius: 1.0, // blur effect
                color: Color(0xFF060100), // semi-transparent black color
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrdersPage(),
                ),
              );
            },
            icon: const Icon(
              Icons.shopping_bag,
              color: Color(0xFF060100),
            ),
          ),
          IconButton(
            onPressed: () {
              AuthService.logout(context);
            },
            icon: const Icon(
              Icons.logout,
              color: Color(0xFF060100),
            ),
          )
        ],
      ),

      /*
      lazy indexed stack, sebuah fungsi mirip seperti indexed stack 
      tapi yang dijalankan(init statem, dll) hanya halaman yang ditampilkan, 
      jadi tidak semua fungsi di semua halaman dijalankan sekaligus seperti di indexed stack biasa
      */
      body: Stack(
        children: [
          IndexedStack(
            index: index,
            children: const [
              Home(),
              Pembeli(),
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
