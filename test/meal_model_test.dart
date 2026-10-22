import 'package:dapur_dunia/models/meal.dart';
import 'package:dapur_dunia/models/meal_category.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Meal.fromJson', () {
    test('memetakan field dasar, tag, dan bahan dengan benar', () {
      final meal = Meal.fromJson({
        'idMeal': '52795',
        'strMeal': 'Chicken Handi',
        'strCategory': 'Chicken',
        'strArea': 'India',
        'strMealThumb': 'https://example.com/handi.jpg',
        'strTags': 'Spicy, Meat',
        'strYoutube': 'https://www.youtube.com/watch?v=IO0issT0Rmc',
        'strInstructions': 'Panaskan minyak.',
        'strIngredient1': 'Chicken',
        'strMeasure1': '1.2 kg',
        'strIngredient2': 'Onion',
        'strMeasure2': '5 thinly sliced',
      });

      expect(meal.id, '52795');
      expect(meal.name, 'Chicken Handi');
      expect(meal.category, 'Chicken');
      expect(meal.area, 'India');
      expect(meal.tags, ['Spicy', 'Meat']);
      expect(meal.youtubeUrl, 'https://www.youtube.com/watch?v=IO0issT0Rmc');
      expect(meal.ingredients.length, 2);
      expect(meal.ingredients.first.name, 'Chicken');
      expect(meal.ingredients.first.measure, '1.2 kg');
    });

    test('mengabaikan bahan kosong dan membersihkan takaran berisi spasi', () {
      final meal = Meal.fromJson({
        'idMeal': '1',
        'strMeal': 'Tes',
        'strMealThumb': '',
        'strIngredient1': 'Salt',
        'strMeasure1': ' ',
        'strIngredient2': '',
        'strMeasure2': '',
        'strIngredient3': null,
        'strMeasure3': null,
      });

      expect(meal.ingredients.length, 1);
      expect(meal.ingredients.first.name, 'Salt');
      expect(meal.ingredients.first.measure, '');
    });

    test('memakai strCountry bila strArea bernilai null', () {
      final meal = Meal.fromJson({
        'idMeal': '53483',
        'strMeal': 'Acaraje',
        'strMealThumb': 'https://example.com/a.jpg',
        'strArea': null,
        'strCountry': 'Brazil',
      });

      expect(meal.area, 'Brazil');
    });

    test('field opsional yang kosong menjadi null atau list kosong', () {
      final meal = Meal.fromJson({
        'idMeal': '2',
        'strMeal': 'Tes',
        'strMealThumb': 'https://example.com/b.jpg',
        'strTags': null,
        'strYoutube': '',
      });

      expect(meal.tags, isEmpty);
      expect(meal.youtubeUrl, isNull);
      expect(meal.instructions, isNull);
      expect(meal.ingredients, isEmpty);
    });
  });

  group('MealCategory.fromJson', () {
    test('memetakan field kategori', () {
      final category = MealCategory.fromJson({
        'idCategory': '1',
        'strCategory': 'Beef',
        'strCategoryThumb': 'https://example.com/beef.png',
        'strCategoryDescription': 'Daging sapi.',
      });

      expect(category.id, '1');
      expect(category.name, 'Beef');
      expect(category.thumbnail, 'https://example.com/beef.png');
      expect(category.description, 'Daging sapi.');
    });
  });
}
