import 'package:flutter/material.dart';
import 'package:eduvault/models/institution_directory_model.dart';
import 'package:eduvault/services/institution_directory_service.dart';

class InstitutionProvider extends ChangeNotifier {
  final InstitutionDirectoryService _service = InstitutionDirectoryService();

  List<InstitutionDirectoryEntry> _institutions = [];
  List<String> _boards = [];
  Map<String, String> _boardAliases = {};
  Map<String, List<String>> _stageRequirements = {};
  Map<String, String> _stageRequirementSources = {};
  bool _isLoading = false;
  String? _error;
  DateTime? _lastSyncedAt;

  List<InstitutionDirectoryEntry> get institutions => _institutions;
  List<String> get boards => _boards;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastSyncedAt => _lastSyncedAt;
  List<String> getStageRequirements(String stage) =>
      _stageRequirements[stage] ?? const [];
  String? getStageRequirementSource(String stage) =>
      _stageRequirementSources[stage];

  Future<void> loadDirectory({bool forceReload = false}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final snapshot = await _service.loadDirectory(forceReload: forceReload);
      _institutions = snapshot.institutions;
      _boards = snapshot.boardNames;
      _boardAliases = snapshot.boardAliases;
      _stageRequirements = snapshot.stageRequirements;
      _stageRequirementSources = snapshot.stageRequirementSources;
      _lastSyncedAt = snapshot.loadedAt;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  String normalizeBoardName(String input) {
    final key = input.trim().toLowerCase();
    return _boardAliases[key] ?? input;
  }

  List<InstitutionDirectoryEntry> searchSchools(String query, {int limit = 8}) {
    return _service.searchInstitutions(
      _institutions,
      query: query,
      type: 'school',
      limit: limit,
    );
  }

  List<InstitutionDirectoryEntry> searchColleges(
    String query, {
    int limit = 8,
  }) {
    return _service.searchInstitutions(
      _institutions,
      query: query,
      type: 'college',
      limit: limit,
    );
  }

  List<InstitutionDirectoryEntry> searchUniversities(
    String query, {
    int limit = 8,
  }) {
    return _service.searchInstitutions(
      _institutions,
      query: query,
      type: 'university',
      limit: limit,
    );
  }

  List<InstitutionDirectoryEntry> searchAll(String query, {int limit = 10}) {
    return _service.searchInstitutions(
      _institutions,
      query: query,
      limit: limit,
    );
  }
}
