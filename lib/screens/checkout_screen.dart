// lib/screens/checkout_screen.dart

import 'package:flutter/material.dart';
import '../services/ticket_history_service.dart';
import 'main_screen.dart';

class CheckoutScreen extends StatelessWidget {
  final String movieTitle;
  final String cinemaName;
  final String time;
  final List<String> selectedSeats;

  const CheckoutScreen({
    super.key,
    required this.movieTitle,
    required this.cinemaName,
    required this.time,
    required this.selectedSeats,
  });

  @override
  Widget build(BuildContext context) {
    final double ticketPrice = 45000; // Harga dummy per tiket
    final total = ticketPrice * selectedSeats.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ringkasan Pesanan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              movieTitle,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.movie, cinemaName),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.access_time, 'Hari ini, $time'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.event_seat, 'Kursi: ${selectedSeats.join(', ')}'),
            const Divider(height: 40),
            const Text(
              'Detail Pembayaran',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildPriceRow('Harga Tiket (${selectedSeats.length}x)', 'Rp ${total.toStringAsFixed(0)}'),
            const SizedBox(height: 8),
            _buildPriceRow('Biaya Layanan', 'Rp 3000'),
            const Divider(height: 30),
            _buildPriceRow(
              'Total Bayar',
              'Rp ${(total + 3000).toStringAsFixed(0)}',
              isTotal: true,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF3F51B5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  // Data yang akan disimpan
                  final ticketData = {
                    'movieTitle': movieTitle,
                    'cinemaName': cinemaName,
                    'time': time,
                    'seats': selectedSeats,
                    'totalPrice': total + 3000,
                    'purchaseDate': DateTime.now().toIso8601String(),
                  };

                  // Panggil service untuk menyimpan tiket
                  await TicketHistoryService.addTicket(ticketData);

                  // Tampilkan dialog sukses
                  if (context.mounted) {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Pembayaran Berhasil!'),
                        content: const Text('E-tiket Anda telah disimpan di menu Tickets.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              // Kembali ke halaman utama setelah sukses
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (c) => const MainScreen()),
                                (route) => false,
                              );
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: const Text('Bayar Sekarang'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
      ],
    );
  }

  Widget _buildPriceRow(String title, String price, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.black : Colors.grey.shade700,
          ),
        ),
        Text(
          price,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}