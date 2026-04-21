class InstitutionDirectoryEntry {
  final String id;
  final String name;
  final String type;
  final String source;
  final String? state;
  final String? country;
  final String? website;
  final List<String> aliases;
  final Map<String, dynamic> metadata;

  const InstitutionDirectoryEntry({
    required this.id,
    required this.name,
    required this.type,
    required this.source,
    this.state,
    this.country,
    this.website,
    this.aliases = const [],
    this.metadata = const {},
  });

  factory InstitutionDirectoryEntry.fromJson(Map<String, dynamic> json) {
    return InstitutionDirectoryEntry(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      type: (json['type'] ?? 'other').toString(),
      source: (json['source'] ?? 'unknown').toString(),
      state: json['state']?.toString(),
      country: json['country']?.toString(),
      website: json['website']?.toString(),
      aliases: (json['aliases'] as List<dynamic>? ?? const [])
          .map((value) => value.toString())
          .toList(),
      metadata: Map<String, dynamic>.from(
        (json['metadata'] as Map<String, dynamic>?) ?? const {},
      ),
    );
  }

  bool matchesQuery(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    if (name.toLowerCase().contains(q)) return true;
    for (final alias in aliases) {
      if (alias.toLowerCase().contains(q)) {
        return true;
      }
    }
    return false;
  }
}

class ExamRegistryEntry {
  final String examName;
  final List<String> aliases;
  final String officialPortal;
  final String? applicationLink;
  final List<String> requiredDocuments;
  final List<String> officialNoticeUrls;
  final List<String> timelineTemplate;
  final DateTime? fallbackDeadline;
  final DateTime? fallbackExamDate;

  const ExamRegistryEntry({
    required this.examName,
    required this.aliases,
    required this.officialPortal,
    this.applicationLink,
    required this.requiredDocuments,
    required this.officialNoticeUrls,
    required this.timelineTemplate,
    this.fallbackDeadline,
    this.fallbackExamDate,
  });

  factory ExamRegistryEntry.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      try {
        return DateTime.parse(value.toString());
      } catch (_) {
        return null;
      }
    }

    return ExamRegistryEntry(
      examName: (json['exam_name'] ?? '').toString(),
      aliases: (json['aliases'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      officialPortal: (json['official_portal'] ?? '').toString(),
      applicationLink: json['application_link']?.toString(),
      requiredDocuments:
          (json['required_documents'] as List<dynamic>? ?? const [])
              .map((item) => item.toString())
              .toList(),
      officialNoticeUrls:
          (json['official_notice_urls'] as List<dynamic>? ?? const [])
              .map((item) => item.toString())
              .toList(),
      timelineTemplate:
          (json['timeline_template'] as List<dynamic>? ?? const [])
              .map((item) => item.toString())
              .toList(),
      fallbackDeadline: parseDate(json['fallback_deadline']),
      fallbackExamDate: parseDate(json['fallback_exam_date']),
    );
  }
}
