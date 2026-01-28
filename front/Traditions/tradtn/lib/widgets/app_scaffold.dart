import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.safeArea = true,
    this.extendBodyBehindAppBar = true,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final bool safeArea;
  final bool extendBodyBehindAppBar;

  @override
  Widget build(BuildContext context) {
    final content = safeArea ? SafeArea(child: body) : body;

    return Scaffold(
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      appBar: appBar,
      backgroundColor: Colors.transparent,
      floatingActionButton: floatingActionButton,
      body: Stack(
        children: [
          const _AppBackground(),
          content,
        ],
      ),
    );
  }
}

class _AppBackground extends StatelessWidget {
  const _AppBackground();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradient =
        isDark ? AppColors.darkBackgroundGradient : AppColors.lightBackgroundGradient;

    return Container(
      decoration: BoxDecoration(gradient: gradient),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            right: -80,
            child: _GlowBlob(
              color: AppColors.neonPurple.withOpacity(isDark ? 0.25 : 0.2),
              size: 260,
            ),
          ),
          Positioned(
            bottom: -140,
            left: -60,
            child: _GlowBlob(
              color: AppColors.neonCyan.withOpacity(isDark ? 0.22 : 0.18),
              size: 240,
            ),
          ),
          Positioned(
            top: 140,
            left: -40,
            child: _GlowBlob(
              color: AppColors.neonPink.withOpacity(isDark ? 0.18 : 0.15),
              size: 200,
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              color: Colors.black.withOpacity(isDark ? 0.15 : 0.04),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, Colors.transparent],
        ),
      ),
    );
  }
}

