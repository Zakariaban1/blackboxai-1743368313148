import 'package:flutter/material.dart';
import 'package:craftsman_app/models/rating_model.dart';

class RatingForm extends StatefulWidget {
  final String jobId;
  final String craftsmanId;
  final String clientId;
  final Function(Rating) onSubmit;

  const RatingForm({
    super.key,
    required this.jobId,
    required this.craftsmanId,
    required this.clientId,
    required this.onSubmit,
  });

  @override
  State<RatingForm> createState() => _RatingFormState();
}

class _RatingFormState extends State<RatingForm> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  int _rating = 3;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rate your experience', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 40,
                ),
                onPressed: () => setState(() => _rating = index + 1),
              );
            }),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _commentController,
            decoration: const InputDecoration(
              labelText: 'Comment (optional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submitRating,
            child: const Text('Submit Rating'),
          ),
        ],
      ),
    );
  }

  void _submitRating() {
    if (_formKey.currentState!.validate()) {
      final rating = Rating(
        id: '',
        jobId: widget.jobId,
        craftsmanId: widget.craftsmanId,
        clientId: widget.clientId,
        stars: _rating,
        comment: _commentController.text.trim(),
        createdAt: DateTime.now(),
      );
      widget.onSubmit(rating);
    }
  }
}