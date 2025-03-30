import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:craftsman_app/models/bookmark_model.dart';
import 'package:craftsman_app/providers/auth_provider.dart';
import 'package:craftsman_app/services/learning_repository.dart';

final bookmarkProvider = FutureProvider.family<Bookmark?, String>(
  (ref, contentId) async {
    final currentUser = ref.watch(authStateProvider).value;
    if (currentUser == null) return null;
    return ref.read(learningRepositoryProvider)
        .getBookmark(currentUser.uid, contentId);
  },
);

final bookmarksProvider = StreamProvider<List<Bookmark>>(
  (ref) {
    final currentUser = ref.watch(authStateProvider).value;
    if (currentUser == null) return const Stream.empty();
    return ref.read(learningRepositoryProvider)
        .getUserBookmarks(currentUser.uid);
  },
);