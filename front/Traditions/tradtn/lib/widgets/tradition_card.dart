import 'package:flutter/material.dart';
import '../models/tradition.dart';
import '../theme/app_spacing.dart';
import 'app_card.dart';
import 'app_chip.dart';
import 'app_icon_button.dart';
import 'app_network_image.dart';

class TraditionCard extends StatelessWidget {
  final Tradition tradition;
  final bool isFavorite;
  final bool isAdmin;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const TraditionCard({
    super.key,
    required this.tradition,
    required this.isFavorite,
    required this.isAdmin,
    required this.onFavoriteToggle,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (tradition.hasImage)
            Stack(
              children: [
                AppNetworkImage(
                  url: tradition.imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  heroTag: 'tradition-image-${tradition.id}',
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.55),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: AppChip(
                    label: tradition.isNew ? 'New' : tradition.category,
                    icon: tradition.isNew
                        ? Icons.auto_awesome_rounded
                        : Icons.category_rounded,
                  ),
                ),
                if (tradition.hasVideo)
                  const Positioned(
                    top: 12,
                    right: 12,
                    child: Icon(
                      Icons.play_circle_fill_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
              ],
            )
          else
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: AppChip(
                label: tradition.category,
                icon: Icons.category_rounded,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        tradition.title,
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    AppIconButton(
                      icon: isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      onPressed: onFavoriteToggle,
                      tooltip: 'Favorite',
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  tradition.description.isNotEmpty
                      ? tradition.description
                      : 'No description available.',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                if (isAdmin && onDelete != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text('Delete'),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
