import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:craftsman_app/models/quiz_model.dart';
import 'package:craftsman_app/providers/auth_provider.dart';
import 'package:craftsman_app/services/learning_repository.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final String contentId;
  const QuizScreen({super.key, required this.contentId});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  late Future<List<QuizQuestion>> _questionsFuture;
  List<int?> _selectedAnswers = [];
  bool _isSubmitting = false;
  bool _showResults = false;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _questionsFuture = ref.read(learningRepositoryProvider)
        .getQuizQuestions(widget.contentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: FutureBuilder<List<QuizQuestion>>(
        future: _questionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Error loading quiz'));
          }

          final questions = snapshot.data!;
          if (_selectedAnswers.isEmpty) {
            _selectedAnswers = List.filled(questions.length, null);
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (_showResults)
                  _buildResultsCard(questions.length),
                Expanded(
                  child: ListView.builder(
                    itemCount: questions.length,
                    itemBuilder: (context, index) {
                      final question = questions[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${index + 1}. ${question.question}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              ...question.options.asMap().entries.map((entry) {
                                final optionIndex = entry.key;
                                final option = entry.value;
                                return RadioListTile<int>(
                                  title: Text(option),
                                  value: optionIndex,
                                  groupValue: _selectedAnswers[index],
                                  onChanged: _showResults ? null : (value) {
                                    setState(() {
                                      _selectedAnswers[index] = value;
                                    });
                                  },
                                  secondary: _showResults
                                      ? optionIndex == question.correctAnswerIndex
                                          ? const Icon(Icons.check, color: Colors.green)
                                          : _selectedAnswers[index] == optionIndex
                                              ? const Icon(Icons.close, color: Colors.red)
                                              : null
                                      : null,
                                );
                              }),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (!_showResults)
                  ElevatedButton(
                    onPressed: _isSubmitting || _selectedAnswers.contains(null)
                        ? null
                        : _submitQuiz,
                    child: _isSubmitting
                        ? const CircularProgressIndicator()
                        : const Text('Submit Quiz'),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultsCard(int totalQuestions) {
    return Card(
      color: _score == totalQuestions ? Colors.green[50] : Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Quiz Results',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'You scored $_score out of $totalQuestions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (_score == totalQuestions)
              const Text(
                'Perfect! 🎉',
                style: TextStyle(fontSize: 24),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitQuiz() async {
    setState(() => _isSubmitting = true);
    
    try {
      final questions = await _questionsFuture;
      final currentUser = ref.read(authStateProvider).value;
      
      if (currentUser != null) {
        int score = 0;
        for (int i = 0; i < questions.length; i++) {
          if (_selectedAnswers[i] == questions[i].correctAnswerIndex) {
            score++;
          }
        }

        final result = QuizResult(
          id: '',
          userId: currentUser.uid,
          contentId: widget.contentId,
          score: score,
          totalQuestions: questions.length,
          completedAt: DateTime.now(),
        );

        await ref.read(learningRepositoryProvider).saveQuizResult(result);
        setState(() {
          _score = score;
          _showResults = true;
        });
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
}