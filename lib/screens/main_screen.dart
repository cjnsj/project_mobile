// lib/screens/main_screen.dart

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'bookmarks_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
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
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(EvaIcons.filmOutline),
            activeIcon: Icon(EvaIcons.film),
            label: 'Home',
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
        showSelectedLabels: true, // Sesuai desain, label hanya muncul saat aktif
        showUnselectedLabels: true,
      ),
    );
  }
}
