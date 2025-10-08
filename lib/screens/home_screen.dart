// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/movie_card.dart';
import '../widgets/popular_movie_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Instance ApiService agar tidak dibuat berulang kali
  final ApiService apiService = ApiService();
  late Future<List<dynamic>> nowShowingMovies;
  late Future<List<dynamic>> popularMovies;

  @override
  void initState() {
    super.initState();
    // Panggil API saat halaman pertama kali dimuat
    nowShowingMovies = apiService.getNowShowingMovies();
    popularMovies = apiService.getPopularMovies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const IconButton(
          icon: Icon(Icons.menu, color: Colors.black),
          onPressed: null, // Fungsi ditambahkan nanti
        ),
        title: const Text(
          'FilmKu',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
        actions: const [
          IconButton(
            icon: Icon(Icons.notifications_none, color: Colors.black, size: 28),
            onPressed: null, // Fungsi ditambahkan nanti
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Bagian "Now Showing" ---
            buildSectionTitle('Now Showing'),
            buildNowShowingList(),
            
            const SizedBox(height: 20),

            // --- Bagian "Popular" ---
            buildSectionTitle('Popular'),
            buildPopularList(),
          ],
        ),
      ),
    );
  }

  // Widget untuk judul section
  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            'See more',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // Widget untuk daftar "Now Showing"
  Widget buildNowShowingList() {
    return Container(
      height: 300,
      child: FutureBuilder<List<dynamic>>(
        future: nowShowingMovies,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada film yang tayang.'));
          }
          
          var movies = snapshot.data!;
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: movies.length,
            // Menambahkan padding agar list tidak terlalu mepet ke tepi
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            itemBuilder: (context, index) {
              var movie = movies[index];
              return MovieCard(
                id: movie['id'],
                posterPath: movie['poster_path'],
                title: movie['title'],
                rating: movie['vote_average'].toDouble(),
              );
            },
          );
        },
      ),
    );
  }

  // Widget untuk daftar "Popular"
  Widget buildPopularList() {
    return FutureBuilder<List<dynamic>>(
      future: popularMovies,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Tidak ada film populer.'));
        }

        var movies = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
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
    );
  }
}