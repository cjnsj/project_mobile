// lib/screens/player_screen.dart

import 'dart:async';
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
  bool _isControlsVisible = true;
  Timer? _controlsTimer;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    )..addListener(_playerListener); // Menambahkan listener
  }

  // Listener untuk memantau status pemutar video
  void _playerListener() {
    if (mounted) {
      // 1. KEMBALI OTOMATIS SAAT VIDEO SELESAI
      if (_controller.value.playerState == PlayerState.ended) {
        Navigator.of(context).pop();
      }

      // Selalu tampilkan kontrol jika video dijeda atau buffering
      if (_controller.value.playerState != PlayerState.playing) {
        if (!_isControlsVisible) {
          setState(() {
            _isControlsVisible = true;
          });
        }
      }
    }
  }

  // Fungsi untuk menampilkan tombol "X"
  void _toggleControls() {
    setState(() {
      _isControlsVisible = true;
    });
    // Mulai timer untuk menyembunyikannya kembali
    _startControlsTimer();
  }

  // Timer untuk menyembunyikan tombol "X" setelah 3 detik
  void _startControlsTimer() {
    _controlsTimer?.cancel(); // Batalkan timer sebelumnya
    _controlsTimer = Timer(const Duration(seconds: 3), () {
      // Sembunyikan tombol HANYA JIKA video sedang diputar
      if (mounted && _controller.value.playerState == PlayerState.playing) {
        setState(() {
          _isControlsVisible = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // Gunakan YoutubePlayerBuilder untuk menempatkan UI di atas video
      body: YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Colors.amber,
          progressColors: const ProgressBarColors(
            playedColor: Colors.amber,
            handleColor: Colors.amberAccent,
          ),
          onReady: () {
            // Saat video siap, mulai timer untuk menyembunyikan tombol
            _startControlsTimer();
          },
        ),
        builder: (context, player) {
          return SafeArea(
            child: Stack(
              children: [
                // Deteksi ketukan di seluruh area untuk menampilkan tombol
                GestureDetector(
                  onTap: _toggleControls,
                  child: Center(child: player),
                ),
                // 2. TOMBOL "X" INTERAKTIF
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _isControlsVisible ? 1.0 : 0.0,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 30),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_playerListener);
    _controller.dispose();
    _controlsTimer?.cancel();
    super.dispose();
  }
}