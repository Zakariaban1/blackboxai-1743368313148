import 'package:flutter/material.dart';
import 'package:craftsman_app/models/rating_model.dart';
import 'package:craftsman_app/services/user_repository.dart';

class RatingItem extends StatelessWidget {
  final Rating rating;
  const RatingItem({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: UserRepository().getUserData(rating.clientId),
      builder: (context, snapshot) {
        final client = snapshot.data;
        
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client?.email ?? 'Anonymous',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < rating.stars ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 20,
                    );
                  }),
                ),
                if (rating.comment != null) ...[
                  const SizedBox(height: 8),
                  Text(rating.comment!),
                ],
                const SizedBox(height: 8),
                Text(
                  '${rating.createdAt.day}/${rating.createdAt.month}/${rating.createdAt.year}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}