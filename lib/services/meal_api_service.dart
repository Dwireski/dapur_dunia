import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/meal.dart';
import '../models/meal_category.dart';

/// Kesalahan yang sudah diterjemahkan menjadi pesan yang mudah dipahami
/// pengguna. Pesan ini langsung ditampilkan pada kondisi error di UI.
class ApiException implements Exception {
  final String message;

  const ApiException(this.message);

  @override
  String toString() => message;
}

/// Lapisan akses data ke TheMealDB (https://www.themealdb.com/api.php).
class MealApiService {
  MealApiService({http.Client? client}) : _client = client ?? http.Client();

  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';
  static const Duration _timeout = Duration(seconds: 15);

  final http.Client _client;

  /// Daftar kategori resep (Beef, Chicken, Dessert, dan seterusnya).
  Future<List<MealCategory>> fetchCategories() async {
    final json = await _getJson('categories.php');
    final list = json['categories'];
    if (list is! List) return const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(MealCategory.fromJson)
        .toList();
  }

  /// Mencari resep berdasarkan nama.
  Future<List<Meal>> searchMeals(String query) async {
    final json = await _getJson('search.php', {'s': query});
    return _parseMeals(json);
  }

  /// Daftar resep pada satu kategori (data ringkas: id, nama, gambar).
  Future<List<Meal>> fetchMealsByCategory(String category) async {
    final json = await _getJson('filter.php', {'c': category});
    return _parseMeals(json);
  }

  /// Detail lengkap satu resep berdasarkan id.
  Future<Meal> fetchMealDetail(String id) async {
    final json = await _getJson('lookup.php', {'i': id});
    final meals = _parseMeals(json);
    if (meals.isEmpty) {
      throw const ApiException('Resep tidak ditemukan.');
    }
    return meals.first;
  }

  /// Satu resep acak.
  Future<Meal> fetchRandomMeal() async {
    final json = await _getJson('random.php');
    final meals = _parseMeals(json);
    if (meals.isEmpty) {
      throw const ApiException('Resep acak tidak tersedia saat ini.');
    }
    return meals.first;
  }

  void dispose() => _client.close();

  /// API mengembalikan `{"meals": null}` (atau string) bila tidak ada hasil,
  /// sehingga nilai selain List diperlakukan sebagai daftar kosong.
  List<Meal> _parseMeals(Map<String, dynamic> json) {
    final list = json['meals'];
    if (list is! List) return const [];
    return list.whereType<Map<String, dynamic>>().map(Meal.fromJson).toList();
  }

  /// Mengirim permintaan GET, memeriksa status respons, lalu mengurai JSON.
  Future<Map<String, dynamic>> _getJson(
    String endpoint, [
    Map<String, String>? query,
  ]) async {
    final uri =
        Uri.parse('$_baseUrl/$endpoint').replace(queryParameters: query);

    try {
      final response = await _client.get(uri).timeout(_timeout);

      if (response.statusCode != 200) {
        throw ApiException(
          'Server mengembalikan status ${response.statusCode}.',
        );
      }

      final body = utf8.decode(response.bodyBytes).trim();
      if (body.isEmpty) return {'meals': null};

      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Respons bukan objek JSON.');
      }
      return decoded;
    } on SocketException {
      throw const ApiException(
        'Tidak ada koneksi internet. Periksa jaringan Anda.',
      );
    } on TimeoutException {
      throw const ApiException('Waktu permintaan habis. Silakan coba lagi.');
    } on http.ClientException {
      throw const ApiException('Gagal terhubung ke server.');
    } on FormatException {
      throw const ApiException(
        'Format data dari server tidak dapat diproses.',
      );
    }
  }
}
