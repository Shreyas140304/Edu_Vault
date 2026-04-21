import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class AppSettingsProvider extends ChangeNotifier {
  static const String _boxName = 'app_settings';
  static const String _keyLanguage = 'language_code';
  static const String _keyProfileImage = 'profile_image_path';
  static const String _keyQualifications = 'qualifications_json';

  String _languageCode = 'en';
  bool _languageSelected = false;
  String? _profileImagePath;
  List<Map<String, String>> _qualifications = [];
  bool _isLoading = false;

  String get languageCode => _languageCode;
  String? get profileImagePath => _profileImagePath;
  List<Map<String, String>> get qualifications => _qualifications;
  bool get isLoading => _isLoading;
  bool get hasLanguageSelection => _languageSelected;

  Locale get locale {
    switch (_languageCode) {
      case 'hi':
        return const Locale('hi');
      case 'mr':
        return const Locale('mr');
      default:
        return const Locale('en');
    }
  }

  Future<void> loadSettings() async {
    try {
      _isLoading = true;
      notifyListeners();

      try {
        final box = await _openBox();
        final savedLanguage = box.get(_keyLanguage) as String?;
        _languageSelected =
            savedLanguage != null && savedLanguage.trim().isNotEmpty;
        _languageCode = savedLanguage ?? 'en';
        _profileImagePath = box.get(_keyProfileImage) as String?;

        final rawQualifications = box.get(_keyQualifications) as String?;
        if (rawQualifications != null && rawQualifications.trim().isNotEmpty) {
          final decoded = jsonDecode(rawQualifications);
          if (decoded is List) {
            _qualifications = decoded
                .whereType<Map<String, dynamic>>()
                .map(
                  (row) => row.map(
                    (key, value) => MapEntry(key.toString(), value.toString()),
                  ),
                )
                .toList();
          }
        }
      } catch (_) {
        _languageCode = 'en';
        _languageSelected = false;
        _profileImagePath = null;
        _qualifications = [];
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setLanguage(String languageCode) async {
    _languageCode = languageCode;
    _languageSelected = true;
    final box = await _openBox();
    await box.put(_keyLanguage, languageCode);
    notifyListeners();
  }

  Future<void> setProfileImagePath(String? path) async {
    _profileImagePath = path;
    final box = await _openBox();
    if (path == null || path.trim().isEmpty) {
      await box.delete(_keyProfileImage);
    } else {
      await box.put(_keyProfileImage, path);
    }
    notifyListeners();
  }

  Future<void> saveQualifications(List<Map<String, String>> items) async {
    _qualifications = items;
    final box = await _openBox();
    await box.put(_keyQualifications, jsonEncode(items));
    notifyListeners();
  }

  Future<void> clearProfileSettings() async {
    _profileImagePath = null;
    _qualifications = [];
    final box = await _openBox();
    await box.delete(_keyProfileImage);
    await box.delete(_keyQualifications);
    notifyListeners();
  }

  Future<Box<dynamic>> _openBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<dynamic>(_boxName);
    }
    return Hive.openBox<dynamic>(_boxName);
  }
}
