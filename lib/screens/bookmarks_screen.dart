// lib/screens/bookmarks_screen.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/bookmark_service.dart';
import '../widgets/popular_movie_card.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  final ApiService apiService = ApiService();
  
  late Future<List<Map<String, dynamic>>> _bookmarkedMovies;

  @override
  void initState() {
    super.initState();
    _loadBookmarkedMovies();
  }

  void _loadBookmarkedMovies() {
    setState(() {
      _bookmarkedMovies = _fetchBookmarkedMovieDetails();
    });
  }

  Future<List<Map<String, dynamic>>> _fetchBookmarkedMovieDetails() async {
    final List<int> bookmarkedIds = await BookmarkService.getBookmarks();
    if (bookmarkedIds.isEmpty) {
      return [];
    }
    
    final List<Future<Map<String, dynamic>>> movieFutures =
        bookmarkedIds.map((id) => apiService.getMovieDetail(id)).toList();
    return Future.wait(movieFutures);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Bookmarks',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _bookmarkedMovies,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_remove_rounded, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Anda belum memiliki bookmark.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          var movies = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async {
              _loadBookmarkedMovies();
            },
            child: ListView.builder(
              itemCount: movies.length,
              itemBuilder: (context, index) {
                var movie = movies[index];
                return PopularMovieCard(
                  id: movie['id'],
                  posterPath: movie['poster_path'],
                  title: movie['title'],
                  rating: movie['vote_average'].toDouble(),
                  genreIds: List<int>.from(movie['genres'].map((g) => g['id'])),
                );
              },
            ),
          );
        },
      ),
    );
  }
}