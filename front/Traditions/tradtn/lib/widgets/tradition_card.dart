import 'package:flutter/material.dart';
import '../models/tradition.dart';

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
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼 IMAGE
            if (tradition.hasImage)
              Stack(
                children: [
                  Image.network(
                    tradition.imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),

                  // 🆕 NEW BADGE
                  if (tradition.isNew)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Chip(
                        label: const Text('Новое'),
                        backgroundColor: Colors.greenAccent,
                      ),
                    ),

                  // ▶️ VIDEO ICON
                  if (tradition.hasVideo)
                    const Positioned(
                      top: 10,
                      right: 10,
                      child: Icon(
                        Icons.play_circle_fill,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                ],
              ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TITLE + FAVORITE
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          tradition.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: isFavorite ? Colors.red : null,
                        ),
                        onPressed: onFavoriteToggle,
                      ),
                    ],
                  ),

                  if (tradition.category.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        tradition.category,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blueGrey.shade600,
                        ),
                      ),
                    ),

                  const SizedBox(height: 8),

                  Text(
                    tradition.description.isNotEmpty
                        ? tradition.description
                        : 'Без описания',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // 🗑 ADMIN DELETE
                  if (isAdmin)
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: onDelete,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
