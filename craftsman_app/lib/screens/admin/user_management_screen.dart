import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:craftsman_app/models/user_model.dart';
import 'package:craftsman_app/services/user_repository.dart';

class UserManagementScreen extends ConsumerWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersFuture = ref.watch(userRepositoryProvider).getAllUsers();

    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: FutureBuilder<List<AppUser>>(
        future: usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Error loading users'));
          }

          final users = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text('Role: ${user.userType.name}'),
                      const SizedBox(height: 8),
                      DropdownButton<UserType>(
                        value: user.userType,
                        items: UserType.values.map((type) {
                          return DropdownMenuItem<UserType>(
                            value: type,
                            child: Text(type.name),
                          );
                        }).toList(),
                        onChanged: (newType) {
                          if (newType != null) {
                            ref.read(userRepositoryProvider)
                                .updateUserType(user.uid, newType);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}