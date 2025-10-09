// lib/screens/detail_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:filmku_app/screens/player_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../services/bookmark_service.dart';
import '../services/language_service.dart';
import 'booking_screen.dart'; // <-- Import halaman booking
import 'cast_screen.dart';
import 'movie_list_screen.dart';

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
  late Future<String> movieCertification;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    movieDetail = apiService.getMovieDetail(widget.movieId);
    movieCast = apiService.getMovieCast(widget.movieId);
    movieTrailerKey = apiService.getMovieTrailer(widget.movieId);
    movieCertification = apiService.getMovieCertification(widget.movieId);
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

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
      if (_isBookmarked) {
        BookmarkService.addBookmark(widget.movieId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ditambahkan ke bookmark'),
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        BookmarkService.removeBookmark(widget.movieId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dihapus dari bookmark'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    });
  }

  void _playTrailer() async {
    try {
      final key = await movieTrailerKey;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PlayerScreen(videoId: key)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat trailer: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader(movie),
                    _buildMainInfo(movie),
                    _buildDescription(movie['overview']),
                    _buildCastSection(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                left: 10,
                child: CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.4),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                right: 10,
                child: CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.4),
                  child: IconButton(
                    icon: const Icon(Icons.more_horiz, color: Colors.white),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tombol Opsi Ditekan!')),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> movie) {
    return SizedBox(
      height: 300,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            child: CachedNetworkImage(
              imageUrl: ApiService.getOriginalImageUrl(movie['backdrop_path']),
              fit: BoxFit.cover,
              errorWidget: (context, url, error) =>
                  Container(color: Colors.grey),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              gradient: LinearGradient(
                begin: Alignment.center,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black54],
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _playTrailer,
                  child: const CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: Color(0xFF677EE1),
                      size: 50,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Play Trailer',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainInfo(Map<String, dynamic> movie) {
    String title = movie['title'];
    double rating = movie['vote_average'];
    final List<Map<String, dynamic>> genres = List<Map<String, dynamic>>.from(
      movie['genres'],
    );
    int runtime = movie['runtime'] ?? 0;
    String languageCode = movie['original_language'] ?? 'N/A';
    String languageName = LanguageService().getLanguageName(languageCode);

    String durationFormatted() {
      final hours = runtime ~/ 60;
      final minutes = runtime % 60;
      return '${hours}h ${minutes}min';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  _isBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_outline_rounded,
                  color: _isBookmarked ? const Color(0xFF677EE1) : Colors.grey,
                  size: 28,
                ),
                onPressed: _toggleBookmark,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
              const SizedBox(width: 6),
              Text(
                '${rating.toStringAsFixed(1)}/10 IMDb',
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8.0,
            runSpacing: 6.0,
            children: genres.map((genre) {
              final String genreName = genre['name'] ?? 'Unknown';
              final int? genreId = genre['id'];

              return GestureDetector(
                onTap: () {
                  if (genreId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MovieListScreen(
                          title: genreName,
                          type: MovieListType.byGenre,
                          genreId: genreId,
                        ),
                      ),
                    );
                  }
                },
                child: Chip(
                  label: Text(genreName),
                  backgroundColor: const Color(0xFFE8EAF6),
                  labelStyle: const TextStyle(
                    color: Color(0xFF3F51B5),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: Colors.transparent),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoItem('Length', durationFormatted()),
              _infoItem('Language', languageName),
              FutureBuilder<String>(
                future: movieCertification,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return _infoItem('Rating', snapshot.data!);
                  }
                  return _infoItem('Rating', '...');
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.theaters),
              label: const Text('Beli Tiket'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF3F51B5),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        BookingScreen(movieTitle: movie['title']),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildDescription(String overview) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            overview,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCastSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: FutureBuilder<List<dynamic>>(
        future: movieCast,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox(height: 150);
          }
          if (snapshot.hasError) {
            return const Text('Gagal memuat pemeran.');
          }

          var fullCast = snapshot.data!;
          if (fullCast.isEmpty) {
            return const SizedBox.shrink();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cast',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CastScreen(cast: fullCast),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'See more',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: fullCast.length > 8 ? 8 : fullCast.length,
                  itemBuilder: (context, index) {
                    var actor = fullCast[index];
                    return Container(
                      width: 70,
                      margin: const EdgeInsets.only(right: 16),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 35,
                            backgroundImage: actor['profile_path'] != null
                                ? NetworkImage(
                                    ApiService.getImageUrl(
                                      actor['profile_path'],
                                    ),
                                  )
                                : null,
                            child: actor['profile_path'] == null
                                ? const Icon(Icons.person, size: 35)
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
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
