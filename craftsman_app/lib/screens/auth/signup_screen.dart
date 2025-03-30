import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:craftsman_app/localization/app_localizations.dart';
import 'package:craftsman_app/models/user_model.dart';
import 'package:craftsman_app/services/auth_service.dart';
import 'package:craftsman_app/screens/auth/verify_email_screen.dart';
import 'package:craftsman_app/services/user_repository.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _craftController = TextEditingController();
  
  UserType _userType = UserType.serviceSeeker;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    
    return Scaffold(
      appBar: AppBar(title: Text(l10n.signup)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Email field
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: l10n.email),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Password field
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: l10n.password),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Confirm Password field
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Phone field
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),
              
              // User Type selection
              Text('Select User Type', style: Theme.of(context).textTheme.titleMedium),
              Column(
                children: UserType.values.map((type) {
                  return RadioListTile<UserType>(
                    title: Text(type.displayName),
                    value: type,
                    groupValue: _userType,
                    onChanged: (value) {
                      setState(() => _userType = value!);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              
              // Craft field (only for craftsmen and learners)
              if (_userType != UserType.serviceSeeker)
                TextFormField(
                  controller: _craftController,
                  decoration: InputDecoration(
                    labelText: 'Your Craft',
                    hintText: 'e.g. Carpentry, Pottery, etc.',
                  ),
                  validator: (value) {
                    if (_userType != UserType.serviceSeeker && 
                        (value == null || value.isEmpty)) {
                      return 'Please specify your craft';
                    }
                    return null;
                  },
                ),
              
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Theme.of(context).errorColor),
                  ),
                ),
              
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _signUp,
                child: _isLoading 
                    ? const CircularProgressIndicator()
                    : Text(l10n.signup),
              ),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text('Verification email sent - please check your inbox'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final auth = ref.read(authServiceProvider);
        final userCredential = await auth.signUpWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _userType,
        );
        
        // Save user data to Firestore
        final user = AppUser(
          uid: userCredential.user!.uid,
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          userType: _userType,
          craft: _userType != UserType.serviceSeeker 
              ? _craftController.text.trim()
              : null,
        );
        
        await UserRepository().saveUserData(user);
        
        // Navigate to verification screen
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const VerifyEmailScreen(),
            ),
          );
        }
        
      } on FirebaseAuthException catch (e) {
        setState(() {
          _errorMessage = _getErrorMessage(e.code);
        });
      } finally {
        if (mounted && _errorMessage != null) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Email already in use';
      case 'invalid-email':
        return 'Invalid email address';
      case 'weak-password':
        return 'Password is too weak';
      default:
        return 'Sign up failed. Please try again';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _craftController.dispose();
    super.dispose();
  }
}