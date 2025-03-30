import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:craftsman_app/providers/auth_provider.dart';

class VerificationBadge extends ConsumerWidget {
  final double size;
  final Color? verifiedColor;
  final Color? unverifiedColor;

  const VerificationBadge({
    this.size = 20,
    this.verifiedColor = Colors.green,
    this.unverifiedColor = Colors.orange,
    super.key
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final isVerified = user?.emailVerified ?? false;

    return Tooltip(
      message: isVerified 
          ? 'Verified email address'
          : 'Email not verified',
      child: Icon(
        isVerified ? Icons.verified : Icons.warning,
        size: size,
        color: isVerified ? verifiedColor : unverifiedColor,
      ),
    );
  }
}