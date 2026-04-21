import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eduvault/l10n/app_localizations.dart';
import 'package:eduvault/providers/index.dart';

class LanguageSetupScreen extends StatelessWidget {
  const LanguageSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isProfileComplete =
        (ModalRoute.of(context)?.settings.arguments as bool?) ?? false;
    final settingsProvider = context.watch<AppSettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('choose_language'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            context.tr('select_language'),
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          RadioListTile<String>(
            title: Text(context.tr('english')),
            value: 'en',
            groupValue: settingsProvider.languageCode,
            onChanged: (value) async {
              if (value == null) return;
              await settingsProvider.setLanguage(value);
            },
          ),
          RadioListTile<String>(
            title: Text(context.tr('hindi')),
            value: 'hi',
            groupValue: settingsProvider.languageCode,
            onChanged: (value) async {
              if (value == null) return;
              await settingsProvider.setLanguage(value);
            },
          ),
          RadioListTile<String>(
            title: Text(context.tr('marathi')),
            value: 'mr',
            groupValue: settingsProvider.languageCode,
            onChanged: (value) async {
              if (value == null) return;
              await settingsProvider.setLanguage(value);
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushReplacementNamed(
                isProfileComplete ? '/dashboard' : '/profile-setup',
              );
            },
            child: Text(context.tr('continue')),
          ),
        ],
      ),
    );
  }
}
