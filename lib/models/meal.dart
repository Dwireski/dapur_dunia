/// Satu bahan masakan beserta takarannya.
class Ingredient {
  final String name;
  final String measure;

  const Ingredient({required this.name, required this.measure});
}

/// Model data satu resep makanan dari TheMealDB.
///
/// Endpoint `filter.php` hanya mengembalikan id, nama, dan gambar, sedangkan
/// `search.php`, `lookup.php`, dan `random.php` mengembalikan data lengkap.
/// Karena itu field selain id, nama, dan gambar dibuat nullable / berisi
/// nilai default.
class Meal {
  final String id;
  final String name;
  final String thumbnail;
  final String? category;
  final String? area;
  final String? instructions;
  final String? youtubeUrl;
  final List<String> tags;
  final List<Ingredient> ingredients;

  const Meal({
    required this.id,
    required this.name,
    required this.thumbnail,
    this.category,
    this.area,
    this.instructions,
    this.youtubeUrl,
    this.tags = const [],
    this.ingredients = const [],
  });

  /// Mengonversi satu objek JSON dari API menjadi objek [Meal].
  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: _text(json['idMeal']) ?? '',
      name: _text(json['strMeal']) ?? 'Tanpa nama',
      thumbnail: _text(json['strMealThumb']) ?? '',
      category: _text(json['strCategory']),
      // strArea kadang bernilai null, sehingga strCountry dipakai sebagai cadangan.
      area: _text(json['strArea']) ?? _text(json['strCountry']),
      instructions: _text(json['strInstructions']),
      youtubeUrl: _text(json['strYoutube']),
      tags: _parseTags(json['strTags']),
      ingredients: _parseIngredients(json),
    );
  }

  /// Membersihkan nilai dari API: null, kosong, atau hanya spasi menjadi null.
  static String? _text(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  /// strTags berformat "Spicy,Meat" atau null.
  static List<String> _parseTags(dynamic raw) {
    final text = _text(raw);
    if (text == null) return const [];
    return text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
  }

  /// API menyimpan bahan sebagai field datar strIngredient1..20 dan
  /// strMeasure1..20, sehingga perlu digabungkan menjadi daftar.
  static List<Ingredient> _parseIngredients(Map<String, dynamic> json) {
    final result = <Ingredient>[];
    for (var i = 1; i <= 20; i++) {
      final name = _text(json['strIngredient$i']);
      if (name == null) continue;
      final measure = _text(json['strMeasure$i']) ?? '';
      result.add(Ingredient(name: name, measure: measure));
    }
    return result;
  }
}
