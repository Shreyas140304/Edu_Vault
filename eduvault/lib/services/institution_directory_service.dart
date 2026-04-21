import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:eduvault/models/institution_directory_model.dart';

class InstitutionDirectorySnapshot {
  final List<InstitutionDirectoryEntry> institutions;
  final List<String> boardNames;
  final Map<String, String> boardAliases;
  final Map<String, List<String>> stageRequirements;
  final Map<String, String> stageRequirementSources;
  final DateTime loadedAt;

  const InstitutionDirectorySnapshot({
    required this.institutions,
    required this.boardNames,
    required this.boardAliases,
    required this.stageRequirements,
    required this.stageRequirementSources,
    required this.loadedAt,
  });
}

class InstitutionDirectoryService {
  InstitutionDirectorySnapshot? _cache;

  Future<InstitutionDirectorySnapshot> loadDirectory({
    bool forceReload = false,
  }) async {
    if (!forceReload && _cache != null) {
      return _cache!;
    }

    final ugc = await _loadAssetList('assets/data/ugc_universities.json');
    final aicte = await _loadAssetList('assets/data/aicte_colleges.json');
    final schools = await _loadAssetList('assets/data/school_directory.json');
    final boards = await _loadAssetList('assets/data/state_boards.json');
    final aliases = await _loadAssetMap('assets/data/curated_aliases.json');
    final stageRequirements = await _loadAssetMap(
      'assets/data/stage_document_requirements.json',
    );

    final entries = <InstitutionDirectoryEntry>[
      ...ugc.map((json) => InstitutionDirectoryEntry.fromJson(json)),
      ...aicte.map((json) => InstitutionDirectoryEntry.fromJson(json)),
      ...schools.map((json) => InstitutionDirectoryEntry.fromJson(json)),
      ...boards.map((json) => InstitutionDirectoryEntry.fromJson(json)),
    ];

    final boardNames =
        boards
            .map((item) => item['name']?.toString() ?? '')
            .where((value) => value.trim().isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    final boardAliases = <String, String>{};
    final aliasMap = Map<String, dynamic>.from(
      aliases['board_aliases'] as Map<String, dynamic>? ?? const {},
    );
    for (final key in aliasMap.keys) {
      boardAliases[key.toLowerCase()] = aliasMap[key].toString();
    }

    final stageRequirementMap = <String, List<String>>{};
    final stageSourceMap = <String, String>{};
    for (final stage in stageRequirements.keys) {
      final value = stageRequirements[stage];
      if (value is! Map<String, dynamic>) continue;
      final docs = (value['documents'] as List<dynamic>? ?? const [])
          .map((doc) => doc.toString())
          .where((doc) => doc.trim().isNotEmpty)
          .toList();
      stageRequirementMap[stage] = docs;
      stageSourceMap[stage] = (value['source'] ?? 'Unknown source').toString();
    }

    _cache = InstitutionDirectorySnapshot(
      institutions: entries,
      boardNames: boardNames,
      boardAliases: boardAliases,
      stageRequirements: stageRequirementMap,
      stageRequirementSources: stageSourceMap,
      loadedAt: DateTime.now(),
    );

    return _cache!;
  }

  List<InstitutionDirectoryEntry> searchInstitutions(
    List<InstitutionDirectoryEntry> entries, {
    required String query,
    String? type,
    int limit = 10,
  }) {
    final filtered = entries.where((entry) {
      final typeMatch = type == null || type.isEmpty || entry.type == type;
      return typeMatch && entry.matchesQuery(query);
    }).toList();

    filtered.sort((a, b) => a.name.compareTo(b.name));
    return filtered.take(limit).toList();
  }

  Future<List<Map<String, dynamic>>> ingestRemoteDataset(String url) async {
    final response = await http
        .get(Uri.parse(url), headers: const {'User-Agent': 'EduVault/1.0'})
        .timeout(const Duration(seconds: 15));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Failed to fetch dataset from $url (status ${response.statusCode})',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is List) {
      return decoded
          .whereType<Map<String, dynamic>>()
          .map((row) => Map<String, dynamic>.from(row))
          .toList();
    }

    throw Exception('Unsupported remote dataset format. Expected JSON list.');
  }

  Future<List<Map<String, dynamic>>> _loadAssetList(String path) async {
    try {
      final raw = await rootBundle.loadString(path);
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map((row) => Map<String, dynamic>.from(row))
            .toList();
      }
      return const [];
    } catch (_) {
      return const [];
    }
  }

  Future<Map<String, dynamic>> _loadAssetMap(String path) async {
    try {
      final raw = await rootBundle.loadString(path);
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return const {};
    } catch (_) {
      return const {};
    }
  }
}
