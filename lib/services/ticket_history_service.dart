// lib/services/ticket_history_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TicketHistoryService {
  static const _key = 'ticketHistory';

  // Stream untuk memberi sinyal saat ada tiket baru
  static final _controller = StreamController<void>.broadcast();
  static Stream<void> get stream => _controller.stream;

  // Menambahkan tiket baru ke riwayat
  static Future<void> addTicket(Map<String, dynamic> ticketData) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> history = prefs.getStringList(_key) ?? [];
    
    // Tambahkan data tiket baru sebagai string JSON
    history.add(json.encode(ticketData));
    
    await prefs.setStringList(_key, history);
    _controller.add(null); // Kirim sinyal bahwa ada data baru
  }

  // Mengambil semua riwayat tiket
  static Future<List<Map<String, dynamic>>> getTicketHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> history = prefs.getStringList(_key) ?? [];
    
    // Ubah kembali string JSON menjadi List<Map>
    return history.map((ticketString) {
      return json.decode(ticketString) as Map<String, dynamic>;
    }).toList().reversed.toList(); // reversed agar tiket terbaru di atas
  }
}