import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import 'package:eduvault/constants/app_colors.dart';
import 'package:eduvault/providers/index.dart';
import 'package:eduvault/services/index.dart';
import 'package:eduvault/screens/splash_screen.dart';
import 'package:eduvault/config/router.dart';

final Logger _logger = Logger();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await _initializeServices();

  runApp(const EduVaultApp());
}

Future<void> _initializeServices() async {
  final initializers = <Future<void> Function()>[
    () => DatabaseService().init(),
    () => FileStorageService().init(),
    () => OcrService().init(),
    () => NotificationService().init(),
  ];

  for (final initialize in initializers) {
    try {
      await initialize();
    } catch (e, stackTrace) {
      _logger.w(
        'Service initialization skipped because it failed: $e',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}

class EduVaultApp extends StatelessWidget {
  const EduVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => DocumentProvider()),
        ChangeNotifierProvider(create: (_) => EntranceExamProvider()),
      ],
      child: MaterialApp(
        title: 'EduVault',
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
        onGenerateRoute: AppRouter.generateRoute,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
