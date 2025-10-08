// lib/screens/movie_list_screen.dart

import 'package:flutter/material.dart';
import '../widgets/movie_card.dart'; // Kita gunakan ulang MovieCard

class MovieListScreen extends StatelessWidget {
  final String title;
  final Future<List<dynamic>> movieFuture;

  const MovieListScreen({
    super.key,
    required this.title,
    required this.movieFuture,
  });

  @override
  Widget build(BuildContext context) {
    // Menghitung jumlah kolom grid berdasarkan lebar layar
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = (screenWidth / 170).floor(); // 170 adalah perkiraan lebar per kartu

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: movieFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada film untuk ditampilkan.'));
          }

          var movies = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(10.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount, // Jumlah kolom dinamis
              childAspectRatio: 0.52, // Rasio aspek kartu (lebar/tinggi)
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: movies.length,
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
}