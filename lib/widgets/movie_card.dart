// lib/widgets/movie_card.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../screens/detail_screen.dart';
import '../services/api_service.dart';

class MovieCard extends StatelessWidget {
  final int id;
  final String? posterPath;
  final String title;
  final double rating;

  const MovieCard({
    super.key,
    required this.id,
    required this.posterPath,
    required this.title,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailScreen(movieId: id)),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar akan mengisi semua ruang vertikal yang tersedia
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: CachedNetworkImage(
                imageUrl: ApiService.getImageUrl(posterPath ?? ''),
                width: double.infinity,
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
          const SizedBox(height: 8),

          // Teks Judul
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 4),

          // Teks Rating
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${rating.toStringAsFixed(1)} / 10 IMDb',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
