// lib/screens/main_screen.dart

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'bookmarks_screen.dart';
import 'ticket_screen.dart'; // TAMBAHKAN: Import halaman tiket yang baru dibuat

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // UBAH: Tambahkan TicketScreen ke dalam daftar widget
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    TicketScreen(), // <-- Halaman baru ditambahkan di sini
    SearchScreen(),
    BookmarksScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),
      bottomNavigationBar: BottomNavigationBar(
        // UBAH: Tambahkan item baru untuk Tiket
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(EvaIcons.filmOutline),
            activeIcon: Icon(EvaIcons.film),
            label: 'Home',
          ),
          // TAMBAHKAN: Item baru untuk menu Tiket
          BottomNavigationBarItem(
            icon: Icon(Icons.local_activity_outlined),
            activeIcon: Icon(Icons.local_activity),
            label: 'Tickets',
          ),
          BottomNavigationBarItem(
            icon: Icon(EvaIcons.searchOutline),
            activeIcon: Icon(EvaIcons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(EvaIcons.bookmarkOutline),
            activeIcon: Icon(EvaIcons.bookmark),
            label: 'Bookmarks',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF3F51B5), // Warna biru indigo
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 10.0,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
    );
  }
}
