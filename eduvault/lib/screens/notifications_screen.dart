import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eduvault/l10n/app_localizations.dart';
import 'package:eduvault/providers/index.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('notifications')),
        actions: [
          IconButton(
            onPressed: provider.items.isEmpty
                ? null
                : () => provider.clearAll(),
            icon: const Icon(Icons.delete_sweep_outlined),
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.items.isEmpty
          ? Center(child: Text(context.tr('no_notifications')))
          : ListView.builder(
              itemCount: provider.items.length,
              itemBuilder: (context, index) {
                final item = provider.items[index];
                return Dismissible(
                  key: ValueKey(item.id ?? index),
                  background: Container(color: Colors.red),
                  onDismissed: (_) {
                    if (item.id != null) {
                      provider.deleteNotification(item.id!);
                    }
                  },
                  child: ListTile(
                    leading: Icon(
                      item.isRead == true
                          ? Icons.notifications_none
                          : Icons.notifications_active,
                    ),
                    title: Text(item.title ?? context.tr('notifications')),
                    subtitle: Text(item.message ?? ''),
                    trailing: Text(item.getFormattedDate()),
                    onTap: () {
                      if (item.id != null) {
                        provider.markAsRead(item.id!);
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}
