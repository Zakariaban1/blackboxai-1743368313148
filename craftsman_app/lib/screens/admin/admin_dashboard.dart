import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:craftsman_app/localization/app_localizations.dart';
import 'package:craftsman_app/screens/learning/content_creation_screen.dart';
import 'package:craftsman_app/screens/learning/learning_path_creation_screen.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    
    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminDashboard)),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildDashboardCard(
            context,
            icon: Icons.library_add,
            title: 'Create Content',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ContentCreationScreen(),
                ),
              );
            },
          ),
          _buildDashboardCard(
            context,
            icon: Icons.auto_stories,
            title: 'Create Learning Path',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LearningPathCreationScreen(),
                ),
              );
            },
          ),
          _buildDashboardCard(
            context,
            icon: Icons.analytics,
            title: 'View Analytics',
            onTap: () {
              // TODO: Implement analytics screen
            },
          ),
          _buildDashboardCard(
            context,
            icon: Icons.manage_accounts,
            title: 'Manage Users',
            onTap: () {
              // TODO: Implement user management
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}