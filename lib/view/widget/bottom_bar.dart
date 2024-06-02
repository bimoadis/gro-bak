import 'package:flutter/material.dart';
import 'package:gro_bak/view/Pedagang.dart';
import 'package:gro_bak/view/add_rute_pedagang.dart';
import 'package:gro_bak/view/list_rute_pedagang.dart';
import 'package:gro_bak/view/menu_pedagang.dart';
import 'package:gro_bak/view/pesanan_pedagang.dart';
import 'package:gro_bak/view/profil_pedagang.dart';

class BottomNavBar extends StatefulWidget {
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    Pedagang(),
    AddRutePedagang(),
    ListRutePage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart,
                color: _selectedIndex == 0 ? Colors.blue : Colors.grey),
            label: 'Pesanan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu,
                color: _selectedIndex == 1 ? Colors.blue : Colors.grey),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history,
                color: _selectedIndex == 2 ? Colors.blue : Colors.grey),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person,
                color: _selectedIndex == 3 ? Colors.blue : Colors.grey),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
