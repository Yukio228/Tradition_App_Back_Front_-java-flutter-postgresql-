import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/tradition.dart';
import '../data/categories.dart';

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

  @override
  void initState() {
    super.initState();
    titleController =
        TextEditingController(text: widget.tradition.title);
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
    setState(() => loading = true);

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
    return Scaffold(
      appBar: AppBar(title: const Text('Редактировать традицию')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration:
              const InputDecoration(labelText: 'Название'),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration:
              const InputDecoration(labelText: 'Описание'),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: meaningController,
              maxLines: 2,
              decoration:
              const InputDecoration(labelText: 'Значение'),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: imageUrlController,
              decoration:
              const InputDecoration(labelText: 'Image URL'),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: youtubeUrlController,
              decoration:
              const InputDecoration(labelText: 'YouTube URL'),
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: selectedCategory,
              items: categories
                  .map(
                    (c) =>
                    DropdownMenuItem(value: c, child: Text(c)),
              )
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  setState(() => selectedCategory = v);
                }
              },
              decoration:
              const InputDecoration(labelText: 'Категория'),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : save,
                child: loading
                    ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text('Сохранить'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
