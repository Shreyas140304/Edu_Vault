import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:eduvault/models/institution_directory_model.dart';

class ExamSyncResult {
  final String examName;
  final String officialPortal;
  final String? applicationLink;
  final DateTime? applicationDeadline;
  final DateTime? examDate;
  final List<String> requiredDocuments;
  final List<String> timeline;
  final bool isLiveFetched;
  final String sourceLabel;
  final DateTime fetchedAt;

  const ExamSyncResult({
    required this.examName,
    required this.officialPortal,
    this.applicationLink,
    this.applicationDeadline,
    this.examDate,
    required this.requiredDocuments,
    required this.timeline,
    required this.isLiveFetched,
    required this.sourceLabel,
    required this.fetchedAt,
  });

  String buildNotes() {
    final lines = <String>[
      'Source: $sourceLabel',
      'Fetched: ${fetchedAt.toIso8601String()}',
      if (!isLiveFetched) 'Mode: Fallback template (verify on official portal)',
      'Timeline:',
      ...timeline.map((item) => '- $item'),
    ];
    return lines.join('\n');
  }
}

class ExamSyncService {
  Map<String, ExamRegistryEntry>? _registryByName;

  Future<String> normalizeExamName(String examName) async {
    final registry = await _loadRegistry();
    final template = _resolveExamTemplate(registry, examName);
    return template?.examName ?? examName;
  }

  Future<ExamSyncResult> fetchExamDetails(
    String examName, {
    int? targetYear,
  }) async {
    final registry = await _loadRegistry();
    final template = _resolveExamTemplate(registry, examName);

    if (template == null) {
      return ExamSyncResult(
        examName: examName,
        officialPortal: 'Official source not mapped',
        requiredDocuments: const [],
        timeline: const ['Manual verification needed for this exam'],
        isLiveFetched: false,
        sourceLabel: 'No source mapping available',
        fetchedAt: DateTime.now(),
      );
    }

    final year = targetYear ?? (DateTime.now().year + 1);
    final scrapedTimeline = <String>[];
    var liveFetched = false;
    var sourceLabel = template.officialPortal;

    for (final url in template.officialNoticeUrls) {
      final text = await _fetchReadableText(url);
      if (text == null || text.isEmpty) {
        continue;
      }

      final extracted = _extractTimelineFromText(text, year);
      if (extracted.isNotEmpty) {
        scrapedTimeline.addAll(extracted);
        sourceLabel = url;
        liveFetched = true;
      }
    }

    final timeline = scrapedTimeline.isNotEmpty
        ? scrapedTimeline.take(10).toList()
        : template.timelineTemplate;

    return ExamSyncResult(
      examName: template.examName,
      officialPortal: template.officialPortal,
      applicationLink: template.applicationLink,
      applicationDeadline: template.fallbackDeadline,
      examDate: template.fallbackExamDate,
      requiredDocuments: template.requiredDocuments,
      timeline: timeline,
      isLiveFetched: liveFetched,
      sourceLabel: sourceLabel,
      fetchedAt: DateTime.now(),
    );
  }

  Future<Map<String, ExamRegistryEntry>> _loadRegistry() async {
    if (_registryByName != null) {
      return _registryByName!;
    }

    try {
      final raw = await rootBundle.loadString('assets/data/exam_registry.json');
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final exams = (decoded['exams'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map((item) => ExamRegistryEntry.fromJson(item))
          .where((item) => item.examName.trim().isNotEmpty)
          .toList();

      _registryByName = {
        for (final item in exams) item.examName.toLowerCase(): item,
      };
      return _registryByName!;
    } catch (_) {
      _registryByName = {};
      return _registryByName!;
    }
  }

  ExamRegistryEntry? _resolveExamTemplate(
    Map<String, ExamRegistryEntry> registry,
    String examName,
  ) {
    final key = examName.trim().toLowerCase();
    if (registry.containsKey(key)) {
      return registry[key];
    }

    for (final entry in registry.values) {
      for (final alias in entry.aliases) {
        if (alias.trim().toLowerCase() == key) {
          return entry;
        }
      }
    }

    return null;
  }

  Future<String?> _fetchReadableText(String url) async {
    try {
      final response = await http
          .get(Uri.parse(url), headers: const {'User-Agent': 'EduVault/1.0'})
          .timeout(const Duration(seconds: 12));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }
      return _stripHtml(response.body);
    } catch (_) {
      return null;
    }
  }

  String _stripHtml(String html) {
    final noScript = html
        .replaceAll(
          RegExp(r'<script[\s\S]*?</script>', caseSensitive: false),
          ' ',
        )
        .replaceAll(
          RegExp(r'<style[\s\S]*?</style>', caseSensitive: false),
          ' ',
        );
    final plain = noScript.replaceAll(RegExp(r'<[^>]+>'), ' ');
    return plain.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  List<String> _extractTimelineFromText(String text, int year) {
    final keywordPattern = RegExp(
      r'(registration|application|admit card|exam|result|counselling|deadline)',
      caseSensitive: false,
    );
    final datePattern = RegExp(
      r'(\d{1,2}\s+(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\s+'
      '${year.toString()})',
      caseSensitive: false,
    );

    final snippets = <String>[];
    final lines = text
        .replaceAll('.', '.\n')
        .replaceAll('•', '\n')
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.length > 15)
        .take(300)
        .toList();

    for (final line in lines) {
      if (keywordPattern.hasMatch(line) && datePattern.hasMatch(line)) {
        snippets.add(line);
      }
    }

    return snippets.toSet().take(10).toList();
  }
}
