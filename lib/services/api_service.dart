// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;


class ApiService {
  // Variabel ini dibuat public agar bisa diakses dari file lain
  static const String apiKey = '895dd7777d25d9011fb9ef7bde76c54d';
  static const String baseUrl = 'https://api.themoviedb.org/3';

  // URL untuk poster kualitas standar (untuk daftar)
  static String getImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return 'https://placehold.co/500x750/e0e0e0/555555?text=No+Image';
    }
    return 'https://image.tmdb.org/t/p/w500$path';
  }

  // URL untuk gambar kualitas original (untuk latar belakang detail)
  static String getOriginalImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return 'https://placehold.co/1280x720/e0e0e0/555555?text=No+Image';
    }
    return 'https://image.tmdb.org/t/p/original$path';
  }

  Future<List<dynamic>> getNowShowingMovies({int page = 1}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/movie/now_playing?api_key=$apiKey&page=$page'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)['results'];
    } else {
      throw Exception('Gagal memuat film "Now Showing"');
    }
  }

  Future<List<dynamic>> getPopularMovies({int page = 1}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/movie/popular?api_key=$apiKey&page=$page'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)['results'];
    } else {
      throw Exception('Gagal memuat film "Popular"');
    }
  }

  Future<Map<String, dynamic>> getMovieDetail(int movieId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/movie/$movieId?api_key=$apiKey'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal memuat detail film.');
    }
  }

  Future<List<dynamic>> getMovieCast(int movieId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/movie/$movieId/credits?api_key=$apiKey'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)['cast'];
    } else {
      throw Exception('Gagal memuat daftar pemeran.');
    }
  }

  Future<String> getMovieTrailer(int movieId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/movie/$movieId/videos?api_key=$apiKey'),
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

  Future<List<dynamic>> searchMovies(String query) async {
    if (query.isEmpty) {
      return [];
    }
    final response = await http.get(
      Uri.parse('$baseUrl/search/movie?api_key=$apiKey&query=$query'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['results'];
    } else {
      throw Exception('Gagal mencari film.');
    }
  }

  // Tambahkan fungsi baru ini di dalam class ApiService

  Future<String> getMovieCertification(int movieId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/movie/$movieId/release_dates?api_key=$apiKey'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;

      // Cari data untuk wilayah US (Amerika Serikat)
      var usRelease = results.firstWhere(
        (release) => release['iso_3166_1'] == 'US',
        orElse: () => null,
      );

      if (usRelease != null) {
        // Cari rating (certification) yang tidak kosong
        var certification = usRelease['release_dates'].firstWhere(
          (date) => date['certification'] != '',
          orElse: () => null,
        )?['certification'];
        return certification ?? 'N/A'; // Kembalikan N/A jika tidak ditemukan
      }
      return 'N/A';
    } else {
      throw Exception('Gagal memuat rating film.');
    }
  }

  Future<List<dynamic>> getMoviesByGenre(int genreId, {int page = 1}) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/discover/movie?api_key=$apiKey&with_genres=$genreId&page=$page',
      ),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)['results'];
    } else {
      throw Exception('Gagal memuat film berdasarkan genre.');
    }
  }

  // TAMBAHKAN FUNGSI BARU INI
  Future<List<dynamic>> getUpcomingMovies({int page = 1}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/movie/upcoming?api_key=$apiKey&page=$page'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)['results'];
    } else {
      throw Exception('Gagal memuat film "Upcoming"');
    }
  }

}
