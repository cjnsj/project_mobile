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
        leading: const IconButton(
          icon: Icon(Icons.menu),
          onPressed: null,
        ),
        title: const Text('FilmKu'),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(Icons.notifications_none, size: 28),
              onPressed: null,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            buildSectionTitle('Now Showing', nowShowingMovies, false),
            buildNowShowingList(),
            const SizedBox(height: 24),
            buildSectionTitle('Popular', popularMovies, true),
            buildPopularList(),
          ],
        ),
      ),
    );
  }

  Widget buildSectionTitle(String title, Future<List<dynamic>> movieFuture, bool isChip) {
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
            child: Container(
              padding: isChip
                  ? const EdgeInsets.symmetric(horizontal: 12, vertical: 6)
                  : const EdgeInsets.all(8.0),
              decoration: isChip
                  ? BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(20),
                    )
                  : null,
              child: Text(
                'See more',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNowShowingList() {
    return SizedBox(
      height: 280, // Disesuaikan untuk memberi ruang pada teks
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemBuilder: (context, index) {
              var movie = movies[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: MovieCard(
                  id: movie['id'],
                  posterPath: movie['poster_path'],
                  title: movie['title'],
                  rating: movie['vote_average'].toDouble(),
                ),
              );
            },
          );
        },
      ),
    );
  }

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
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemCount: movies.length,
          itemBuilder: (context, index) {
            var movie = movies[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
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
      },
    );
  }
}
