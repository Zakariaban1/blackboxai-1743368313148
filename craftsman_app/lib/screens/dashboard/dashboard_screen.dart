import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:craftsman_app/localization/app_localizations.dart';
import 'package:craftsman_app/models/user_model.dart';
import 'package:craftsman_app/providers/auth_provider.dart';
import 'package:craftsman_app/screens/craft_search/search_screen.dart';
import 'package:craftsman_app/screens/job_requests/job_request_list.dart';
import 'package:craftsman_app/screens/profile/profile_screen.dart';
import 'package:craftsman_app/screens/learning/learning_content_screen.dart';
import 'package:craftsman_app/screens/learning/learning_path_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final userAsync = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (user) {
          if (user == null) return const Center(child: Text('Please sign in'));
          return _buildDashboard(context, user);
        },
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildDashboard(BuildContext context, User? user) {
    switch (user?.userType) {
      case UserType.craftsman:
        return const JobRequestList();
      case UserType.serviceSeeker:
        return const SearchScreen();
      case UserType.learner:
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: Text('${user.craft ?? 'General'} Learning'),
              bottom: const TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.library_books), text: 'Content'),
                  Tab(icon: Icon(Icons.auto_stories), text: 'Paths'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                LearningContentScreen(craft: user.craft ?? 'General'),
                LearningPathScreen(craft: user.craft ?? 'General'),
              ],
            ),
          ),
        );
      default:
        return const Center(child: Text('Welcome to Craftsman App'));
    }
  }

  BottomNavigationBar _buildBottomNavBar(BuildContext context) {
    final l10n = context.l10n;
    
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: l10n.home,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.search),
          label: l10n.search,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person),
          label: l10n.profile,
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
            );
            break;
          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SearchScreen()),
            );
            break;
          case 2:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
            break;
        }
      },
    );
  }
}