import 'package:flutter/material.dart';

class CouponPromoCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final double rating;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const CouponPromoCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.rating,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              imagePath,
              width: 90,
              height: 90,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: theme.textTheme.labelMedium?.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, size: 18, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          rating.toString(),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: isFavorite ? Colors.red : Colors.grey,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: onFavoriteToggle,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
