import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eduvault/l10n/app_localizations.dart';
import 'package:eduvault/providers/index.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appSettings = context.watch<AppSettingsProvider>();
    final notificationProvider = context.watch<NotificationProvider>();
    final examProvider = context.watch<EntranceExamProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('settings'))),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(context.tr('edit_profile')),
            onTap: () => Navigator.of(context).pushNamed('/profile'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(context.tr('language')),
            subtitle: Text(
              appSettings.languageCode == 'hi'
                  ? context.tr('hindi')
                  : appSettings.languageCode == 'mr'
                  ? context.tr('marathi')
                  : context.tr('english'),
            ),
            onTap: () => Navigator.of(
              context,
            ).pushNamed('/language-setup', arguments: true),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.sync),
            title: Text(context.tr('sync_entrance_exams')),
            subtitle: Text(context.tr('sync_exam_subtitle')),
            onTap: () async {
              await examProvider.syncAllExamsFromOfficialSources();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.tr('exam_sync_completed'))),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.notifications_active_outlined),
            title: Text(context.tr('send_test_notification')),
            onTap: () async {
              await notificationProvider.sendTestNotification();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.tr('test_notification_sent'))),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: Text(
              context.tr('delete_profile'),
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(context.tr('delete_profile_confirm_title')),
                  content: Text(context.tr('delete_profile_confirm_text')),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(context.tr('cancel')),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(context.tr('delete')),
                    ),
                  ],
                ),
              );
              if (confirm != true || !context.mounted) return;
              await context.read<UserProvider>().deleteUserProfile();
              await context.read<AppSettingsProvider>().clearProfileSettings();
              if (!context.mounted) return;
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/profile-setup', (route) => false);
            },
          ),
        ],
      ),
    );
  }
}
