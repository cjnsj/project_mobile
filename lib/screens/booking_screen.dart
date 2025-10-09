// lib/screens/booking_screen.dart

import 'package:flutter/material.dart';
import 'seat_selection_screen.dart';

class BookingScreen extends StatelessWidget {
  final String movieTitle;

  const BookingScreen({super.key, required this.movieTitle});

  @override
  Widget build(BuildContext context) {
    // Data bioskop dan jadwal dummy
    final List<Map<String, dynamic>> cinemas = [
      {
        'name': 'Cinema XXI - Panakkukang Mall',
        'times': ['12:30', '14:45', '17:00', '19:15', '21:30']
      },
      {
        'name': 'CGV - Trans Studio Mall',
        'times': ['13:00', '15:20', '17:40', '20:00', '22:20']
      },
      {
        'name': 'Cinépolis - Phinisi Point',
        'times': ['12:00', '14:15', '16:30', '18:45', '21:00']
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Pilih Jadwal - $movieTitle'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: cinemas.length,
        itemBuilder: (context, index) {
          final cinema = cinemas[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cinema['name'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: (cinema['times'] as List<String>).map((time) {
                      return ActionChip(
                        label: Text(time),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SeatSelectionScreen(
                                movieTitle: movieTitle,
                                cinemaName: cinema['name'],
                                time: time,
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}