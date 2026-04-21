import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:eduvault/constants/app_constants.dart';
import 'package:eduvault/models/index.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static final Logger _logger = Logger();

  late Box<UserProfile> userBox;
  late Box<Document> documentBox;
  late Box<EntranceExam> examBox;
  late Box<NotificationItem> notificationBox;

  DatabaseService._internal();

  factory DatabaseService() {
    return _instance;
  }

  /// Initialize the database
  Future<void> init() async {
    try {
      await Hive.initFlutter();

      // Register adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(UserProfileAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(DocumentAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(EntranceExamAdapter());
      }
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(NotificationItemAdapter());
      }

      // Open boxes
      userBox = await Hive.openBox<UserProfile>(AppConstants.hiveBoxUser);
      documentBox = await Hive.openBox<Document>(AppConstants.hiveBoxDocuments);
      examBox = await Hive.openBox<EntranceExam>(AppConstants.hiveBoxExams);
      notificationBox = await Hive.openBox<NotificationItem>(
        AppConstants.hiveBoxNotifications,
      );

      _logger.i('Database initialized successfully');
    } catch (e) {
      _logger.e('Error initializing database: $e');
      rethrow;
    }
  }

  /// Save or update user profile
  Future<void> saveUserProfile(UserProfile profile) async {
    try {
      await userBox.put('profile', profile);
      _logger.i('User profile saved');
    } catch (e) {
      _logger.e('Error saving user profile: $e');
      rethrow;
    }
  }

  /// Get user profile
  UserProfile? getUserProfile() {
    try {
      return userBox.get('profile');
    } catch (e) {
      _logger.e('Error getting user profile: $e');
      return null;
    }
  }

  /// Delete user profile
  Future<void> deleteUserProfile() async {
    try {
      await userBox.delete('profile');
      _logger.i('User profile deleted');
    } catch (e) {
      _logger.e('Error deleting user profile: $e');
      rethrow;
    }
  }

  /// Add or update document
  Future<void> addDocument(Document document) async {
    try {
      await documentBox.put(document.id, document);
      _logger.i('Document added: ${document.id}');
    } catch (e) {
      _logger.e('Error adding document: $e');
      rethrow;
    }
  }

  /// Get all documents
  List<Document> getAllDocuments() {
    try {
      return documentBox.values.toList();
    } catch (e) {
      _logger.e('Error getting all documents: $e');
      return [];
    }
  }

  /// Get documents by stage
  List<Document> getDocumentsByStage(String stage) {
    try {
      return documentBox.values.where((doc) => doc.stage == stage).toList();
    } catch (e) {
      _logger.e('Error getting documents by stage: $e');
      return [];
    }
  }

  /// Get documents by category
  List<Document> getDocumentsByCategory(String category) {
    try {
      return documentBox.values
          .where((doc) => doc.category == category)
          .toList();
    } catch (e) {
      _logger.e('Error getting documents by category: $e');
      return [];
    }
  }

  /// Search documents
  List<Document> searchDocuments(String query) {
    try {
      final lowerQuery = query.toLowerCase();
      return documentBox.values
          .where(
            (doc) =>
                (doc.fileName?.toLowerCase().contains(lowerQuery) ?? false) ||
                (doc.category?.toLowerCase().contains(lowerQuery) ?? false) ||
                (doc.extractedText?.toLowerCase().contains(lowerQuery) ??
                    false),
          )
          .toList();
    } catch (e) {
      _logger.e('Error searching documents: $e');
      return [];
    }
  }

  /// Delete document
  Future<void> deleteDocument(String documentId) async {
    try {
      await documentBox.delete(documentId);
      _logger.i('Document deleted: $documentId');
    } catch (e) {
      _logger.e('Error deleting document: $e');
      rethrow;
    }
  }

  /// Add or update entrance exam
  Future<void> addEntranceExam(EntranceExam exam) async {
    try {
      await examBox.put(exam.id, exam);
      _logger.i('Entrance exam added: ${exam.id}');
    } catch (e) {
      _logger.e('Error adding entrance exam: $e');
      rethrow;
    }
  }

  /// Get all entrance exams
  List<EntranceExam> getAllEntranceExams() {
    try {
      return examBox.values.toList();
    } catch (e) {
      _logger.e('Error getting all entrance exams: $e');
      return [];
    }
  }

  /// Get active entrance exams
  List<EntranceExam> getActiveEntranceExams() {
    try {
      return examBox.values.where((exam) => exam.isActive == true).toList();
    } catch (e) {
      _logger.e('Error getting active entrance exams: $e');
      return [];
    }
  }

  /// Delete entrance exam
  Future<void> deleteEntranceExam(String examId) async {
    try {
      await examBox.delete(examId);
      _logger.i('Entrance exam deleted: $examId');
    } catch (e) {
      _logger.e('Error deleting entrance exam: $e');
      rethrow;
    }
  }

  /// Add notification
  Future<void> addNotification(NotificationItem notification) async {
    try {
      await notificationBox.put(notification.id, notification);
      _logger.i('Notification added: ${notification.id}');
    } catch (e) {
      _logger.e('Error adding notification: $e');
      rethrow;
    }
  }

  /// Get all notifications
  List<NotificationItem> getAllNotifications() {
    try {
      return notificationBox.values.toList();
    } catch (e) {
      _logger.e('Error getting all notifications: $e');
      return [];
    }
  }

  /// Get unread notifications
  List<NotificationItem> getUnreadNotifications() {
    try {
      return notificationBox.values
          .where((notif) => notif.isRead == false)
          .toList();
    } catch (e) {
      _logger.e('Error getting unread notifications: $e');
      return [];
    }
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      final notification = notificationBox.get(notificationId);
      if (notification != null) {
        notification.isRead = true;
        await notification.save();
        _logger.i('Notification marked as read: $notificationId');
      }
    } catch (e) {
      _logger.e('Error marking notification as read: $e');
      rethrow;
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await notificationBox.delete(notificationId);
      _logger.i('Notification deleted: $notificationId');
    } catch (e) {
      _logger.e('Error deleting notification: $e');
      rethrow;
    }
  }

  /// Clear all data (for development/testing)
  Future<void> clearAllData() async {
    try {
      await userBox.clear();
      await documentBox.clear();
      await examBox.clear();
      await notificationBox.clear();
      _logger.i('All data cleared');
    } catch (e) {
      _logger.e('Error clearing all data: $e');
      rethrow;
    }
  }

  /// Close database
  Future<void> close() async {
    try {
      await Hive.close();
      _logger.i('Database closed');
    } catch (e) {
      _logger.e('Error closing database: $e');
      rethrow;
    }
  }
}
