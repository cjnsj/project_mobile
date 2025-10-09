// lib/screens/search_screen.dart

import 'dart:async'; // Import untuk Timer (debouncing)
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/popular_movie_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ApiService apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  List<dynamic>? _results;
  bool _isLoading = false;
  Timer? _debounce;

  // Fungsi yang dipanggil saat teks di kolom pencarian berubah
  void _onSearchChanged(String query) {
    // Batalkan timer sebelumnya jika ada
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Atur timer baru. Jika pengguna tidak mengetik lagi selama 500ms, lakukan pencarian.
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        _performSearch(query);
      } else {
        // Jika kolom pencarian kosong, bersihkan hasil
        setState(() {
          _results = null;
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await apiService.searchMovies(query);
      setState(() {
        _results = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _results = []; // Kosongkan hasil jika ada error
      });
      // Tampilkan pesan error jika perlu
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Search Movie',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Kolom Input Pencarian
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              autofocus: true, // Langsung fokus ke kolom pencarian
              decoration: InputDecoration(
                hintText: 'Cari Film/Movie Favorite-Mu"',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                fillColor: Colors.grey[100],
                filled: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
              ),
              onChanged: _onSearchChanged, // Panggil fungsi saat teks berubah
            ),
          ),

          // Daftar Hasil Pencarian
          Expanded(child: _buildResults()),
        ],
      ),
    );
  }

  // Widget untuk menampilkan hasil berdasarkan state
  Widget _buildResults() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_results == null) {
      // Tampilan awal sebelum pencarian dilakukan
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.movie_filter_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Temukan Film Favoritmu',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_results!.isEmpty) {
      // Tampilan jika hasil pencarian kosong
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Film "${_searchController.text}" tidak ditemukan',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Tampilan jika ada hasil
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16.0),
      itemCount: _results!.length,
      itemBuilder: (context, index) {
        var movie = _results![index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: PopularMovieCard(
            id: movie['id'],
            posterPath: movie['poster_path'],
            title: movie['title'],
            rating: movie['vote_average'].toDouble(),
            genreIds: List<int>.from(movie['genre_ids']),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }
}
