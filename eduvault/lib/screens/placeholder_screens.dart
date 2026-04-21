import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: const Center(child: Text('Notifications feature coming soon')),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(child: Text('Settings feature coming soon')),
    );
  }
}

class StageDetailsScreen extends StatelessWidget {
  final String stage;

  const StageDetailsScreen({Key? key, required this.stage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$stage Documents')),
      body: Center(child: Text('Details for $stage coming soon')),
    );
  }
}

class ExamDetailsScreen extends StatelessWidget {
  const ExamDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exam Details')),
      body: const Center(child: Text('Exam details feature coming soon')),
    );
  }
}

