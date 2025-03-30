class LearningContent {
  final String id;
  final String title;
  final String description;
  final String? videoUrl;
  final String? imageUrl;
  final String craft;
  final int difficultyLevel;
  final List<String> tags;

  LearningContent({
    required this.id,
    required this.title,
    required this.description,
    this.videoUrl,
    this.imageUrl,
    required this.craft,
    this.difficultyLevel = 1,
    this.tags = const [],
  });
}