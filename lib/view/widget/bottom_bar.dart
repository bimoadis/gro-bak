import 'package:flutter/material.dart';
import 'package:gro_bak/view/pedagang/Pedagang.dart';
import 'package:gro_bak/view/pedagang/add_rute_pedagang.dart';
import 'package:gro_bak/view/pedagang/list_menu_pedagang.dart';
import 'package:gro_bak/view/pedagang/list_rute_pedagang.dart';
import 'package:gro_bak/view/pedagang/profil_pedagang.dart';

class BottomNavBar extends StatefulWidget {
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    Pedagang(),
    ListMenuPage(),
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
                color: _selectedIndex == 0 ? Color(0xFFFEC901) : Colors.grey),
            label: 'Pesanan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu,
                color: _selectedIndex == 1 ? Color(0xFFFEC901) : Colors.grey),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history,
                color: _selectedIndex == 2 ? Color(0xFFFEC901) : Colors.grey),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person,
                color: _selectedIndex == 3 ? Color(0xFFFEC901) : Colors.grey),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFFFEC901),
        onTap: _onItemTapped,
        selectedIconTheme: IconThemeData(
            color: Color(0xFFFEC901), size: 28), // Ukuran ikon yang dipilih
        unselectedIconTheme: IconThemeData(
            color: Colors.grey, size: 24), // Ukuran ikon yang tidak dipilih
        selectedLabelStyle: TextStyle(
          color: Color(0xFFFEC901),
          fontSize: 18,
          shadows: [
            BoxShadow(
              color: Color(0xFF060100).withOpacity(0.45),
              blurRadius: 1,
              offset: Offset(0, 0.4),
            ),
          ],
        ),
        unselectedLabelStyle: TextStyle(
          color: Colors.grey,
          shadows: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              blurRadius: 2,
              offset: Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}
