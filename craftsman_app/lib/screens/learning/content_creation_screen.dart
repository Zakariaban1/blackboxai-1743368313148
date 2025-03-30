import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:craftsman_app/models/learning_content.dart';
import 'package:craftsman_app/services/learning_repository.dart';

class ContentCreationScreen extends ConsumerStatefulWidget {
  const ContentCreationScreen({super.key});

  @override
  ConsumerState<ContentCreationScreen> createState() => _ContentCreationScreenState();
}

class _ContentCreationScreenState extends ConsumerState<ContentCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _craftController = TextEditingController();
  final _videoUrlController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _tagsController = TextEditingController();
  int _difficultyLevel = 1;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _craftController.dispose();
    _videoUrlController.dispose();
    _imageUrlController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Learning Content'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isSubmitting ? null : _submitForm,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: _craftController,
                decoration: const InputDecoration(labelText: 'Craft'),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Text('Difficulty Level: $_difficultyLevel/5'),
              Slider(
                value: _difficultyLevel.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                onChanged: (value) {
                  setState(() => _difficultyLevel = value.toInt());
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _videoUrlController,
                decoration: const InputDecoration(labelText: 'Video URL (optional)'),
              ),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'Image URL (optional)'),
              ),
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags (comma separated)',
                  hintText: 'woodworking, beginner, tools',
                ),
              ),
              const SizedBox(height: 24),
              if (_isSubmitting)
                const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      
      try {
        final repository = ref.read(learningRepositoryProvider);
        final content = LearningContent(
          id: '',
          title: _titleController.text,
          description: _descriptionController.text,
          craft: _craftController.text,
          difficultyLevel: _difficultyLevel,
          videoUrl: _videoUrlController.text.isEmpty ? null : _videoUrlController.text,
          imageUrl: _imageUrlController.text.isEmpty ? null : _imageUrlController.text,
          tags: _tagsController.text.split(',').map((e) => e.trim()).toList(),
        );

        await repository.addLearningContent(content);
        Navigator.of(context).pop();
      } finally {
        setState(() => _isSubmitting = false);
      }
    }
  }
}