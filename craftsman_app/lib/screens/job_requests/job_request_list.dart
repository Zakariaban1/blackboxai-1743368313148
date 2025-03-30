import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:craftsman_app/localization/app_localizations.dart';
import 'package:craftsman_app/models/job_model.dart';
import 'package:craftsman_app/providers/job_provider.dart';
import 'package:craftsman_app/widgets/job_request_item.dart';

class JobRequestList extends ConsumerWidget {
  const JobRequestList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final currentUser = ref.watch(authStateProvider).value;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.requests)),
      body: currentUser == null
          ? const Center(child: Text('Please sign in'))
          : _buildRequestList(currentUser.uid, ref),
    );
  }

  Widget _buildRequestList(String userId, WidgetRef ref) {
    final requestsAsync = ref.watch(jobRequestsProvider(userId));

    return requestsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
      data: (requests) {
        if (requests.isEmpty) {
          return const Center(child: Text('No requests found'));
        }

        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return JobRequestItem(
              request: request,
              onStatusChanged: (status) {
                ref.read(jobRepositoryProvider)
                    .updateJobStatus(request.id, status);
              },
            );
          },
        );
      },
    );
  }
}