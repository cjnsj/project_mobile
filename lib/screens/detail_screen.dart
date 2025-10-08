// lib/screens/detail_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../services/bookmark_service.dart';

class DetailScreen extends StatefulWidget {
  final int movieId;

  const DetailScreen({super.key, required this.movieId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final ApiService apiService = ApiService();
  late Future<Map<String, dynamic>> movieDetail;
  late Future<List<dynamic>> movieCast;
  late Future<String> movieTrailerKey;

  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    movieDetail = apiService.getMovieDetail(widget.movieId);
    movieCast = apiService.getMovieCast(widget.movieId);
    movieTrailerKey = apiService.getMovieTrailer(widget.movieId);
    _loadBookmarkStatus();
  }

  void _loadBookmarkStatus() async {
    bool isBookmarked = await BookmarkService.isBookmarked(widget.movieId);
    if (mounted) {
      setState(() {
        _isBookmarked = isBookmarked;
      });
    }
  }

  void _toggleBookmark() async {
    if (_isBookmarked) {
      await BookmarkService.removeBookmark(widget.movieId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dihapus dari bookmark'), duration: Duration(seconds: 1)),
      );
    } else {
      await BookmarkService.addBookmark(widget.movieId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ditambahkan ke bookmark'), duration: Duration(seconds: 1)),
      );
    }
    _loadBookmarkStatus();
  }

  void _playTrailer() async {
    try {
      final key = await movieTrailerKey;
      final youtubeUrl = Uri.parse('https://www.youtube.com/watch?v=$key');

      if (await canLaunchUrl(youtubeUrl)) {
        await launchUrl(youtubeUrl, mode: LaunchMode.externalApplication);
      } else {
        throw 'Tidak bisa membuka URL YouTube';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuka trailer: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: movieDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Data film tidak ditemukan.'));
          }

          var movie = snapshot.data!;
          String backdropUrl = ApiService.getImageUrl(movie['backdrop_path'] ?? '');
          String title = movie['title'];
          double rating = movie['vote_average'];
          List genres = movie['genres'];
          int runtime = movie['runtime'] ?? 0;
          String overview = movie['overview'];

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildHeader(backdropUrl),
                buildMainInfo(title, rating, genres, runtime),
                buildDescription(overview),
                buildCastSection(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildHeader(String backdropUrl) {
    return Stack(
      children: [
        CachedNetworkImage(
          imageUrl: backdropUrl,
          width: double.infinity,
          height: 250,
          fit: BoxFit.cover,
          errorWidget: (context, url, error) => Container(
            height: 250,
            color: Colors.grey,
            child: const Icon(Icons.movie_creation_outlined, color: Colors.white),
          ),
        ),
        Positioned(
          top: 40,
          left: 10,
          child: CircleAvatar(
            backgroundColor: Colors.black.withOpacity(0.5),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        Positioned(
          top: 40,
          right: 10,
          child: CircleAvatar(
            backgroundColor: Colors.black.withOpacity(0.5),
            child: IconButton(
              icon: Icon(
                _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: Colors.white,
              ),
              onPressed: _toggleBookmark,
            ),
          ),
        ),
        Positioned.fill(
          child: Center(
            child: GestureDetector(
              onTap: _playTrailer,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_arrow, color: Colors.white, size: 60),
              ),
            ),
          ),
        ),
      ],
    );
  }

   Widget buildMainInfo(String title, double rating, List genres, int runtime) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text('${rating.toStringAsFixed(1)}/10 IMDb', style: const TextStyle(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: genres.map((genre) => Chip(label: Text(genre['name']))).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              infoItem('Length', '${runtime} min'),
              infoItem('Language', 'English'),
              infoItem('Rating', 'PG-13'),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget infoItem(String title, String value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget buildDescription(String overview) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Description', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            overview,
            textAlign: TextAlign.justify,
            style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget buildCastSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Cast', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 130,
            child: FutureBuilder<List<dynamic>>(
              future: movieCast,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Gagal memuat pemeran.'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Data pemeran tidak tersedia.'));
                }
                
                var cast = snapshot.data!;
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: cast.length > 10 ? 10 : cast.length,
                  itemBuilder: (context, index) {
                    var actor = cast[index];
                    String profileUrl = ApiService.getImageUrl(actor['profile_path'] ?? '');
                    
                    return Container(
                      width: 80,
                      margin: const EdgeInsets.only(right: 12),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: actor['profile_path'] != null
                                ? NetworkImage(profileUrl)
                                : null,
                            child: actor['profile_path'] == null 
                                ? const Icon(Icons.person, size: 40) 
                                : null,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            actor['name'],
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}