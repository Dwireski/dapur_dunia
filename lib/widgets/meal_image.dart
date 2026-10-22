import 'package:flutter/material.dart';

/// Gambar jaringan dengan indikator saat memuat dan pengganti saat gagal,
/// sehingga kegagalan memuat gambar tidak merusak tampilan.
class MealImage extends StatelessWidget {
  const MealImage({super.key, required this.url, this.fit = BoxFit.cover});

  final String url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return const _ImagePlaceholder(icon: Icons.restaurant);
    }
    return Image.network(
      url,
      fit: fit,
      width: double.infinity,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
      },
      errorBuilder: (context, error, stackTrace) =>
          const _ImagePlaceholder(icon: Icons.broken_image_outlined),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      color: colors.secondaryContainer,
      child: Icon(icon, size: 40, color: colors.onSecondaryContainer),
    );
  }
}
