import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';
import 'package:eduvault/constants/app_constants.dart';

class FileStorageService {
  static final FileStorageService _instance = FileStorageService._internal();
  static final Logger _logger = Logger();

  late Directory _documentsDirectory;
  bool _isInitialized = false;
  bool _isSupported = true;

  FileStorageService._internal();

  factory FileStorageService() {
    return _instance;
  }

  /// Initialize file storage
  Future<void> init() async {
    if (kIsWeb) {
      _isSupported = false;
      _logger.w('File storage is not supported on web in this build.');
      return;
    }

    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      _documentsDirectory = Directory(
        '${appDocDir.path}/${AppConstants.documentsFolder}',
      );

      // Create directory if it doesn't exist
      if (!await _documentsDirectory.exists()) {
        await _documentsDirectory.create(recursive: true);
      }

      _isInitialized = true;
      _logger.i('File storage initialized: ${_documentsDirectory.path}');
    } catch (e) {
      _logger.e('Error initializing file storage: $e');
      rethrow;
    }
  }

  void _assertReady() {
    if (!_isSupported) {
      throw UnsupportedError(
        'File storage is unavailable on web. Use a web upload flow.',
      );
    }
    if (!_isInitialized) {
      throw StateError('File storage service is not initialized.');
    }
  }

  /// Get base documents directory
  Directory getBaseDirectory() {
    _assertReady();
    return _documentsDirectory;
  }

  /// Save document to storage
  Future<String> saveDocument(
    File sourceFile,
    String stage,
    String category,
  ) async {
    _assertReady();
    try {
      // Create stage directory
      final stageDir = Directory(
        '${_documentsDirectory.path}/${stage.replaceAll(' ', '_')}',
      );
      if (!await stageDir.exists()) {
        await stageDir.create(recursive: true);
      }

      // Create category subdirectory
      final categoryDir = Directory(
        '${stageDir.path}/${category.replaceAll(' ', '_')}',
      );
      if (!await categoryDir.exists()) {
        await categoryDir.create(recursive: true);
      }

      // Copy file
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_'
          '${sourceFile.path.split('/').last}';
      final savedFile = await sourceFile.copy('${categoryDir.path}/$fileName');

      _logger.i('Document saved: ${savedFile.path}');
      return savedFile.path;
    } catch (e) {
      _logger.e('Error saving document: $e');
      rethrow;
    }
  }

  /// Get all documents from stage
  Future<List<File>> getDocumentsFromStage(String stage) async {
    _assertReady();
    try {
      final stageDir = Directory(
        '${_documentsDirectory.path}/${stage.replaceAll(' ', '_')}',
      );

      if (!await stageDir.exists()) {
        return [];
      }

      final List<File> files = [];
      final entities = stageDir.listSync(recursive: true);

      for (var entity in entities) {
        if (entity is File) {
          files.add(entity);
        }
      }

      return files;
    } catch (e) {
      _logger.e('Error getting documents from stage: $e');
      return [];
    }
  }

  /// Get documents from specific category
  Future<List<File>> getDocumentsFromCategory(
    String stage,
    String category,
  ) async {
    _assertReady();
    try {
      final categoryDir = Directory(
        '${_documentsDirectory.path}/${stage.replaceAll(' ', '_')}/'
        '${category.replaceAll(' ', '_')}',
      );

      if (!await categoryDir.exists()) {
        return [];
      }

      return categoryDir.listSync().whereType<File>().toList();
    } catch (e) {
      _logger.e('Error getting documents from category: $e');
      return [];
    }
  }

  /// Get file size in MB
  double getFileSizeInMB(File file) {
    try {
      return file.lengthSync() / (1024 * 1024);
    } catch (e) {
      _logger.e('Error getting file size: $e');
      return 0.0;
    }
  }

  /// Get total storage used
  Future<double> getTotalStorageUsedInMB() async {
    _assertReady();
    try {
      final entities = _documentsDirectory.listSync(recursive: true);
      int totalSize = 0;

      for (var entity in entities) {
        if (entity is File) {
          totalSize += entity.lengthSync();
        }
      }

      return totalSize / (1024 * 1024);
    } catch (e) {
      _logger.e('Error getting total storage used: $e');
      return 0.0;
    }
  }

  /// Delete document file
  Future<void> deleteDocument(String filePath) async {
    _assertReady();
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        _logger.i('Document deleted: $filePath');
      }
    } catch (e) {
      _logger.e('Error deleting document: $e');
      rethrow;
    }
  }

  /// Check if file exists
  Future<bool> fileExists(String filePath) async {
    _assertReady();
    try {
      return await File(filePath).exists();
    } catch (e) {
      _logger.e('Error checking if file exists: $e');
      return false;
    }
  }

  /// Get file info
  Future<Map<String, dynamic>> getFileInfo(String filePath) async {
    _assertReady();
    try {
      final file = File(filePath);

      if (!await file.exists()) {
        return {};
      }

      final stat = file.statSync();

      return {
        'name': file.path.split('/').last,
        'path': filePath,
        'size': stat.size,
        'sizeInMB': stat.size / (1024 * 1024),
        'modified': stat.modified,
        'accessed': stat.accessed,
      };
    } catch (e) {
      _logger.e('Error getting file info: $e');
      return {};
    }
  }

  /// Create backup of all documents
  Future<String> createBackup() async {
    _assertReady();
    try {
      final backupDir = Directory('${_documentsDirectory.path}/backups');
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      final backupFile = File(
        '${backupDir.path}/backup_${DateTime.now().millisecondsSinceEpoch}.zip',
      );
      _logger.i('Backup created at: ${backupFile.path}');

      return backupFile.path;
    } catch (e) {
      _logger.e('Error creating backup: $e');
      rethrow;
    }
  }

  /// Clear old documents (older than specified days)
  Future<int> clearOldDocuments(int days) async {
    _assertReady();
    try {
      int deletedCount = 0;
      final entities = _documentsDirectory.listSync(recursive: true);
      final cutoffDate = DateTime.now().subtract(Duration(days: days));

      for (var entity in entities) {
        if (entity is File) {
          final stat = entity.statSync();
          if (stat.modified.isBefore(cutoffDate)) {
            await entity.delete();
            deletedCount++;
          }
        }
      }

      _logger.i('Cleared $deletedCount old documents');
      return deletedCount;
    } catch (e) {
      _logger.e('Error clearing old documents: $e');
      return 0;
    }
  }
}
