class QuizQuestion {
  final String id;
  final String contentId;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;

  QuizQuestion({
    required this.id,
    required this.contentId,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
  });

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      id: map['id'],
      contentId: map['contentId'],
      question: map['question'],
      options: List<String>.from(map['options']),
      correctAnswerIndex: map['correctAnswerIndex'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'contentId': contentId,
      'question': question,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
    };
  }
}

class QuizResult {
  final String id;
  final String userId;
  final String contentId;
  final int score;
  final int totalQuestions;
  final DateTime completedAt;

  QuizResult({
    required this.id,
    required this.userId,
    required this.contentId,
    required this.score,
    required this.totalQuestions,
    required this.completedAt,
  });

  factory QuizResult.fromMap(Map<String, dynamic> map) {
    return QuizResult(
      id: map['id'],
      userId: map['userId'],
      contentId: map['contentId'],
      score: map['score'],
      totalQuestions: map['totalQuestions'],
      completedAt: map['completedAt'].toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'contentId': contentId,
      'score': score,
      'totalQuestions': totalQuestions,
      'completedAt': FieldValue.serverTimestamp(),
    };
  }
}