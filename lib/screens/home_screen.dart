// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'movie_list_screen.dart';
import '../services/api_service.dart';
import '../widgets/movie_card.dart';
import '../widgets/popular_movie_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService apiService = ApiService();
  late Future<List<dynamic>> nowShowingMovies;
  late Future<List<dynamic>> popularMovies;

  @override
  void initState() {
    super.initState();
    nowShowingMovies = apiService.getNowShowingMovies();
    popularMovies = apiService.getPopularMovies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const IconButton(
          icon: Icon(Icons.menu, color: Colors.black),
          onPressed: null,
        ),
        title: const Text(
          'FilmKu',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
        actions: const [
          IconButton(
            icon: Icon(Icons.notifications_none, color: Colors.black, size: 28),
            onPressed: null,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Bagian "Now Showing" ---
            buildSectionTitle('Now Showing', nowShowingMovies),
            buildNowShowingList(),
            
            const SizedBox(height: 20),

            // --- Bagian "Popular" ---
            buildSectionTitle('Popular', popularMovies),
            buildPopularList(),
          ],
        ),
      ),
    );
  }

  // Widget untuk judul section dengan "See more" yang bisa diklik
  Widget buildSectionTitle(String title, Future<List<dynamic>> movieFuture) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          InkWell(
            onTap: () {
              // Aksi navigasi saat "See more" di-tap
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MovieListScreen(
                    title: title,
                    movieFuture: movieFuture,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'See more',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk daftar "Now Showing"
  Widget buildNowShowingList() {
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      height: screenHeight * 0.38,
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