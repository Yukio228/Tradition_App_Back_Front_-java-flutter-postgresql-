import 'package:flutter/material.dart';
import '../data/categories.dart';
import '../models/tradition.dart';
import '../services/api_service.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/app_icon_button.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/app_text_field.dart';

class EditTraditionPage extends StatefulWidget {
  final Tradition tradition;
  const EditTraditionPage({super.key, required this.tradition});

  @override
  State<EditTraditionPage> createState() => _EditTraditionPageState();
}

class _EditTraditionPageState extends State<EditTraditionPage> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController meaningController;
  late TextEditingController imageUrlController;
  late TextEditingController youtubeUrlController;
  late String selectedCategory;

  bool loading = false;
  String? imageError;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.tradition.title);
    descriptionController =
        TextEditingController(text: widget.tradition.description);
    meaningController =
        TextEditingController(text: widget.tradition.meaning);
    imageUrlController =
        TextEditingController(text: widget.tradition.imageUrl);
    youtubeUrlController =
        TextEditingController(text: widget.tradition.youtubeUrl);
    selectedCategory = widget.tradition.category;
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

  Future<void> save() async {
    setState(() {
      loading = true;
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

    await ApiService.updateTradition(
      id: widget.tradition.id,
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
            Text('Edit tradition', style: theme.textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.xl),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    controller: titleController,
                    label: 'Title',
                    hintText: 'Name of the tradition',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: descriptionController,
                    label: 'Description',
                    hintText: 'Short explanation',
                    maxLines: 3,
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
                        .map(
                          (c) => DropdownMenuItem(value: c, child: Text(c)),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setState(() => selectedCategory = v);
                      }
                    },
                    decoration: const InputDecoration(labelText: 'Category'),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    label: 'Save changes',
                    loading: loading,
                    onPressed: loading ? null : save,
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
