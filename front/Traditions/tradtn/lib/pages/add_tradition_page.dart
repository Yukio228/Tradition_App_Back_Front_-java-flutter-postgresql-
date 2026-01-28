import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../data/categories.dart';

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

  Future<void> submit() async {
    if (titleController.text.isEmpty ||
        descriptionController.text.isEmpty) {
      setState(() {
        error = 'Заполните обязательные поля';
      });
      return;
    }

    setState(() {
      loading = true;
      error = null;
    });

    await ApiService.addTradition(
      title: titleController.text,
      description: descriptionController.text,
      meaning: meaningController.text,
      category: selectedCategory,
      imageUrl: imageUrlController.text,
      youtubeUrl: youtubeUrlController.text,
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
    return Scaffold(
      appBar: AppBar(title: const Text('Добавить традицию')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Название *'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Описание *'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: meaningController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Значение'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: imageUrlController,
              decoration: const InputDecoration(
                labelText: 'Ссылка на изображение',
                hintText: 'https://...',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: youtubeUrlController,
              decoration: const InputDecoration(
                labelText: 'YouTube ссылка',
                hintText: 'https://www.youtube.com/watch?v=...',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              items: categories
                  .map((c) => DropdownMenuItem(
                value: c,
                child: Text(c),
              ))
                  .toList(),
              onChanged: (v) => setState(() => selectedCategory = v!),
              decoration: const InputDecoration(labelText: 'Категория'),
            ),
            if (error != null) ...[
              const SizedBox(height: 12),
              Text(error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : submit,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Сохранить'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
