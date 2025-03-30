import 'package:flutter/material.dart';
import 'package:craftsman_app/models/learning_path.dart';

class LearningPathCard extends StatelessWidget {
  final LearningPath path;
  final VoidCallback onTap;

  const LearningPathCard({
    super.key,
    required this.path,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (path.imageUrl != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Image.network(path.imageUrl!),
                ),
              Text(
                path.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(path.description),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.star, size: 16, color: Colors.amber),
                  Text(' ${path.difficultyLevel}/5'),
                  const Spacer(),
                  Text(
                    '${path.contentIds.length} lessons',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}