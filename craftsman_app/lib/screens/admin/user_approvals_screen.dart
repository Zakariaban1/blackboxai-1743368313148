import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:craftsman_app/models/approval_model.dart';
import 'package:craftsman_app/services/user_approval_repository.dart';

class UserApprovalsScreen extends ConsumerStatefulWidget {
  const UserApprovalsScreen({super.key});

  @override
  ConsumerState<UserApprovalsScreen> createState() => _UserApprovalsScreenState();
}

class _UserApprovalsScreenState extends ConsumerState<UserApprovalsScreen> {
  @override
  Widget build(BuildContext context) {
    final approvalsStream = ref.watch(userApprovalRepositoryProvider).getPendingApprovals();

    return Scaffold(
      appBar: AppBar(title: const Text('Pending Approvals')),
      body: StreamBuilder<List<UserApproval>>(
        stream: approvalsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final approvals = snapshot.data!;

          if (approvals.isEmpty) {
            return const Center(child: Text('No pending approvals'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: approvals.length,
            itemBuilder: (context, index) {
              final approval = approvals[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      approval.user.email,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('User Type: ${approval.user.userType.name}'),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => _showRejectDialog(context, ref, approval.id),
                          child: const Text('Reject'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            final currentUser = ref.read(authStateProvider).value;
                            if (currentUser != null) {
                              await ref.read(userApprovalRepositoryProvider)
                                  .approveUser(approval.id, currentUser.uid);
                            }
                          },
                          child: const Text('Approve'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showRejectDialog(BuildContext context, WidgetRef ref, String approvalId) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reject User'),
          content: TextField(
            controller: reasonController,
            decoration: const InputDecoration(
              labelText: 'Reason for rejection',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final currentUser = ref.read(authStateProvider).value;
                if (currentUser != null && reasonController.text.isNotEmpty) {
                  await ref.read(userApprovalRepositoryProvider)
                      .rejectUser(approvalId, currentUser.uid, reasonController.text);
                  Navigator.pop(context);
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}