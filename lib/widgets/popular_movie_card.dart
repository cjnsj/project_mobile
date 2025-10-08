// lib/widgets/popular_movie_card.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../screens/detail_screen.dart';
import '../services/api_service.dart';
import '../services/genre_service.dart';

class PopularMovieCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // Ambil 2 nama genre pertama dari service
    final genreNames = GenreService().getGenreNames(genreIds).take(2).toList();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(movieId: id),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            // Poster
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: CachedNetworkImage(
                imageUrl: ApiService.getImageUrl(posterPath ?? ''),
                width: 80,
                height: 100,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Container(
                  width: 80,
                  height: 100,
                  color: Colors.grey[200],
                  child: const Icon(Icons.movie, size: 40, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Info Film
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '${rating.toStringAsFixed(1)} / 10 IMDb',
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Tampilan "Genre Pills" yang dinamis
                  if (genreNames.isNotEmpty)
                    Wrap(
                      spacing: 8.0,
                      children: genreNames.map((name) => Chip(
                        label: Text(name),
                        backgroundColor: const Color(0xFFE3F2FD), // Warna biru muda
                        labelStyle: const TextStyle(color: Color(0xFF1E88E5), fontSize: 10, fontWeight: FontWeight.bold), // Warna biru
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                        shape: const StadiumBorder(side: BorderSide(color: Colors.transparent)),
                      )).toList(),
                    ),
                  
                  // CATATAN: Durasi film tidak ditampilkan karena alasan performa
                  // seperti yang dijelaskan sebelumnya.
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
