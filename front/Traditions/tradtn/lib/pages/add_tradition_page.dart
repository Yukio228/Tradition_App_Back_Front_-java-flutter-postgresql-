import 'package:flutter/material.dart';
import '../data/categories.dart';
import '../services/api_service.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/app_icon_button.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/app_text_field.dart';

class AddTraditionPage extends StatefulWidget {
  const AddTraditionPage({super.key});

  @override
  State<AddTraditionPage> createState() => _AddTraditionPageState();
}

class _AddTraditionPageState extends State<AddTraditionPage> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final meaningController = TextEditingController();
  final imageUrlController = TextEditingController();
  final youtubeUrlController = TextEditingController();

  String selectedCategory = categories.first;
  bool loading = false;
  String? error;
  String? imageError;

  Future<void> submit() async {
    if (titleController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty) {
      setState(() {
        error = 'Please fill in the required fields';
      });
      return;
    }

    setState(() {
      loading = true;
      error = null;
      imageError = null;
    });

    final imageUrl = imageUrlController.text.trim();
    if (imageUrl.isNotEmpty) {
      final validationError = await ApiService.validateImageUrl(imageUrl);
      if (!mounted) return;
      if (validationError != null) {
        setState(() {
          loading = false;
          imageError = validationError;
        });
        return;
      }
    }

    await ApiService.addTradition(
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      meaning: meaningController.text.trim(),
      category: selectedCategory,
      imageUrl: imageUrlController.text.trim(),
      youtubeUrl: youtubeUrlController.text.trim(),
    );

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    meaningController.dispose();
    imageUrlController.dispose();
    youtubeUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            const SizedBox(height: AppSpacing.md),
            Text('Add tradition', style: theme.textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.xl),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    controller: titleController,
                    label: 'Title *',
                    hintText: 'Name of the tradition',
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: descriptionController,
                    label: 'Description *',
                    hintText: 'Short explanation',
                    maxLines: 3,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: meaningController,
                    label: 'Meaning',
                    hintText: 'Cultural significance',
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: imageUrlController,
                    label: 'Image URL',
                    hintText: 'https://...',
                    keyboardType: TextInputType.url,
                    errorText: imageError,
                    onChanged: (_) => setState(() => imageError = null),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: youtubeUrlController,
                    label: 'YouTube URL',
                    hintText: 'https://www.youtube.com/watch?v=...',
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    items: categories
                        .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(c),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => selectedCategory = v!),
                    decoration: const InputDecoration(
                      labelText: 'Category',
                    ),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      error!,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: theme.colorScheme.error),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    label: 'Save',
                    loading: loading,
                    onPressed: loading ? null : submit,
                    icon: Icons.save_rounded,
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
