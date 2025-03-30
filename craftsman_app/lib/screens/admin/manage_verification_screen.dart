import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:craftsman_app/models/user_model.dart';
import 'package:craftsman_app/services/user_repository.dart';
import 'package:craftsman_app/widgets/verification_badge.dart';

class ManageVerificationScreen extends ConsumerWidget {
  final AppUser user;

  const ManageVerificationScreen({required this.user, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRepo = ref.read(userRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Verification')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User: ${user.email}', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Verification Status: '),
                VerificationBadge(size: 20),
                const SizedBox(width: 8),
                Text(
                  user.isVerified
                    ? (user.isEmailVerified ? 'Email Verified' : 'Manually Verified')
                    : 'Not Verified',
                ),
              ],
            ),
            if (user.isManuallyVerified) ...[
              const SizedBox(height: 8),
              Text('Verified by: ${user.verifiedBy ?? 'Admin'}'),
              Text('Date: ${user.verificationDate?.toLocal().toString() ?? 'Unknown'}'),
            ],
            const SizedBox(height: 24),
            if (!user.isVerified)
              ElevatedButton(
                onPressed: () async {
                  final currentUser = ref.read(authStateProvider).value;
                  if (currentUser != null) {
                    await userRepo.manuallyVerifyUser(
                      user.uid,
                      currentUser.uid,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User manually verified')),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Manually Verify User'),
              ),
            if (user.isManuallyVerified)
              OutlinedButton(
                onPressed: () async {
                  await userRepo.revokeManualVerification(user.uid);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Manual verification revoked')),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Revoke Manual Verification'),
              ),
          ],
        ),
      ),
    );
  }
}