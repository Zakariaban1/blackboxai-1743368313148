class LearningPath {
  final String id;
  final String title;
  final String description;
  final String craft;
  final List<String> contentIds;
  final int difficultyLevel;
  final String? imageUrl;

  LearningPath({
    required this.id,
    required this.title,
    required this.description,
    required this.craft,
    required this.contentIds,
    this.difficultyLevel = 1,
    this.imageUrl,
  });

  factory LearningPath.fromMap(Map<String, dynamic> map) {
    return LearningPath(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      craft: map['craft'],
      contentIds: List<String>.from(map['contentIds']),
      difficultyLevel: map['difficultyLevel'],
      imageUrl: map['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'craft': craft,
      'contentIds': contentIds,
      'difficultyLevel': difficultyLevel,
      'imageUrl': imageUrl,
    };
  }
}