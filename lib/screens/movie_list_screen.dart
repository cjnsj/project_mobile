// lib/screens/movie_list_screen.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/movie_grid_card.dart';

// Enum untuk menentukan tipe daftar yang akan ditampilkan
enum MovieListType { nowShowing, popular, byGenre }

class MovieListScreen extends StatefulWidget {
  final String title;
  final MovieListType type;
  final int? genreId; // Hanya digunakan jika tipenya byGenre

  const MovieListScreen({
    super.key,
    required this.title,
    required this.type,
    this.genreId,
  });

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final ApiService apiService = ApiService();
  final List<dynamic> _movies = [];
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchMovies(); // Memuat data halaman pertama

    // Listener untuk mendeteksi scroll
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent * 0.8 &&
          !_isLoading) {
        _fetchMovies();
      }
    });
  }

  Future<void> _fetchMovies() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      List<dynamic> newMovies;
      switch (widget.type) {
        case MovieListType.nowShowing:
          newMovies = await apiService.getNowShowingMovies(page: _currentPage);
          break;
        case MovieListType.popular:
          newMovies = await apiService.getPopularMovies(page: _currentPage);
          break;
        case MovieListType.byGenre:
          newMovies = await apiService.getMoviesByGenre(
            widget.genreId!,
            page: _currentPage,
          );
          break;
      }

      if (newMovies.isEmpty) {
        _hasMore = false;
      } else {
        _movies.addAll(newMovies);
        _currentPage++;
      }
    } catch (e) {
      // Handle error
      print(e);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // UBAH: Gunakan 2 atau 3 kolom berdasarkan lebar layar
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 3 : 2;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GridView.builder(
        controller: _scrollController,
        // UBAH: Tambahkan padding yang lebih besar di sekeliling grid
        padding: const EdgeInsets.all(16.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          // UBAH: Atur rasio agar kartu terlihat proporsional
          childAspectRatio: 0.6,
          // UBAH: Beri spasi yang lebih besar antar kartu
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _movies.length + (_isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _movies.length) {
            return const Center(child: CircularProgressIndicator());
          }

          var movie = _movies[index];
          return MovieGridCard(
            id: movie['id'],
            posterPath: movie['poster_path'],
            title: movie['title'],
            rating: movie['vote_average'].toDouble(),
          );
        },
      ),
    );
  }
}