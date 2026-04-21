import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:eduvault/models/index.dart';
import 'package:eduvault/services/index.dart';

class UserProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _error;

  /// Getters
  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isProfileComplete => _userProfile?.isProfileComplete ?? false;

  /// Load user profile
  Future<void> loadUserProfile() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _userProfile = _dbService.getUserProfile();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create user profile
  Future<bool> createUserProfile({
    required String fullName,
    required String schoolName,
    required String board,
    required String collegeName,
    required String universityName,
    required String state,
    required String country,
    required List<String> targetExams,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final profile = UserProfile(
        id: const Uuid().v4(),
        fullName: fullName,
        schoolName: schoolName,
        board: board,
        collegeName: collegeName,
        universityName: universityName,
        state: state,
        country: country,
        targetExams: targetExams,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isProfileComplete: true,
      );

      await _dbService.saveUserProfile(profile);
      _userProfile = profile;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update user profile
  Future<bool> updateUserProfile({
    String? fullName,
    String? schoolName,
    String? board,
    String? collegeName,
    String? universityName,
    String? state,
    String? country,
    List<String>? targetExams,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (_userProfile == null) {
        throw Exception('User profile not found');
      }

      _userProfile = _userProfile!.copyWith(
        fullName: fullName ?? _userProfile!.fullName,
        schoolName: schoolName ?? _userProfile!.schoolName,
        board: board ?? _userProfile!.board,
        collegeName: collegeName ?? _userProfile!.collegeName,
        universityName: universityName ?? _userProfile!.universityName,
        state: state ?? _userProfile!.state,
        country: country ?? _userProfile!.country,
        targetExams: targetExams ?? _userProfile!.targetExams,
        updatedAt: DateTime.now(),
      );

      await _dbService.saveUserProfile(_userProfile!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Add target exam
  Future<bool> addTargetExam(String examName) async {
    try {
      if (_userProfile == null) {
        throw Exception('User profile not found');
      }

      final targetExams = _userProfile!.targetExams ?? [];
      if (!targetExams.contains(examName)) {
        targetExams.add(examName);
        _userProfile = _userProfile!.copyWith(
          targetExams: targetExams,
          updatedAt: DateTime.now(),
        );

        await _dbService.saveUserProfile(_userProfile!);
        notifyListeners();
      }

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Remove target exam
  Future<bool> removeTargetExam(String examName) async {
    try {
      if (_userProfile == null) {
        throw Exception('User profile not found');
      }

      final targetExams = _userProfile!.targetExams ?? [];
      targetExams.remove(examName);

      _userProfile = _userProfile!.copyWith(
        targetExams: targetExams,
        updatedAt: DateTime.now(),
      );

      await _dbService.saveUserProfile(_userProfile!);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> deleteUserProfile() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _dbService.deleteUserProfile();
      _userProfile = null;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
