import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:eduvault/models/index.dart';
import 'package:eduvault/services/index.dart';
import 'package:eduvault/constants/app_constants.dart';

class EntranceExamProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  final ExamSyncService _examSyncService = ExamSyncService();

  List<EntranceExam> _exams = [];
  EntranceExam? _selectedExam;
  bool _isLoading = false;
  String? _error;
  final Map<String, String> _syncStatusByExamId = {};

  /// Getters
  List<EntranceExam> get exams => _exams;
  List<EntranceExam> get activeExams =>
      _exams.where((exam) => exam.isActive == true).toList();
  EntranceExam? get selectedExam => _selectedExam;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? getSyncStatus(String examId) => _syncStatusByExamId[examId];

  /// Load all entrance exams
  Future<void> loadEntranceExams() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _exams = _dbService.getAllEntranceExams();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add entrance exam
  Future<bool> addEntranceExam({
    required String examName,
    DateTime? applicationDeadline,
    DateTime? examDate,
    String? officialPortal,
    String? examLink,
    String? notes,
    bool autoFetchOfficialData = true,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final normalizedExamName = await _examSyncService.normalizeExamName(
        examName,
      );

      ExamSyncResult? syncResult;
      if (autoFetchOfficialData) {
        syncResult = await _examSyncService.fetchExamDetails(
          normalizedExamName,
        );
      }

      // Get default requirements for exam
      final requirements = syncResult?.requiredDocuments.isNotEmpty == true
          ? syncResult!.requiredDocuments
          : (AppConstants.examRequirements[normalizedExamName] ?? []);

      final finalDeadline =
          syncResult?.applicationDeadline ??
          applicationDeadline ??
          DateTime.now().add(const Duration(days: 90));

      final exam = EntranceExam(
        id: const Uuid().v4(),
        examName: normalizedExamName,
        applicationDeadline: finalDeadline,
        examDate: syncResult?.examDate ?? examDate,
        requiredDocuments: requirements,
        uploadedDocumentIds: [],
        officialPortal: syncResult?.officialPortal ?? officialPortal,
        examLink: syncResult?.applicationLink ?? examLink,
        lastUpdated: DateTime.now(),
        notes: syncResult?.buildNotes() ?? notes,
        isActive: true,
        applicationStatus: 'Not Started',
      );

      await _dbService.addEntranceExam(exam);
      _exams.add(exam);
      _syncStatusByExamId[exam.id ?? ''] = syncResult == null
          ? 'Manual mode'
          : (syncResult.isLiveFetched
                ? 'Synced from ${syncResult.sourceLabel}'
                : 'Synced with fallback template');

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

  Future<bool> syncExamFromOfficialSource(String examId) async {
    try {
      final examIndex = _exams.indexWhere((exam) => exam.id == examId);
      if (examIndex == -1) return false;

      _isLoading = true;
      _error = null;
      notifyListeners();

      final current = _exams[examIndex];
      final name = current.examName;
      if (name == null || name.trim().isEmpty) {
        _isLoading = false;
        _error = 'Exam name is missing';
        notifyListeners();
        return false;
      }

      final syncResult = await _examSyncService.fetchExamDetails(name);
      final updated = current.copyWith(
        applicationDeadline:
            syncResult.applicationDeadline ?? current.applicationDeadline,
        examDate: syncResult.examDate ?? current.examDate,
        requiredDocuments: syncResult.requiredDocuments.isNotEmpty
            ? syncResult.requiredDocuments
            : current.requiredDocuments,
        officialPortal: syncResult.officialPortal,
        examLink: syncResult.applicationLink ?? current.examLink,
        notes: syncResult.buildNotes(),
        lastUpdated: DateTime.now(),
      );

      _exams[examIndex] = updated;
      await _dbService.addEntranceExam(updated);
      _syncStatusByExamId[examId] = syncResult.isLiveFetched
          ? 'Synced from ${syncResult.sourceLabel}'
          : 'Synced with fallback template';

      if (_selectedExam?.id == examId) {
        _selectedExam = updated;
      }

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

  Future<void> syncAllExamsFromOfficialSources() async {
    for (final exam in _exams) {
      final id = exam.id;
      if (id == null) continue;
      await syncExamFromOfficialSource(id);
    }
  }

  /// Select entrance exam
  void selectEntranceExam(EntranceExam exam) {
    _selectedExam = exam;
    notifyListeners();
  }

  /// Update exam status
  Future<bool> updateExamStatus(String examId, String status) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final examIndex = _exams.indexWhere((exam) => exam.id == examId);
      if (examIndex != -1) {
        _exams[examIndex] = _exams[examIndex].copyWith(
          applicationStatus: status,
          lastUpdated: DateTime.now(),
        );

        await _dbService.addEntranceExam(_exams[examIndex]);

        if (_selectedExam?.id == examId) {
          _selectedExam = _exams[examIndex];
        }
      }

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

  /// Add uploaded document to exam
  Future<bool> addUploadedDocumentToExam(
    String examId,
    String documentId,
  ) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final examIndex = _exams.indexWhere((exam) => exam.id == examId);
      if (examIndex != -1) {
        final uploadedDocs = _exams[examIndex].uploadedDocumentIds ?? [];
        if (!uploadedDocs.contains(documentId)) {
          uploadedDocs.add(documentId);

          _exams[examIndex] = _exams[examIndex].copyWith(
            uploadedDocumentIds: uploadedDocs,
            lastUpdated: DateTime.now(),
          );

          await _dbService.addEntranceExam(_exams[examIndex]);

          if (_selectedExam?.id == examId) {
            _selectedExam = _exams[examIndex];
          }
        }
      }

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

  /// Remove uploaded document from exam
  Future<bool> removeUploadedDocumentFromExam(
    String examId,
    String documentId,
  ) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final examIndex = _exams.indexWhere((exam) => exam.id == examId);
      if (examIndex != -1) {
        final uploadedDocs = _exams[examIndex].uploadedDocumentIds ?? [];
        uploadedDocs.remove(documentId);

        _exams[examIndex] = _exams[examIndex].copyWith(
          uploadedDocumentIds: uploadedDocs,
          lastUpdated: DateTime.now(),
        );

        await _dbService.addEntranceExam(_exams[examIndex]);

        if (_selectedExam?.id == examId) {
          _selectedExam = _exams[examIndex];
        }
      }

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

  /// Update exam requirements
  Future<bool> updateExamRequirements(
    String examId,
    List<String> requirements,
  ) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final examIndex = _exams.indexWhere((exam) => exam.id == examId);
      if (examIndex != -1) {
        _exams[examIndex] = _exams[examIndex].copyWith(
          requiredDocuments: requirements,
          lastUpdated: DateTime.now(),
        );

        await _dbService.addEntranceExam(_exams[examIndex]);

        if (_selectedExam?.id == examId) {
          _selectedExam = _exams[examIndex];
        }
      }

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

  /// Delete entrance exam
  Future<bool> deleteEntranceExam(String examId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _dbService.deleteEntranceExam(examId);
      _exams.removeWhere((exam) => exam.id == examId);

      if (_selectedExam?.id == examId) {
        _selectedExam = null;
      }

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

  /// Get exams with approaching deadlines
  List<EntranceExam> getExamsWithApproachingDeadlines() {
    return _exams.where((exam) => exam.isDeadlineApproaching()).toList();
  }

  /// Get exams with passed deadlines
  List<EntranceExam> getExamsWithPassedDeadlines() {
    return _exams.where((exam) => exam.isDeadlinePassed()).toList();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
