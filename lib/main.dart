// lib/main.dart

import 'package:filmku_app/screens/main_screen.dart'; // <-- GANTI IMPORT INI
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
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
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
      home: const MainScreen(), // <-- GANTI WIDGET INI
      debugShowCheckedModeBanner: false, // Opsional: menghilangkan banner debug
    );
  }
}