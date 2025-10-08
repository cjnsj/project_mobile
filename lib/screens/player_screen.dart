// lib/screens/player_screen.dart

import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';


class PlayerScreen extends StatefulWidget {
  final String videoId;

  const PlayerScreen({super.key, required this.videoId});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller saat halaman dibuka
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true, // Putar video secara otomatis
        mute: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        // Widget utama dari package untuk menampilkan player
        child: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Colors.amber,
          progressColors: const ProgressBarColors(
            playedColor: Colors.amber,
            handleColor: Colors.amberAccent,
          ),
          onReady: () {
            // Logika saat player sudah siap
            print('Player is ready.');
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Pastikan untuk membuang controller saat halaman ditutup
    _controller.dispose();
    super.dispose();
  }
}
