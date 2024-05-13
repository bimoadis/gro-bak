import 'package:flutter/material.dart';
import 'package:gro_bak/view/Pedagang.dart';
import 'package:gro_bak/view/pesanan_pedagang.dart';
import 'package:gro_bak/view/profil_pedagang.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onItemTapped;

  BottomNavBar({
    required this.selectedIndex,
    required this.onItemTapped,
  });

  // List berisi kelas-kelas halaman yang akan ditampilkan
  static List<Widget> _widgetOptions = <Widget>[
    Pedagang(), // Halaman Pedagang
    OrderPage(), // Halaman Pesanan
    ProfilePage(),
    // Jika ingin menambah halaman lainnya, tambahkan di sini
    // Contoh: ProfilePage(),
  ];

  static List<Widget> get widgetOptions => _widgetOptions;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      currentIndex: selectedIndex,
      selectedItemColor: Colors.blue,
      onTap: onItemTapped,
    );
  }
}
