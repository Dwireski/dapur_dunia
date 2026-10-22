import 'dart:async';
import 'dart:io';

import 'package:dapur_dunia/services/meal_api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('MealApiService', () {
    test('searchMeals mengembalikan daftar Meal saat respons 200', () async {
      final client = MockClient((request) async {
        expect(request.url.path, '/api/json/v1/1/search.php');
        expect(request.url.queryParameters['s'], 'pasta');
        return http.Response(
          '{"meals":[{"idMeal":"1","strMeal":"Spaghetti",'
          '"strMealThumb":"https://example.com/s.jpg"}]}',
          200,
        );
      });
      final service = MealApiService(client: client);

      final meals = await service.searchMeals('pasta');

      expect(meals.length, 1);
      expect(meals.first.name, 'Spaghetti');
    });

    test('mengembalikan daftar kosong saat meals bernilai null', () async {
      final client = MockClient(
        (request) async => http.Response('{"meals":null}', 200),
      );
      final service = MealApiService(client: client);

      expect(await service.searchMeals('zzzz'), isEmpty);
    });

    test('fetchMealsByCategory memakai endpoint filter.php', () async {
      final client = MockClient((request) async {
        expect(request.url.path, '/api/json/v1/1/filter.php');
        expect(request.url.queryParameters['c'], 'Seafood');
        return http.Response('{"meals":[]}', 200);
      });
      final service = MealApiService(client: client);

      expect(await service.fetchMealsByCategory('Seafood'), isEmpty);
    });

    test('fetchMealDetail melempar ApiException bila resep tidak ada', () async {
      final client = MockClient(
        (request) async => http.Response('{"meals":null}', 200),
      );
      final service = MealApiService(client: client);

      await expectLater(
        service.fetchMealDetail('0'),
        throwsA(isA<ApiException>()),
      );
    });

    test('melempar ApiException saat status bukan 200', () async {
      final client = MockClient(
        (request) async => http.Response('Server Error', 500),
      );
      final service = MealApiService(client: client);

      await expectLater(
        service.fetchCategories(),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            contains('500'),
          ),
        ),
      );
    });

    test('melempar ApiException saat tidak ada koneksi internet', () async {
      final client = MockClient(
        (request) async => throw const SocketException('tidak ada jaringan'),
      );
      final service = MealApiService(client: client);

      await expectLater(
        service.searchMeals('chicken'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            contains('koneksi internet'),
          ),
        ),
      );
    });

    test('melempar ApiException saat JSON tidak valid', () async {
      final client = MockClient(
        (request) async => http.Response('<html>bukan json</html>', 200),
      );
      final service = MealApiService(client: client);

      await expectLater(
        service.searchMeals('chicken'),
        throwsA(isA<ApiException>()),
      );
    });

    test('melempar ApiException saat permintaan melewati batas waktu', () async {
      final client = MockClient(
        (request) async => throw TimeoutException('lambat'),
      );
      final service = MealApiService(client: client);

      await expectLater(
        service.searchMeals('chicken'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            contains('Waktu permintaan habis'),
          ),
        ),
      );
    });
  });
}
