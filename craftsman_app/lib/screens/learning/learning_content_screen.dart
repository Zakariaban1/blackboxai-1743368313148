import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:craftsman_app/localization/app_localizations.dart';
import 'package:craftsman_app/models/learning_content.dart';
import 'package:craftsman_app/providers/learning_provider.dart';
import 'package:craftsman_app/widgets/learning_content_card.dart';

class LearningContentScreen extends ConsumerWidget {
  final String craft;
  const LearningContentScreen({super.key, required this.craft});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final contentAsync = ref.watch(learningContentProvider(craft));

    return Scaffold(
      appBar: AppBar(title: Text('$craft ${l10n.learning}')),
      body: contentAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (contentList) {
          if (contentList.isEmpty) {
            return Center(child: Text('No learning content available'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: contentList.length,
            itemBuilder: (context, index) {
              return LearningContentCard(
                content: contentList[index],
                onTap: () {
                  // TODO: Navigate to content detail
                },
              );
            },
          );
        },
      ),
    );
  }
}