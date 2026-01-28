class Tradition {
  final int id;
  final String title;
  final String description;
  final String meaning;
  final String category;
  final String imageUrl;
  final String youtubeUrl;
  final DateTime createdAt;

  Tradition({
    required this.id,
    required this.title,
    required this.description,
    required this.meaning,
    required this.category,
    required this.imageUrl,
    required this.youtubeUrl,
    required this.createdAt,
  });

  factory Tradition.fromJson(Map<String, dynamic> json) {
    return Tradition(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      meaning: json['meaning'] ?? '',
      category: json['category'] ?? 'Без категории',
      imageUrl: json['imageUrl'] ?? '',
      youtubeUrl: json['youtubeUrl'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  bool get hasImage => imageUrl.isNotEmpty;
  bool get hasVideo => youtubeUrl.isNotEmpty;

  bool get isNew {
    final now = DateTime.now();
    return now.difference(createdAt).inDays <= 7;
  }
}
