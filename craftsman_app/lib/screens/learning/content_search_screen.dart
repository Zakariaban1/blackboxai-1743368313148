import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:craftsman_app/widgets/learning_content_card.dart';
import 'package:craftsman_app/providers/content_search_provider.dart';
import 'package:craftsman_app/screens/learning/content_detail_screen.dart';

class ContentSearchScreen extends ConsumerStatefulWidget {
  const ContentSearchScreen({super.key});

  @override
  ConsumerState<ContentSearchScreen> createState() => _ContentSearchScreenState();
}

class _ContentSearchScreenState extends ConsumerState<ContentSearchScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(contentSearchProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search learning content...',
            border: InputBorder.none,
          ),
          onChanged: (query) {
            ref.read(contentSearchProvider.notifier).searchContent(query);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              ref.read(contentSearchProvider.notifier).clearResults();
            },
          ),
        ],
      ),
      body: searchResults.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    _searchController.text.isEmpty
                        ? 'Search for learning content'
                        : 'No results found',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final content = searchResults[index];
                return LearningContentCard(
                  content: content,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ContentDetailScreen(
                          content: content,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}