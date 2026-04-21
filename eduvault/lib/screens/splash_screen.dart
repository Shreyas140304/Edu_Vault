import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eduvault/constants/app_colors.dart';
import 'package:eduvault/l10n/app_localizations.dart';
import 'package:eduvault/providers/index.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInCubic),
    );

    _animationController.forward();

    _initializeAndNavigate();
  }

  void _initializeAndNavigate() {
    _navigationTimer = Timer(
      const Duration(milliseconds: 2500),
      _loadProfileAndNavigate,
    );
  }

  Future<void> _loadProfileAndNavigate() async {
    // Load user profile
    if (mounted) {
      final userProvider = context.read<UserProvider>();
      final settingsProvider = context.read<AppSettingsProvider>();
      await settingsProvider.loadSettings();
      await userProvider.loadUserProfile();

      if (mounted) {
        if (!settingsProvider.hasLanguageSelection) {
          Navigator.of(context).pushReplacementNamed(
            '/language-setup',
            arguments: userProvider.isProfileComplete,
          );
          return;
        }

        // Navigate based on profile existence
        if (userProvider.isProfileComplete) {
          Navigator.of(context).pushReplacementNamed('/dashboard');
        } else {
          Navigator.of(context).pushReplacementNamed('/profile-setup');
        }
      }
    }
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowColor,
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.folder_open,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 32),
            FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  Text(
                    context.tr('app_name'),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.tr('splash_tagline'),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
