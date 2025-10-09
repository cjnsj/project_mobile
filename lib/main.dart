// lib/main.dart

import 'package:filmku_app/screens/main_screen.dart';
import 'package:filmku_app/services/genre_service.dart';
import 'package:filmku_app/services/language_service.dart'; // <-- 1. IMPORT
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Fungsi main diubah menjadi async untuk menunggu loadGenres selesai
void main() async {
  // Pastikan semua binding Flutter siap sebelum menjalankan kode async
  WidgetsFlutterBinding.ensureInitialized();
  /// Jalankan kedua service secara bersamaan untuk efisiensi
  await Future.wait([
    GenreService().loadGenres(),
    LanguageService().loadLanguages(), // <-- 2. TAMBAHKAN INI
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FilmKu',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Gunakan Poppins sebagai font default di seluruh aplikasi
        fontFamily: GoogleFonts.poppins().fontFamily,
        // Atur warna latar belakang default agar konsisten
        scaffoldBackgroundColor: const Color(0xFFF9F9F9),
        // Tema AppBar default
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF9F9F9),
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
