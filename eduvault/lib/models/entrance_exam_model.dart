import 'package:hive/hive.dart';

part 'entrance_exam_model.g.dart';

@HiveType(typeId: 2)
class EntranceExam extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? examName;

  @HiveField(2)
  DateTime? applicationDeadline;

  @HiveField(3)
  DateTime? examDate;

  @HiveField(4)
  List<String>? requiredDocuments;

  @HiveField(5)
  List<String>? uploadedDocumentIds;

  @HiveField(6)
  String? examLink;

  @HiveField(7)
  String? officialPortal;

  @HiveField(8)
  DateTime? lastUpdated;

  @HiveField(9)
  String? notes;

  @HiveField(10)
  bool? isActive;

  @HiveField(11)
  String? applicationStatus; // Not Started, In Progress, Submitted

  EntranceExam({
    this.id,
    this.examName,
    this.applicationDeadline,
    this.examDate,
    this.requiredDocuments,
    this.uploadedDocumentIds,
    this.examLink,
    this.officialPortal,
    this.lastUpdated,
    this.notes,
    this.isActive = true,
    this.applicationStatus = 'Not Started',
  });

  /// Get days remaining until deadline
  int? getDaysUntilDeadline() {
    if (applicationDeadline == null) return null;
    return applicationDeadline!.difference(DateTime.now()).inDays;
  }

  /// Check if deadline is approaching (within 3 days)
  bool isDeadlineApproaching() {
    final daysRemaining = getDaysUntilDeadline();
    return daysRemaining != null && daysRemaining > 0 && daysRemaining <= 3;
  }

  /// Check if deadline has passed
  bool isDeadlinePassed() {
    final daysRemaining = getDaysUntilDeadline();
    return daysRemaining != null && daysRemaining < 0;
  }

  /// Get number of missing documents
  int getMissingDocumentCount() {
    if (requiredDocuments == null || uploadedDocumentIds == null) return 0;
    int missing = 0;
    for (var doc in requiredDocuments!) {
      if (!uploadedDocumentIds!.contains(doc)) {
        missing++;
      }
    }
    return missing;
  }

  /// Get progress percentage
  int getProgressPercentage() {
    if (requiredDocuments == null || requiredDocuments!.isEmpty) return 0;
    if (uploadedDocumentIds == null) return 0;

    int uploaded = 0;
    for (var doc in requiredDocuments!) {
      if (uploadedDocumentIds!.contains(doc)) {
        uploaded++;
      }
    }

    return ((uploaded / requiredDocuments!.length) * 100).toInt();
  }

  /// Format deadline for display
  String getFormattedDeadline() {
    if (applicationDeadline == null) return 'Not set';
    return '${applicationDeadline!.day}/${applicationDeadline!.month}/${applicationDeadline!.year}';
  }

  /// Copy with new values
  EntranceExam copyWith({
    String? id,
    String? examName,
    DateTime? applicationDeadline,
    DateTime? examDate,
    List<String>? requiredDocuments,
    List<String>? uploadedDocumentIds,
    String? examLink,
    String? officialPortal,
    DateTime? lastUpdated,
    String? notes,
    bool? isActive,
    String? applicationStatus,
  }) {
    return EntranceExam(
      id: id ?? this.id,
      examName: examName ?? this.examName,
      applicationDeadline: applicationDeadline ?? this.applicationDeadline,
      examDate: examDate ?? this.examDate,
      requiredDocuments: requiredDocuments ?? this.requiredDocuments,
      uploadedDocumentIds: uploadedDocumentIds ?? this.uploadedDocumentIds,
      examLink: examLink ?? this.examLink,
      officialPortal: officialPortal ?? this.officialPortal,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      applicationStatus: applicationStatus ?? this.applicationStatus,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'examName': examName,
      'applicationDeadline': applicationDeadline?.toIso8601String(),
      'examDate': examDate?.toIso8601String(),
      'requiredDocuments': requiredDocuments,
      'uploadedDocumentIds': uploadedDocumentIds,
      'examLink': examLink,
      'officialPortal': officialPortal,
      'lastUpdated': lastUpdated?.toIso8601String(),
      'notes': notes,
      'isActive': isActive,
      'applicationStatus': applicationStatus,
    };
  }

  /// Create from JSON
  factory EntranceExam.fromJson(Map<String, dynamic> json) {
    return EntranceExam(
      id: json['id'],
      examName: json['examName'],
      applicationDeadline: json['applicationDeadline'] != null
          ? DateTime.parse(json['applicationDeadline'])
          : null,
      examDate: json['examDate'] != null
          ? DateTime.parse(json['examDate'])
          : null,
      requiredDocuments: List<String>.from(json['requiredDocuments'] ?? []),
      uploadedDocumentIds: List<String>.from(json['uploadedDocumentIds'] ?? []),
      examLink: json['examLink'],
      officialPortal: json['officialPortal'],
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : null,
      notes: json['notes'],
      isActive: json['isActive'] ?? true,
      applicationStatus: json['applicationStatus'] ?? 'Not Started',
    );
  }
}
