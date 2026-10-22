import 'package:flutter/material.dart';

import '../models/meal.dart';
import '../models/meal_category.dart';
import '../services/meal_api_service.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/meal_card.dart';
import 'detail_screen.dart';

/// Halaman utama: pencarian, filter kategori, dan grid daftar resep.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String _defaultCategory = 'Chicken';

  final MealApiService _service = MealApiService();
  final TextEditingController _searchController = TextEditingController();

  // Future disimpan sebagai state agar tidak dibuat ulang setiap build().
  late Future<List<MealCategory>> _categoriesFuture;
  late Future<List<Meal>> _mealsFuture;

  String? _selectedCategory = _defaultCategory;
  String _activeQuery = '';

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _service.fetchCategories();
    _mealsFuture = _service.fetchMealsByCategory(_defaultCategory);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _service.dispose();
    super.dispose();
  }

  Future<List<Meal>> _loadMeals() {
    final category = _selectedCategory;
    if (category != null) return _service.fetchMealsByCategory(category);
    return _service.searchMeals(_activeQuery);
  }

  void _selectCategory(String category) {
    _searchController.clear();
    FocusScope.of(context).unfocus();
    setState(() {
      _selectedCategory = category;
      _activeQuery = '';
      _mealsFuture = _loadMeals();
    });
  }

  void _submitSearch(String value) {
    final query = value.trim();
    if (query.isEmpty) return;
    setState(() {
      _selectedCategory = null;
      _activeQuery = query;
      _mealsFuture = _loadMeals();
    });
  }

  void _reload() {
    setState(() {
      _categoriesFuture = _service.fetchCategories();
      _mealsFuture = _loadMeals();
    });
  }

  Future<void> _refresh() async {
    setState(() {
      _mealsFuture = _loadMeals();
    });
    try {
      await _mealsFuture;
    } catch (_) {
      // Kesalahan ditampilkan oleh FutureBuilder, bukan oleh RefreshIndicator.
    }
  }

  void _openDetail(Meal meal) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DetailScreen(
          title: meal.name,
          loader: () => _service.fetchMealDetail(meal.id),
        ),
      ),
    );
  }

  void _openRandom() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DetailScreen(
          title: 'Resep Acak',
          loader: _service.fetchRandomMeal,
        ),
      ),
    );
  }

  String _messageFrom(Object? error) {
    if (error is ApiException) return error.message;
    return 'Terjadi kesalahan yang tidak terduga.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dapur Dunia'),
        actions: [
          IconButton(
            tooltip: 'Resep acak',
            icon: const Icon(Icons.casino_outlined),
            onPressed: _openRandom,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: _submitSearch,
              decoration: InputDecoration(
                hintText: 'Cari resep, misalnya pasta',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          _buildCategoryBar(),
          Expanded(child: _buildMealList()),
        ],
      ),
    );
  }

  Widget _buildCategoryBar() {
    return FutureBuilder<List<MealCategory>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 52,
            child: Center(child: LinearProgressIndicator()),
          );
        }
        // Kategori hanya pelengkap; bila gagal, bagian ini disembunyikan
        // dan kesalahan utama ditangani pada daftar resep.
        final categories = snapshot.data;
        if (snapshot.hasError || categories == null || categories.isEmpty) {
          return const SizedBox.shrink();
        }
        return SizedBox(
          height: 52,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final category = categories[index];
              return ChoiceChip(
                label: Text(category.name),
                selected: category.name == _selectedCategory,
                onSelected: (_) => _selectCategory(category.name),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMealList() {
    return FutureBuilder<List<Meal>>(
      future: _mealsFuture,
      builder: (context, snapshot) {
        // 1. Loading: permintaan sedang berjalan.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingView(message: 'Memuat resep...');
        }

        // 2. Error: permintaan gagal atau data tidak dapat diproses.
        if (snapshot.hasError) {
          return ErrorView(
            message: _messageFrom(snapshot.error),
            onRetry: _reload,
          );
        }

        // 3. Success: data siap ditampilkan.
        final meals = snapshot.data ?? const <Meal>[];
        if (meals.isEmpty) {
          return _EmptyView(query: _activeQuery);
        }

        final label = _selectedCategory != null
            ? 'Kategori $_selectedCategory'
            : 'Hasil pencarian "$_activeQuery"';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                '${meals.length} resep • $label',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: GridView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: meals.length,
                  itemBuilder: (context, index) {
                    final meal = meals[index];
                    return MealCard(
                      meal: meal,
                      onTap: () => _openDetail(meal),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Tampilan saat permintaan berhasil tetapi tidak ada resep yang cocok.
class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final message = query.isEmpty
        ? 'Belum ada resep pada kategori ini.'
        : 'Tidak ada resep yang cocok dengan "$query".';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
