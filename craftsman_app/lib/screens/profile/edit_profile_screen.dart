import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:craftsman_app/localization/app_localizations.dart';
import 'package:craftsman_app/models/user_model.dart';
import 'package:craftsman_app/services/user_repository.dart';

class EditProfileScreen extends StatefulWidget {
  final AppUser user;
  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _phoneController;
  late TextEditingController _craftController;
  late TextEditingController _locationController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.user.phone);
    _craftController = TextEditingController(text: widget.user.craft);
    _locationController = TextEditingController(text: widget.user.location);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Phone field
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: l10n.phone),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              
              // Craft field (if not service seeker)
              if (widget.user.userType != UserType.serviceSeeker)
                TextFormField(
                  controller: _craftController,
                  decoration: InputDecoration(labelText: l10n.craft),
                ),
              const SizedBox(height: 16),
              
              // Location field with map picker
              TextButton(
                onPressed: () => _showLocationPicker(context),
                child: Text(_locationController.text.isEmpty 
                    ? 'Select Location' 
                    : 'Change Location'),
              ),
              if (_locationController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(_locationController.text),
                ),
              const SizedBox(height: 24),
              
              if (_isLoading)
                const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        final updatedUser = widget.user.copyWith(
          phone: _phoneController.text.trim(),
          craft: _craftController.text.trim(),
          location: _locationController.text.trim(),
        );
        
        await UserRepository().saveUserData(updatedUser);
        Navigator.of(context).pop();
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _craftController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}