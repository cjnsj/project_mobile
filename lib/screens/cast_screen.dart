// lib/screens/cast_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CastScreen extends StatelessWidget {
  final List<dynamic> cast;

  const CastScreen({super.key, required this.cast});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Cast'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // Tampilkan 3 aktor per baris
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 0.6, // Sesuaikan rasio untuk foto dan nama
        ),
        itemCount: cast.length,
        itemBuilder: (context, index) {
          var actor = cast[index];
          return Column(
            children: [
              // Foto Aktor
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: CachedNetworkImage(
                    imageUrl: ApiService.getImageUrl(actor['profile_path']),
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.person, color: Colors.grey, size: 40),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Nama Aktor
              Text(
                actor['name'] ?? 'Unknown',
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          );
        },
      ),
    );
  }
}