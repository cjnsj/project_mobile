// lib/screens/seat_selection_screen.dart

import 'package:flutter/material.dart';
import 'checkout_screen.dart';

class SeatSelectionScreen extends StatefulWidget {
  final String movieTitle;
  final String cinemaName;
  final String time;

  const SeatSelectionScreen({
    super.key,
    required this.movieTitle,
    required this.cinemaName,
    required this.time,
  });

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  // Set untuk menyimpan kursi yang dipilih (menggunakan Set agar tidak ada duplikat)
  final Set<String> _selectedSeats = {};
  // Daftar kursi yang sudah dipesan (dummy)
  final List<String> _bookedSeats = ['A3', 'A4', 'C5', 'D1', 'D2', 'F8'];

  // Fungsi untuk membangun satu kursi
  Widget _buildSeat(int row, int number) {
    final seatId = '${String.fromCharCode(65 + row)}$number';
    final isBooked = _bookedSeats.contains(seatId);
    final isSelected = _selectedSeats.contains(seatId);

    Color seatColor = Colors.grey.shade300; // Tersedia
    if (isBooked) {
      seatColor = Colors.red.shade200; // Dipesan
    } else if (isSelected) {
      seatColor = const Color(0xFF3F51B5); // Dipilih
    }

    return GestureDetector(
      onTap: isBooked
          ? null // Jangan lakukan apa-apa jika kursi sudah dipesan
          : () {
              setState(() {
                if (isSelected) {
                  _selectedSeats.remove(seatId);
                } else {
                  _selectedSeats.add(seatId);
                }
              });
            },
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: seatColor,
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Kursi'),
      ),
      body: Column(
        children: [
          // Layar Bioskop
          Container(
            margin: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Container(
                  width: 250,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const Text('Layar Bioskop'),
              ],
            ),
          ),
          // Grid Kursi
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8, // 8 kursi per baris
              ),
              itemCount: 8 * 8, // 8 baris x 8 kursi
              itemBuilder: (context, index) {
                final row = index ~/ 8;
                final number = (index % 8) + 1;
                return _buildSeat(row, number);
              },
            ),
          ),
          // Tombol Lanjut
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _selectedSeats.isNotEmpty
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CheckoutScreen(
                              movieTitle: widget.movieTitle,
                              cinemaName: widget.cinemaName,
                              time: widget.time,
                              selectedSeats: _selectedSeats.toList(),
                            ),
                          ),
                        );
                      }
                    : null, // Nonaktifkan tombol jika tidak ada kursi yang dipilih
                child: Text('Lanjut (${_selectedSeats.length} kursi)'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}