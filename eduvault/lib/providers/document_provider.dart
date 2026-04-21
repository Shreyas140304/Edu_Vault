import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:eduvault/models/index.dart';
import 'package:eduvault/services/index.dart';
import 'package:eduvault/constants/app_constants.dart';

class DocumentProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  final FileStorageService _fileService = FileStorageService();
  final OcrService _ocrService = OcrService();

  List<Document> _documents = [];
  List<Document> _filteredDocuments = [];
  Map<String, List<Document>> _documentsByStage = {};
  bool _isLoading = false;
  String? _error;

  /// Getters
  List<Document> get documents => _documents;
  List<Document> get filteredDocuments => _filteredDocuments;
  Map<String, List<Document>> get documentsByStage => _documentsByStage;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load all documents
  Future<void> loadDocuments() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _documents = _dbService.getAllDocuments();
      _organizeDocumentsByStage();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Organize documents by stage
  void _organizeDocumentsByStage() {
    _documentsByStage.clear();
    for (var stage in AppConstants.educationStages) {
      _documentsByStage[stage] = _dbService.getDocumentsByStage(stage);
    }
  }

  /// Upload document from file with OCR
  Future<bool> uploadDocument(
    File sourceFile,
    String stage, {
    String? recognizedCategory,
    String? recognizedStage,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Save file to storage
      final savedPath = await _fileService.saveDocument(
        sourceFile,
        stage,
        recognizedCategory ?? 'Other',
      );

      // Extract text using OCR if it's an image
      String extractedText = '';
      String detectedCategory = recognizedCategory ?? 'Unknown';
      String detectionConfidence = 'Low';

      if (sourceFile.path.toLowerCase().endsWith('.pdf') ||
          sourceFile.path.toLowerCase().endsWith('.jpg') ||
          sourceFile.path.toLowerCase().endsWith('.jpeg') ||
          sourceFile.path.toLowerCase().endsWith('.png')) {
        extractedText = await _ocrService.extractTextFromImage(sourceFile.path);

        if (extractedText.isNotEmpty) {
          final detection = _ocrService.detectDocumentType(extractedText);
          detectedCategory = detection['category'] ?? 'Unknown';
          detectionConfidence = detection['confidence'] ?? 'Low';

          if (recognizedStage == null) {
            stage = _ocrService.determineEducationStage(
              extractedText,
              detectedCategory,
            );
          }
        }
      }

      // Create document record
      final document = Document(
        id: const Uuid().v4(),
        fileName: sourceFile.path.split('/').last,
        filePath: savedPath,
        fileType: sourceFile.path.split('.').last,
        fileSize: await File(sourceFile.path).length(),
        stage: stage,
        category: detectedCategory,
        extractedText: extractedText,
        detectionConfidence: detectionConfidence,
        uploadedAt: DateTime.now(),
        scannedAt: DateTime.now(),
        isRequired: _isRequiredDocument(stage, detectedCategory),
      );

      // Save to database
      await _dbService.addDocument(document);
      _documents.add(document);
      _organizeDocumentsByStage();

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

  /// Upload document from a file path (useful for UI layers that avoid dart:io imports).
  Future<bool> uploadDocumentFromPath(
    String sourcePath,
    String stage, {
    String? recognizedCategory,
    String? recognizedStage,
  }) async {
    return uploadDocument(
      File(sourcePath),
      stage,
      recognizedCategory: recognizedCategory,
      recognizedStage: recognizedStage,
    );
  }

  /// Check if document is required
  bool _isRequiredDocument(String stage, String category) {
    final required = AppConstants.requiredDocuments[stage] ?? [];
    return required.contains(category);
  }

  /// Search documents
  void searchDocuments(String query) {
    if (query.isEmpty) {
      _filteredDocuments = _documents;
    } else {
      _filteredDocuments = _dbService.searchDocuments(query);
    }
    notifyListeners();
  }

  /// Get documents by stage
  List<Document> getDocumentsByStage(String stage) {
    return _dbService.getDocumentsByStage(stage);
  }

  /// Get missing documents for stage
  List<String> getMissingDocumentsForStage(String stage) {
    final required = AppConstants.requiredDocuments[stage] ?? [];
    final uploaded = _dbService.getDocumentsByStage(stage);
    final uploadedCategories = uploaded.map((doc) => doc.category).toSet();

    return required.where((doc) => !uploadedCategories.contains(doc)).toList();
  }

  /// Delete document
  Future<bool> deleteDocument(String documentId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final document = _documents.firstWhere((doc) => doc.id == documentId);
      await _fileService.deleteDocument(document.filePath ?? '');
      await _dbService.deleteDocument(documentId);

      _documents.removeWhere((doc) => doc.id == documentId);
      _organizeDocumentsByStage();

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

  /// Update document
  Future<bool> updateDocument(Document document) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _dbService.addDocument(document);
      final index = _documents.indexWhere((doc) => doc.id == document.id);
      if (index != -1) {
        _documents[index] = document;
      }

      _organizeDocumentsByStage();

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

  /// Get document count by stage
  Map<String, int> getDocumentCountByStage() {
    Map<String, int> counts = {};
    for (var stage in AppConstants.educationStages) {
      counts[stage] = _dbService.getDocumentsByStage(stage).length;
    }
    return counts;
  }

  /// Get completion percentage for stage
  int getStageCompletionPercentage(String stage) {
    final required = AppConstants.requiredDocuments[stage] ?? [];
    if (required.isEmpty) return 100;

    final uploaded = _dbService.getDocumentsByStage(stage);
    final uploadedCategories = uploaded.map((doc) => doc.category).toSet();

    final completed = required
        .where((doc) => uploadedCategories.contains(doc))
        .length;
    return ((completed / required.length) * 100).toInt();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
