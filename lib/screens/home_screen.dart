// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'movie_list_screen.dart';
import 'notifications_screen.dart'; // TAMBAHKAN: Import halaman notifikasi yang baru dibuat
import '../services/api_service.dart';
import '../widgets/movie_card.dart'; // <-- TAMBAHKAN BARIS INI
import '../widgets/popular_movie_card.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService apiService = ApiService();
  late Future<List<dynamic>> nowShowingMovies;
  late Future<List<dynamic>> popularMovies;

  @override
  void initState() {
    super.initState();
    nowShowingMovies = apiService.getNowShowingMovies(page: 1);
    popularMovies = apiService.getPopularMovies(page: 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // TAMBAHKAN: Drawer untuk menu samping
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF3F51B5), // Warna biru indigo
              ),
              child: Text(
                'FilmKu Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context); // Tutup drawer
                // TODO: Tambahkan navigasi ke halaman profil
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context); // Tutup drawer
                // TODO: Tambahkan navigasi ke halaman pengaturan
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // UBAH: Hapus 'leading' agar Flutter otomatis menampilkan ikon menu drawer
        title: const Text(
          'FilmKu',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        // UBAH: Beri fungsi pada tombol notifikasi
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none,
              color: Colors.black,
              size: 28,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildSectionTitle('Now Showing', MovieListType.nowShowing),
            buildNowShowingList(),
            const SizedBox(height: 20),
            buildSectionTitle('Popular', MovieListType.popular),
            buildPopularList(),
          ],
        ),
      ),
    );
  }

  Widget buildSectionTitle(String title, MovieListType type) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      MovieListScreen(title: title, type: type),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'See more',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ),
        ],
      ),
    );
  }

   Widget buildNowShowingList() {
    final screenHeight = MediaQuery.of(context).size.height;
    return SizedBox(
      // UBAH: Kurangi tinggi kontainer agar sesuai dengan rasio kartu yang baru
      height: 220, // Anda bisa menyesuaikan angka ini (misalnya 220 atau 230)
      child: FutureBuilder<List<dynamic>>(
        future: nowShowingMovies,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada film yang tayang.'));
          }

          var movies = snapshot.data!;
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: movies.length,
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            itemBuilder: (context, index) {
              var movie = movies[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: MovieCard(
                  id: movie['id'],
                  posterPath: movie['poster_path'],
                  title: movie['title'],
                  rating: movie['vote_average'].toDouble(),
                ),
              );
            },
          );
        },
      ),
    );
  }
  Widget buildPopularList() {
    return FutureBuilder<List<dynamic>>(
      future: popularMovies,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Tidak ada film populer.'));
        }

        var movies = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: movies.length,
          itemBuilder: (context, index) {
            var movie = movies[index];
            return PopularMovieCard(
              id: movie['id'],
              posterPath: movie['poster_path'],
              title: movie['title'],
              rating: movie['vote_average'].toDouble(),
              genreIds: List<int>.from(movie['genre_ids']),
            );
          },
        );
      },
    );
  }
}
