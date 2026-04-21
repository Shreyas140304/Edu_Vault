import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import 'package:eduvault/constants/app_colors.dart';
import 'package:eduvault/l10n/app_localizations.dart';
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
        ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => DocumentProvider()),
        ChangeNotifierProvider(create: (_) => EntranceExamProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(
          create: (_) => InstitutionProvider()..loadDirectory(),
        ),
      ],
      child: Consumer<AppSettingsProvider>(
        builder: (context, settingsProvider, _) {
          return MaterialApp(
            title: 'EduVault',
            theme: AppTheme.lightTheme,
            locale: settingsProvider.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const SplashScreen(),
            onGenerateRoute: AppRouter.generateRoute,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
