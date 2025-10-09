// lib/widgets/popular_movie_card.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import '../screens/detail_screen.dart';
import '../screens/movie_list_screen.dart';
import '../services/api_service.dart';
import '../services/genre_service.dart';

class PopularMovieCard extends StatefulWidget {
  final int id;
  final String? posterPath;
  final String title;
  final double rating;
  final List<int> genreIds;

  const PopularMovieCard({
    super.key,
    required this.id,
    required this.posterPath,
    required this.title,
    required this.rating,
    required this.genreIds,
  });

  @override
  State<PopularMovieCard> createState() => _PopularMovieCardState();
}

class _PopularMovieCardState extends State<PopularMovieCard> {
  late Future<Map<String, dynamic>> _movieDetailFuture;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _movieDetailFuture = apiService.getMovieDetail(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    final genreData = widget.genreIds
        .map((id) {
          final genreName = GenreService().getGenreNames([id]);
          return genreName.isNotEmpty
              ? {'id': id, 'name': genreName.first}
              : null;
        })
        .where((genre) => genre != null)
        .take(2)
        .toList();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(movieId: widget.id),
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 5,
        // UBAH: Bungkus Row dengan Padding untuk memberi spasi
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            // UBAH: Atur crossAxisAlignment untuk menengahkan
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Gambar poster
              SizedBox(
                width: 80,
                height: 110,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: CachedNetworkImage(
                    imageUrl: ApiService.getImageUrl(widget.posterPath),
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.movie, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Bagian detail film
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // Agar Column tidak meregang penuh
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.rating.toStringAsFixed(1)} / 10 IMDb',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (genreData.isNotEmpty)
                      Wrap(
                        spacing: 6.0,
                        children: genreData.map((genre) {
                          return Chip(
                            label: Text(genre!['name'] as String),
                            backgroundColor: const Color(0xFFE8EAF6),
                            labelStyle: const TextStyle(
                              color: Color(0xFF3F51B5),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 8),
                    FutureBuilder<Map<String, dynamic>>(
                      future: _movieDetailFuture,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final runtime = snapshot.data?['runtime'] ?? 0;
                          if (runtime > 0) {
                            final hours = runtime ~/ 60;
                            final minutes = runtime % 60;
                            final durationString = '${hours}h ${minutes}min';

                            return Row(
                              children: [
                                Icon(
                                  EvaIcons.clockOutline,
                                  color: Colors.grey.shade600,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  durationString,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            );
                          }
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ));
  }
}