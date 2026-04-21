import 'package:flutter/material.dart';
import 'package:eduvault/screens/dashboard_screen.dart';
import 'package:eduvault/screens/profile_setup_screen.dart';
import 'package:eduvault/screens/placeholder_screens.dart';
import 'package:eduvault/screens/search_screen.dart';
import 'package:eduvault/screens/upload_document_screen.dart';
import 'package:eduvault/screens/add_exam_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/dashboard':
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case '/profile-setup':
        return MaterialPageRoute(builder: (_) => const ProfileSetupScreen());
      case '/search':
        return MaterialPageRoute(builder: (_) => const SearchScreen());
      case '/notifications':
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case '/stage-details':
        final stage = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => StageDetailsScreen(stage: stage),
        );
      case '/exam-details':
        return MaterialPageRoute(builder: (_) => const ExamDetailsScreen());
      case '/upload-document':
        return MaterialPageRoute(builder: (_) => const UploadDocumentScreen());
      case '/add-exam':
        return MaterialPageRoute(builder: (_) => const AddExamScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(child: Text('Route not found')),
          ),
        );
    }
  }
}
