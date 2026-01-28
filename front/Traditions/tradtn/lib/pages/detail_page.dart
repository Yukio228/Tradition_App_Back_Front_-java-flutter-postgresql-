import 'package:flutter/material.dart';
import '../models/tradition.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_card.dart';
import '../widgets/app_icon_button.dart';
import '../widgets/app_scaffold.dart';

class DetailPage extends StatelessWidget {
  final Tradition tradition;

  const DetailPage({super.key, required this.tradition});

  @override
  Widget build(BuildContext context) {
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
            Text(
              tradition.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              child: Text(
                tradition.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
