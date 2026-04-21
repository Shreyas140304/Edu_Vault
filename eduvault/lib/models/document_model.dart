import 'package:hive/hive.dart';

part 'document_model.g.dart';

@HiveType(typeId: 1)
class Document extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? fileName;

  @HiveField(2)
  String? filePath;

  @HiveField(3)
  String? fileType; // pdf, image, etc.

  @HiveField(4)
  int? fileSize;

  @HiveField(5)
  String? stage; // Class 10, Class 12, Graduation, etc.

  @HiveField(6)
  String? category; // Marksheet, Certificate, etc.

  @HiveField(7)
  String? extractedText; // OCR extracted text

  @HiveField(8)
  String? detectionConfidence; // High, Medium, Low

  @HiveField(9)
  List<String>? tags;

  @HiveField(10)
  DateTime? uploadedAt;

  @HiveField(11)
  DateTime? scannedAt;

  @HiveField(12)
  bool? isRequired;

  @HiveField(13)
  String? relatedExam; // For exam documents

  @HiveField(14)
  bool? isFavorite;

  @HiveField(15)
  String? notes;

  Document({
    this.id,
    this.fileName,
    this.filePath,
    this.fileType,
    this.fileSize,
    this.stage,
    this.category,
    this.extractedText,
    this.detectionConfidence,
    this.tags,
    this.uploadedAt,
    this.scannedAt,
    this.isRequired,
    this.relatedExam,
    this.isFavorite = false,
    this.notes,
  });

  /// Get display name
  String getDisplayName() {
    return fileName ?? 'Unknown Document';
  }

  /// Get formatted upload date
  String getFormattedDate() {
    if (uploadedAt == null) return 'Unknown';
    return '${uploadedAt!.day}/${uploadedAt!.month}/${uploadedAt!.year}';
  }

  /// Copy with new values
  Document copyWith({
    String? id,
    String? fileName,
    String? filePath,
    String? fileType,
    int? fileSize,
    String? stage,
    String? category,
    String? extractedText,
    String? detectionConfidence,
    List<String>? tags,
    DateTime? uploadedAt,
    DateTime? scannedAt,
    bool? isRequired,
    String? relatedExam,
    bool? isFavorite,
    String? notes,
  }) {
    return Document(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      stage: stage ?? this.stage,
      category: category ?? this.category,
      extractedText: extractedText ?? this.extractedText,
      detectionConfidence: detectionConfidence ?? this.detectionConfidence,
      tags: tags ?? this.tags,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      scannedAt: scannedAt ?? this.scannedAt,
      isRequired: isRequired ?? this.isRequired,
      relatedExam: relatedExam ?? this.relatedExam,
      isFavorite: isFavorite ?? this.isFavorite,
      notes: notes ?? this.notes,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'filePath': filePath,
      'fileType': fileType,
      'fileSize': fileSize,
      'stage': stage,
      'category': category,
      'extractedText': extractedText,
      'detectionConfidence': detectionConfidence,
      'tags': tags,
      'uploadedAt': uploadedAt?.toIso8601String(),
      'scannedAt': scannedAt?.toIso8601String(),
      'isRequired': isRequired,
      'relatedExam': relatedExam,
      'isFavorite': isFavorite,
      'notes': notes,
    };
  }

  /// Create from JSON
  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'],
      fileName: json['fileName'],
      filePath: json['filePath'],
      fileType: json['fileType'],
      fileSize: json['fileSize'],
      stage: json['stage'],
      category: json['category'],
      extractedText: json['extractedText'],
      detectionConfidence: json['detectionConfidence'],
      tags: List<String>.from(json['tags'] ?? []),
      uploadedAt: json['uploadedAt'] != null
          ? DateTime.parse(json['uploadedAt'])
          : null,
      scannedAt: json['scannedAt'] != null
          ? DateTime.parse(json['scannedAt'])
          : null,
      isRequired: json['isRequired'],
      relatedExam: json['relatedExam'],
      isFavorite: json['isFavorite'] ?? false,
      notes: json['notes'],
    );
  }
}
