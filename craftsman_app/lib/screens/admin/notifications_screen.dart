import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:craftsman_app/models/notification_model.dart';
import 'package:craftsman_app/providers/auth_provider.dart';
import 'package:craftsman_app/services/notification_service.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authStateProvider).value;
    final notificationsStream = currentUser != null
        ? ref.watch(notificationServiceProvider).getUserNotifications(currentUser.uid)
        : const Stream.empty();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: StreamBuilder<List<AppNotification>>(
        stream: notificationsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data!;

          if (notifications.isEmpty) {
            return const Center(child: Text('No notifications'));
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return Dismissible(
                key: Key(notification.id),
                background: Container(color: Colors.red),
                onDismissed: (direction) {
                  ref.read(notificationServiceProvider)
                      .deleteNotification(notification.id);
                },
                child: ListTile(
                  title: Text(notification.title),
                  subtitle: Text(notification.body),
                  trailing: notification.isRead
                      ? null
                      : const Icon(Icons.circle, color: Colors.blue, size: 12),
                  onTap: () {
                    _handleNotificationTap(notification);
                    if (!notification.isRead) {
                      ref.read(notificationServiceProvider)
                          .markAsRead(notification.id);
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _handleNotificationTap(AppNotification notification) {
    // TODO: Implement navigation based on notification type
  }
}