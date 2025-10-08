// lib/services/genre_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart'; // Mengimpor file api_service

class GenreService {
  static final GenreService _instance = GenreService._internal();
  factory GenreService() => _instance;
  GenreService._internal();

  final Map<int, String> _genreMap = {};

  Future<void> loadGenres() async {
    if (_genreMap.isNotEmpty) return;

    try {
      // Gunakan nama variabel yang sudah public
      final response = await http.get(
        Uri.parse(
          '${ApiService.baseUrl}/genre/movie/list?api_key=${ApiService.apiKey}',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        for (var genre in data['genres']) {
          if (genre['id'] != null && genre['name'] != null) {
            _genreMap[genre['id']] = genre['name'];
          }
        }
        print('Genres loaded successfully.');
      } else {
        throw Exception('Failed to load genres');
      }
    } catch (e) {
      print('Error loading genres: $e');
    }
  }

  List<String> getGenreNames(List<int> ids) {
    return ids
        .map((id) => _genreMap[id] ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
  }
}
