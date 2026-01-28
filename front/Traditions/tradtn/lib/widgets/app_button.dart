import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

enum AppButtonVariant { primary, secondary, ghost }

class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.fullWidth = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final AppButtonVariant variant;
  final bool fullWidth;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.loading;
    final colorScheme = Theme.of(context).colorScheme;

    Color background;
    Color foreground;
    BorderSide? border;

    switch (widget.variant) {
      case AppButtonVariant.secondary:
        background = colorScheme.secondary.withOpacity(isDisabled ? 0.5 : 0.9);
        foreground = colorScheme.onSecondary;
        break;
      case AppButtonVariant.ghost:
        background = Colors.transparent;
        foreground = colorScheme.onSurface;
        border = BorderSide(color: colorScheme.onSurface.withOpacity(0.2));
        break;
      case AppButtonVariant.primary:
      default:
        background = colorScheme.primary.withOpacity(isDisabled ? 0.45 : 1);
        foreground = colorScheme.onPrimary;
        break;
    }

    final child = widget.loading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(foreground),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 18),
                const SizedBox(width: 8),
              ],
              Text(widget.label),
            ],
          );

    final buttonChild = AnimatedScale(
      scale: _pressed ? 0.98 : 1,
      duration: const Duration(milliseconds: 120),
      child: AnimatedOpacity(
        opacity: isDisabled ? 0.7 : 1,
        duration: const Duration(milliseconds: 120),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: border == null ? null : Border.fromBorderSide(border),
            boxShadow: widget.variant == AppButtonVariant.primary
                ? [
                    BoxShadow(
                      color: AppColors.neonPurple.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: DefaultTextStyle(
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    color: foreground,
                  ),
              child: IconTheme(
                data: IconThemeData(color: foreground),
                child: Center(child: child),
              ),
            ),
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      enabled: !isDisabled,
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: isDisabled ? null : widget.onPressed,
        child: widget.fullWidth
            ? SizedBox(width: double.infinity, child: buttonChild)
            : buttonChild,
      ),
    );
  }
}
