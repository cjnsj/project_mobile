// lib/screens/ticket_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/ticket_history_service.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  late Future<List<Map<String, dynamic>>> _historyFuture;
  late StreamSubscription _ticketSubscription;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    // Dengarkan perubahan agar UI otomatis refresh saat ada tiket baru
    _ticketSubscription = TicketHistoryService.stream.listen((_) {
      _loadHistory();
    });
  }

  void _loadHistory() {
    setState(() {
      _historyFuture = TicketHistoryService.getTicketHistory();
    });
  }

  @override
  void dispose() {
    _ticketSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tickets'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Gagal memuat riwayat tiket.'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_activity_outlined, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Anda belum memiliki tiket.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final history = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final ticket = history[index];
              final purchaseDate = DateTime.parse(ticket['purchaseDate']);
              final formattedDate = DateFormat('d MMMM yyyy, HH:mm').format(purchaseDate);

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticket['movieTitle'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(ticket['cinemaName']),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Kursi: ${(ticket['seats'] as List).join(', ')}'),
                          Text(
                            'Rp ${ticket['totalPrice'].toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tgl: $formattedDate',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}