// lib/services/bookmark_service.dart

import 'dart:async'; // TAMBAHKAN: Import untuk StreamController
import 'package:shared_preferences/shared_preferences.dart';

class BookmarkService {
  static const _key = 'bookmarkedMovies';

  // TAMBAHKAN: StreamController untuk menyiarkan perubahan
  static final _bookmarksChangedController = StreamController<void>.broadcast();
  static Stream<void> get bookmarksStream => _bookmarksChangedController.stream;

  // Mendapatkan daftar ID film yang di-bookmark
  static Future<List<int>> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? bookmarkedIds = prefs.getStringList(_key);
    return bookmarkedIds?.map((id) => int.parse(id)).toList() ?? [];
  }

  // Menambahkan bookmark
  static Future<void> addBookmark(int movieId) async {
    final prefs = await SharedPreferences.getInstance();
    List<int> bookmarks = await getBookmarks();
    if (!bookmarks.contains(movieId)) {
      bookmarks.add(movieId);
      await prefs.setStringList(_key, bookmarks.map((id) => id.toString()).toList());
      _bookmarksChangedController.add(null); // UBAH: Kirim sinyal perubahan
    }
  }

  // Menghapus bookmark
  static Future<void> removeBookmark(int movieId) async {
    final prefs = await SharedPreferences.getInstance();
    List<int> bookmarks = await getBookmarks();
    if (bookmarks.contains(movieId)) {
      bookmarks.remove(movieId);
      await prefs.setStringList(_key, bookmarks.map((id) => id.toString()).toList());
      _bookmarksChangedController.add(null); // UBAH: Kirim sinyal perubahan
    }
  }

  // Mengecek apakah sebuah film sudah di-bookmark
  static Future<bool> isBookmarked(int movieId) async {
    List<int> bookmarks = await getBookmarks();
    return bookmarks.contains(movieId);
  }
}