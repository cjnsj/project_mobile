// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _apiKey =
      '895dd7777d25d9011fb9ef7bde76c54d'; // API Key Anda
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  // Fungsi untuk mendapatkan URL gambar poster dengan ukuran w500
  static String getImageUrl(String path) {
    return 'https://image.tmdb.org/t/p/w500$path';
  }

  // Fungsi untuk mengambil film yang sedang tayang ("Now Showing")
  Future<List<dynamic>> getNowShowingMovies() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/movie/now_playing?api_key=$_apiKey'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)['results'];
    } else {
      throw Exception('Gagal memuat film "Now Showing"');
    }
  }

  // Fungsi untuk mengambil film populer ("Popular")
  Future<List<dynamic>> getPopularMovies() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/movie/popular?api_key=$_apiKey'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)['results'];
    } else {
      throw Exception('Gagal memuat film "Popular"');
    }
  }

  // Fungsi untuk mengambil detail film berdasarkan ID
  Future<Map<String, dynamic>> getMovieDetail(int movieId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/movie/$movieId?api_key=$_apiKey'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal memuat detail film.');
    }
  }

  // Fungsi untuk mengambil daftar pemeran (cast) film
  Future<List<dynamic>> getMovieCast(int movieId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/movie/$movieId/credits?api_key=$_apiKey'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)['cast'];
    } else {
      throw Exception('Gagal memuat daftar pemeran.');
    }
  }

  // Fungsi untuk mendapatkan kunci video trailer dari YouTube
  Future<String> getMovieTrailer(int movieId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/movie/$movieId/videos?api_key=$_apiKey'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;

      final officialTrailer = results.firstWhere(
        (video) => video['site'] == 'YouTube' && video['type'] == 'Trailer',
        orElse: () => null,
      );

      if (officialTrailer != null) {
        return officialTrailer['key'];
      } else {
        final anyTrailer = results.firstWhere(
          (video) => video['site'] == 'YouTube',
          orElse: () => null,
        );
        if (anyTrailer != null) {
          return anyTrailer['key'];
        }
      }

      throw Exception('Trailer tidak ditemukan.');
    } else {
      throw Exception('Gagal memuat video trailer.');
    }
  }

  // Fungsi untuk mencari film berdasarkan query
  Future<List<dynamic>> searchMovies(String query) async {
    if (query.isEmpty) {
      return []; // Kembalikan list kosong jika query kosong
    }
    final response = await http.get(
      Uri.parse('$_baseUrl/search/movie?api_key=$_apiKey&query=$query'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['results'];
    } else {
      throw Exception('Gagal mencari film.');
    }
  }
}
