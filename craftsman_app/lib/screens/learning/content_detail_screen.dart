import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:craftsman_app/models/learning_content.dart';
import 'package:craftsman_app/models/learning_progress.dart';
import 'package:craftsman_app/providers/auth_provider.dart';
import 'package:craftsman_app/providers/bookmark_provider.dart';
import 'package:craftsman_app/services/learning_repository.dart';
import 'package:craftsman_app/screens/learning/quiz_screen.dart';

class ContentDetailScreen extends ConsumerStatefulWidget {
  final LearningContent content;
  const ContentDetailScreen({super.key, required this.content});

  @override
  ConsumerState<ContentDetailScreen> createState() => _ContentDetailScreenState();
}

class _ContentDetailScreenState extends ConsumerState<ContentDetailScreen> {
  late VideoPlayerController _controller;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.content.videoUrl != null) {
      _controller = VideoPlayerController.network(widget.content.videoUrl!)
        ..initialize().then((_) {
          setState(() => _isVideoInitialized = true);
          _controller.addListener(_updateVideoProgress);
        });
    }
  }

  void _updateVideoProgress() {
    if (_controller.value.isInitialized) {
      final duration = _controller.value.duration.inSeconds;
      final position = _controller.value.position.inSeconds;
      if (duration > 0) {
        final progress = position / duration;
        _updateProgress(progress.clamp(0.0, 1.0));
      }
    }
  }

  void _updateProgress(double progress) {
    final currentUser = ref.read(authStateProvider).value;
    if (currentUser != null) {
      ref.read(learningRepositoryProvider).updateProgress(
        currentUser.uid,
        widget.content.id,
        progress,
      );
    }
  }

  @override
  void dispose() {
    if (widget.content.videoUrl != null) {
      _controller.removeListener(_updateVideoProgress);
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authStateProvider).value;
    final progressStream = currentUser != null
        ? ref.watch(learningRepositoryProvider)
            .getProgress(currentUser.uid, widget.content.id)
        : null;
    final bookmarkAsync = ref.watch(bookmarkProvider(widget.content.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.content.title),
        actions: [
          bookmarkAsync.when(
            loading: () => const IconButton(
              icon: Icon(Icons.bookmark_border),
              onPressed: null,
            ),
            error: (_, __) => const IconButton(
              icon: Icon(Icons.error),
              onPressed: null,
            ),
            data: (bookmark) => IconButton(
              icon: Icon(bookmark != null 
                ? Icons.bookmark 
                : Icons.bookmark_border),
              onPressed: () async {
                final currentUser = ref.read(authStateProvider).value;
                if (currentUser != null) {
                  if (bookmark != null) {
                    await ref.read(learningRepositoryProvider)
                        .removeBookmark(bookmark.id);
                  } else {
                    await ref.read(learningRepositoryProvider)
                        .addBookmark(currentUser.uid, widget.content.id);
                  }
                  ref.invalidate(bookmarkProvider(widget.content.id));
                }
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.content.videoUrl != null)
              AspectRatio(
                aspectRatio: 16/9,
                child: _isVideoInitialized
                    ? VideoPlayer(_controller)
                    : const Center(child: CircularProgressIndicator()),
              ),
            if (widget.content.imageUrl != null && widget.content.videoUrl == null)
              Image.network(widget.content.imageUrl!),
            const SizedBox(height: 16),
            Text(
              widget.content.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star, size: 20, color: Colors.amber),
                Text(' ${widget.content.difficultyLevel}/5'),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.content.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            StreamBuilder<LearningProgress?>(
              stream: progressStream,
              builder: (context, snapshot) {
                final progress = snapshot.data?.progress ?? 0.0;
                return Column(
                  children: [
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress >= 1.0 ? Colors.green : Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}% completed',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizScreen(
                      contentId: widget.content.id,
                    ),
                  ),
                );
              },
              child: const Text('Take Quiz'),
            ),
            const SizedBox(height: 16),
            if (widget.content.tags.isNotEmpty)
              Wrap(
                spacing: 8,
                children: widget.content.tags
                    .map((tag) => Chip(label: Text(tag)))
                    .toList(),
              ),
          ],
        ),
      ),
      floatingActionButton: widget.content.videoUrl != null
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  _controller.value.isPlaying
                      ? _controller.pause()
                      : _controller.play();
                });
              },
              child: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
            )
          : null,
    );
  }
}