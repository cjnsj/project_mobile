// lib/services/language_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class LanguageService {
  static final LanguageService _instance = LanguageService._internal();
  factory LanguageService() => _instance;
  LanguageService._internal();

  final Map<String, String> _languageMap = {};

  Future<void> loadLanguages() async {
    if (_languageMap.isNotEmpty) return;

    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/configuration/languages?api_key=${ApiService.apiKey}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> languages = json.decode(response.body);
        for (var lang in languages) {
          _languageMap[lang['iso_639_1']] = lang['english_name'];
        }
        print('Languages loaded successfully.');
      } else {
        throw Exception('Failed to load languages');
      }
    } catch (e) {
      print('Error loading languages: $e');
    }
  }

  String getLanguageName(String isoCode) {
    return _languageMap[isoCode] ?? isoCode.toUpperCase();
  }
}