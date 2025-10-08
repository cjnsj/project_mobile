// lib/widgets/popular_movie_card.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../screens/detail_screen.dart';
import '../services/api_service.dart';

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
    return GestureDetector(
      onTap: () {
        // Aksi saat kartu di-tap: Pindah ke DetailScreen dengan mengirim movie id
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(movieId: id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            // Poster
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: CachedNetworkImage(
                imageUrl: ApiService.getImageUrl(posterPath ?? ''),
                width: 100,
                height: 120,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Container(
                  width: 100,
                  height: 120,
                  color: Colors.grey[200],
                  child: const Icon(Icons.movie, size: 40, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Info Film
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '${rating.toStringAsFixed(1)} / 10 IMDb',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Tampilan genre statis, bisa dikembangkan lebih lanjut
                  Text(
                    'Action, Fantasy', // Contoh statis
                    style: TextStyle(color: Colors.grey[700], fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}