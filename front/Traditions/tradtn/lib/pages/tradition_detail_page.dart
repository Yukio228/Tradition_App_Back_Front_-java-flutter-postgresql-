import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../models/tradition.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_card.dart';
import '../widgets/app_chip.dart';
import '../widgets/app_icon_button.dart';
import '../widgets/app_network_image.dart';
import '../widgets/app_scaffold.dart';

class TraditionDetailPage extends StatefulWidget {
  final Tradition tradition;

  const TraditionDetailPage({super.key, required this.tradition});

  @override
  State<TraditionDetailPage> createState() => _TraditionDetailPageState();
}

class _TraditionDetailPageState extends State<TraditionDetailPage> {
  YoutubePlayerController? _controller;

  @override
  void initState() {
    super.initState();

    if (widget.tradition.youtubeUrl.isNotEmpty) {
      final videoId =
          YoutubePlayer.convertUrlToId(widget.tradition.youtubeUrl);
      if (videoId != null) {
        _controller = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tradition;
    final theme = Theme.of(context);

    return AppScaffold(
      safeArea: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppIconButton(
              icon: Icons.arrow_back_rounded,
              onPressed: () => Navigator.pop(context),
              tooltip: 'Back',
            ),
            const SizedBox(height: AppSpacing.lg),
            if (t.hasImage)
              Stack(
                children: [
                  AppNetworkImage(
                    url: t.imageUrl,
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                    heroTag: 'tradition-image-${t.id}',
                    borderRadius: BorderRadius.circular(24),
                  ),
                  Positioned(
                    left: 16,
                    bottom: 16,
                    child: AppChip(
                      label: t.category,
                      icon: Icons.category_rounded,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              t.title,
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              t.description,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            if (t.meaning.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Meaning',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      t.meaning,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
            if (_controller != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AppCard(
                padding: EdgeInsets.zero,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: YoutubePlayer(
                    controller: _controller!,
                    showVideoProgressIndicator: true,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
