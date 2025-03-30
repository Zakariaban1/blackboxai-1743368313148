import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:craftsman_app/models/learning_content.dart';
import 'package:craftsman_app/services/learning_repository.dart';

final contentSearchProvider = StateNotifierProvider<ContentSearchNotifier, List<LearningContent>>(
  (ref) => ContentSearchNotifier(ref.read(learningRepositoryProvider)),
);

class ContentSearchNotifier extends StateNotifier<List<LearningContent>> {
  final LearningRepository _repository;

  ContentSearchNotifier(this._repository) : super([]);

  Future<void> searchContent(String query) async {
    if (query.isEmpty) {
      state = [];
      return;
    }

    final results = await _repository.searchContent(query);
    state = results;
  }

  void clearResults() {
    state = [];
  }
}