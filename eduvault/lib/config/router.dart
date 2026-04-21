import 'package:flutter/material.dart';
import 'package:eduvault/models/entrance_exam_model.dart';
import 'package:eduvault/screens/dashboard_screen.dart';
import 'package:eduvault/screens/profile_setup_screen.dart';
import 'package:eduvault/screens/placeholder_screens.dart';
import 'package:eduvault/screens/notifications_screen.dart';
import 'package:eduvault/screens/settings_screen.dart';
import 'package:eduvault/screens/profile_screen.dart';
import 'package:eduvault/screens/language_setup_screen.dart';
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
      case '/language-setup':
        return MaterialPageRoute(builder: (_) => const LanguageSetupScreen());
      case '/notifications':
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case '/stage-details':
        final stage = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => StageDetailsScreen(stage: stage),
        );
      case '/exam-details':
        final exam = settings.arguments as EntranceExam?;
        return MaterialPageRoute(builder: (_) => ExamDetailsScreen(exam: exam));
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
