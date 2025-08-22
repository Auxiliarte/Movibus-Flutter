import 'package:flutter/material.dart';
import '../../models/favorite_location.dart';

class FavoriteCard extends StatelessWidget {
  final FavoriteLocation favorite;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const FavoriteCard({
    Key? key,
    required this.favorite,
    this.onTap,
    this.onDelete,
  }) : super(key: key);

  IconData _getIconForFavorite(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('casa') || lowerName.contains('home')) {
      return Icons.home;
    } else if (lowerName.contains('trabajo') || lowerName.contains('work')) {
      return Icons.work;
    } else if (lowerName.contains('escuela') || lowerName.contains('universidad')) {
      return Icons.school;
    } else if (lowerName.contains('tienda') || lowerName.contains('supermercado')) {
      return Icons.shopping_cart;
    } else {
      return Icons.location_on;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.dialogBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getIconForFavorite(favorite.name),
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    favorite.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    favorite.address,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (onDelete != null) ...[
              IconButton(
                onPressed: onDelete,
                icon: Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: theme.colorScheme.error.withOpacity(0.7),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
            ],
            Icon(
              Icons.keyboard_arrow_right,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
