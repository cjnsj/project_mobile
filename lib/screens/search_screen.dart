// lib/screens/search_screen.dart

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
  
  Future<List<dynamic>>? _searchResults;

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      setState(() {
        _searchResults = apiService.searchMovies(query);
      });
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
              decoration: InputDecoration(
                hintText: 'Cari film favoritmu...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
              ),
              onSubmitted: (value) => _performSearch(), // Cari saat menekan enter
            ),
          ),

          // Daftar Hasil Pencarian
          Expanded(
            child: _searchResults == null
                ? const Center(child: Icon(Icons.search, size: 60, color: Colors.grey))
                : FutureBuilder<List<dynamic>>(
                    future: _searchResults,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('Film tidak ditemukan.'));
                      }

                      var movies = snapshot.data!;
                      return ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        itemCount: movies.length,
                        itemBuilder: (context, index) {
                          var movie = movies[index];
                          return PopularMovieCard(
                            id: movie['id'],
                            posterPath: movie['poster_path'],
                            title: movie['title'],
                            rating: movie['vote_average'].toDouble(),
                            genreIds: List<int>.from(movie['genre_ids']),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}