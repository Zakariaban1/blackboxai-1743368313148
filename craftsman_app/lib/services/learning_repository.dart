import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:craftsman_app/models/learning_content.dart';
import 'package:craftsman_app/models/learning_path.dart';
import 'package:craftsman_app/models/learning_progress.dart';
import 'package:craftsman_app/models/quiz_model.dart';
import 'package:craftsman_app/models/bookmark_model.dart';

class LearningRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<LearningContent>> getAllLearningContent() async {
    final snapshot = await _firestore.collection('learningContent').get();
    return snapshot.docs.map((doc) => LearningContent(
      id: doc.id,
      title: doc['title'],
      description: doc['description'],
      videoUrl: doc['videoUrl'],
      imageUrl: doc['imageUrl'],
      craft: doc['craft'],
      difficultyLevel: doc['difficultyLevel'],
      tags: List<String>.from(doc['tags']),
    )).toList();
  }

  Future<List<LearningContent>> getLearningContentByCraft(String craft) async {
    final snapshot = await _firestore
        .collection('learningContent')
        .where('craft', isEqualTo: craft)
        .get();
    return snapshot.docs.map((doc) => LearningContent(
      id: doc.id,
      title: doc['title'],
      description: doc['description'],
      videoUrl: doc['videoUrl'],
      imageUrl: doc['imageUrl'],
      craft: doc['craft'],
      difficultyLevel: doc['difficultyLevel'],
      tags: List<String>.from(doc['tags']),
    )).toList();
  }

  Future<LearningContent> getLearningContentById(String contentId) async {
    final doc = await _firestore.collection('learningContent').doc(contentId).get();
    return LearningContent(
      id: doc.id,
      title: doc['title'],
      description: doc['description'],
      videoUrl: doc['videoUrl'],
      imageUrl: doc['imageUrl'],
      craft: doc['craft'],
      difficultyLevel: doc['difficultyLevel'],
      tags: List<String>.from(doc['tags']),
    );
  }

  Future<List<LearningPath>> getLearningPaths(String craft) async {
    final snapshot = await _firestore
        .collection('learningPaths')
        .where('craft', isEqualTo: craft)
        .get();
    return snapshot.docs
        .map((doc) => LearningPath.fromMap(doc.data()..['id'] = doc.id))
        .toList();
  }

  Future<LearningPath> getLearningPathById(String pathId) async {
    final doc = await _firestore.collection('learningPaths').doc(pathId).get();
    return LearningPath.fromMap(doc.data()!..['id'] = doc.id);
  }

  Future<void> addLearningPath(LearningPath path) async {
    await _firestore.collection('learningPaths').add(path.toMap());
  }

  Future<void> updateProgress(String userId, String contentId, double progress) async {
    await _firestore.collection('learningProgress').doc('$userId-$contentId').set({
      'userId': userId,
      'contentId': contentId,
      'progress': progress,
      'isCompleted': progress >= 1.0,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<LearningProgress?> getProgress(String userId, String contentId) {
    return _firestore
        .collection('learningProgress')
        .doc('$userId-$contentId')
        .snapshots()
        .map((doc) => doc.exists ? LearningProgress.fromFirestore(doc) : null);
  }

  Future<void> addQuizQuestion(QuizQuestion question) async {
    await _firestore
        .collection('quizQuestions')
        .doc(question.id)
        .set(question.toMap());
  }

  Future<List<QuizQuestion>> getQuizQuestions(String contentId) async {
    final snapshot = await _firestore
        .collection('quizQuestions')
        .where('contentId', isEqualTo: contentId)
        .get();
    return snapshot.docs
        .map((doc) => QuizQuestion.fromMap(doc.data()..['id'] = doc.id))
        .toList();
  }

  Future<void> saveQuizResult(QuizResult result) async {
    await _firestore.collection('quizResults').add(result.toMap());
  }

  Future<void> addBookmark(String userId, String contentId) async {
    await _firestore.collection('bookmarks').add({
      'userId': userId,
      'contentId': contentId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeBookmark(String bookmarkId) async {
    await _firestore.collection('bookmarks').doc(bookmarkId).delete();
  }

  Stream<List<Bookmark>> getUserBookmarks(String userId) {
    return _firestore
        .collection('bookmarks')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Bookmark.fromFirestore(doc))
            .toList());
  }

  Future<Bookmark?> getBookmark(String userId, String contentId) async {
    final snapshot = await _firestore
        .collection('bookmarks')
        .where('userId', isEqualTo: userId)
        .where('contentId', isEqualTo: contentId)
        .limit(1)
        .get();
    return snapshot.docs.isEmpty
        ? null
        : Bookmark.fromFirestore(snapshot.docs.first);
  }

  Future<void> addLearningContent(LearningContent content) async {
    await _firestore.collection('learningContent').add({
      'title': content.title,
      'description': content.description,
      'videoUrl': content.videoUrl,
      'imageUrl': content.imageUrl,
      'craft': content.craft,
      'difficultyLevel': content.difficultyLevel,
      'tags': content.tags,
    });
  }
}