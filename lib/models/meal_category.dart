/// Model kategori resep dari endpoint `categories.php`.
class MealCategory {
  final String id;
  final String name;
  final String thumbnail;
  final String description;

  const MealCategory({
    required this.id,
    required this.name,
    required this.thumbnail,
    required this.description,
  });

  factory MealCategory.fromJson(Map<String, dynamic> json) {
    return MealCategory(
      id: (json['idCategory'] ?? '').toString(),
      name: (json['strCategory'] ?? '').toString(),
      thumbnail: (json['strCategoryThumb'] ?? '').toString(),
      description: (json['strCategoryDescription'] ?? '').toString(),
    );
  }
}
