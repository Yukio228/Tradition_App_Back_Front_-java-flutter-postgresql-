import 'package:flutter/material.dart';

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.heroTag,
  });

  final String url;
  final double? height;
  final double? width;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget child;
    if (url.isEmpty) {
      child = _Placeholder(
        height: height,
        width: width,
        message: 'No image',
      );
    } else {
      child = Image.network(
        url,
        height: height,
        width: width,
        fit: fit,
        loadingBuilder: (context, imageChild, progress) {
          if (progress == null) return imageChild;
          return _Placeholder(
            height: height,
            width: width,
            message: 'Loading...',
            showSpinner: true,
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _Placeholder(
            height: height,
            width: width,
            message: 'Image unavailable',
          );
        },
      );
    }

    if (borderRadius != null) {
      child = ClipRRect(
        borderRadius: borderRadius!,
        child: child,
      );
    }

    if (heroTag != null) {
      child = Hero(tag: heroTag!, child: child);
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.4),
        borderRadius: borderRadius,
      ),
      child: child,
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({
    required this.height,
    required this.width,
    required this.message,
    this.showSpinner = false,
  });

  final double? height;
  final double? width;
  final String message;
  final bool showSpinner;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: height,
      width: width,
      alignment: Alignment.center,
      color: theme.colorScheme.surface.withOpacity(0.35),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showSpinner)
            const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Icon(
              Icons.broken_image_rounded,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          const SizedBox(height: 8),
          Text(
            message,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
