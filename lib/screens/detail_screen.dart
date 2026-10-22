import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/meal.dart';
import '../services/meal_api_service.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/meal_image.dart';

/// Halaman detail resep: gambar, bahan, langkah memasak, dan tautan video.
///
/// Data diambil melalui [loader] sehingga halaman yang sama dapat dipakai
/// untuk resep terpilih (lookup by id) maupun resep acak.
class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.title, required this.loader});

  final String title;
  final Future<Meal> Function() loader;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<Meal> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.loader();
  }

  void _retry() {
    setState(() {
      _future = widget.loader();
    });
  }

  String _messageFrom(Object? error) {
    if (error is ApiException) return error.message;
    return 'Terjadi kesalahan yang tidak terduga.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder<Meal>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingView(message: 'Memuat detail resep...');
          }
          if (snapshot.hasError) {
            return ErrorView(
              message: _messageFrom(snapshot.error),
              onRetry: _retry,
            );
          }
          final meal = snapshot.data;
          if (meal == null) {
            return ErrorView(
              message: 'Data resep tidak tersedia.',
              onRetry: _retry,
            );
          }
          return _MealDetailView(meal: meal);
        },
      ),
    );
  }
}

class _MealDetailView extends StatelessWidget {
  const _MealDetailView({required this.meal});

  final Meal meal;

  /// Memecah teks instruksi menjadi paragraf berdasarkan baris baru.
  List<String> get _steps {
    final text = meal.instructions;
    if (text == null) return const [];
    return text
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  Future<void> _copyLink(BuildContext context, String url) async {
    await Clipboard.setData(ClipboardData(text: url));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tautan video disalin.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final steps = _steps;
    final youtube = meal.youtubeUrl;

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        AspectRatio(
          aspectRatio: 16 / 10,
          child: MealImage(url: meal.thumbnail),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(meal.name, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (meal.category != null)
                    Chip(
                      avatar: const Icon(Icons.category_outlined, size: 18),
                      label: Text(meal.category!),
                    ),
                  if (meal.area != null)
                    Chip(
                      avatar: const Icon(Icons.public, size: 18),
                      label: Text(meal.area!),
                    ),
                  for (final tag in meal.tags) Chip(label: Text(tag)),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Bahan-bahan (${meal.ingredients.length})',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (meal.ingredients.isEmpty)
                const Text('Data bahan tidak tersedia.')
              else
                for (final item in meal.ingredients)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2, right: 8),
                          child: Icon(Icons.check_circle_outline, size: 18),
                        ),
                        Expanded(child: Text(item.name)),
                        const SizedBox(width: 12),
                        Text(
                          item.measure,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              const SizedBox(height: 20),
              Text('Cara Memasak', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              if (steps.isEmpty)
                const Text('Instruksi tidak tersedia.')
              else
                for (final step in steps)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(step, style: theme.textTheme.bodyMedium),
                  ),
              if (youtube != null) ...[
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.play_circle_outline),
                    title: const Text('Video tutorial'),
                    subtitle: SelectableText(youtube),
                    trailing: IconButton(
                      tooltip: 'Salin tautan',
                      icon: const Icon(Icons.copy),
                      onPressed: () => _copyLink(context, youtube),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
