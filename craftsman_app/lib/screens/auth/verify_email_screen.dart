import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:craftsman_app/services/auth_service.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  bool _isLoading = false;
  bool _isVerified = false;
  bool _canResend = true;
  int _cooldownSeconds = 30;

  @override
  void initState() {
    super.initState();
    _checkVerificationStatus();
  }

  Future<void> _checkVerificationStatus() async {
    final user = ref.read(authStateProvider).value;
    if (user != null) {
      await user.reload();
      setState(() {
        _isVerified = user.emailVerified;
      });
    }
  }

  Future<void> _resendVerification() async {
    setState(() {
      _isLoading = true;
      _canResend = false;
    });

    try {
      await ref.read(authServiceProvider).sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification email sent'),
          duration: Duration(seconds: 3),
        ),
      );

      // Start cooldown timer
      for (var i = _cooldownSeconds; i > 0; i--) {
        if (mounted) {
          setState(() => _cooldownSeconds = i);
        }
        await Future.delayed(const Duration(seconds: 1));
      }

      if (mounted) {
        setState(() {
          _canResend = true;
          _cooldownSeconds = 30;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send: ${e.toString()}'),
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isVerified ? Icons.verified : Icons.mark_email_unread,
                size: 80,
                color: _isVerified ? Colors.green : Colors.orange,
              ),
              const SizedBox(height: 20),
              Text(
                _isVerified 
                    ? 'Your email has been verified!'
                    : 'Please verify your email address',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              if (!_isVerified) ...[
                const Text(
                  'We sent a verification link to your email address',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  icon: const Icon(Icons.email),
                  label: Text(_canResend 
                      ? 'Resend Verification' 
                      : 'Resend in $_cooldownSeconds sec'),
                  onPressed: _canResend && !_isLoading 
                      ? _resendVerification 
                      : null,
                ),
                if (_isLoading) const SizedBox(height: 20),
                if (_isLoading) const CircularProgressIndicator(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}