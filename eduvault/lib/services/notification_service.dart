import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import 'package:eduvault/models/notification_model.dart';
import 'package:eduvault/services/database_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  static final Logger _logger = Logger();

  late FlutterLocalNotificationsPlugin _notificationsPlugin;
  final DatabaseService _dbService = DatabaseService();

  NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  /// Initialize notification service
  Future<void> init() async {
    try {
      _notificationsPlugin = FlutterLocalNotificationsPlugin();

      // Android initialization
      const AndroidInitializationSettings androidInit =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization
      const DarwinInitializationSettings iosInit = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      );

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      _logger.i('Notification service initialized');
    } catch (e) {
      _logger.e('Error initializing notification service: $e');
    }
  }

  /// Show notification
  Future<void> showNotification({
    required String title,
    required String message,
    required String type,
    required String category,
    String? actionPath,
    Map<String, dynamic>? actionData,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'eduvault_channel',
            'EduVault Notifications',
            channelDescription: 'Notifications for EduVault app',
            importance: Importance.max,
            priority: Priority.high,
          );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final String notificationId = const Uuid().v4();

      await _notificationsPlugin.show(
        notificationId.hashCode,
        title,
        message,
        notificationDetails,
        payload: notificationId,
      );

      // Save to database
      final notification = NotificationItem(
        id: notificationId,
        title: title,
        message: message,
        type: type,
        category: category,
        createdAt: DateTime.now(),
        isRead: false,
        actionPath: actionPath,
        actionData: actionData,
      );

      await _dbService.addNotification(notification);
      _logger.i('Notification shown: $notificationId');
    } catch (e) {
      _logger.e('Error showing notification: $e');
    }
  }

  /// Handle notification tapped
  void _onNotificationTapped(NotificationResponse response) {
    _logger.i('Notification tapped: ${response.payload}');
    // Navigate based on payload
  }

  /// Send missing document reminder
  Future<void> sendMissingDocumentReminder(
    String stage,
    List<String> missingDocuments,
  ) async {
    try {
      final missingList = missingDocuments.join(', ');
      await showNotification(
        title: 'Missing Documents',
        message: 'Upload $missingList for $stage',
        type: 'missing_doc',
        category: stage,
      );
    } catch (e) {
      _logger.e('Error sending missing document reminder: $e');
    }
  }

  /// Send deadline alert
  Future<void> sendDeadlineAlert(String examName, int daysRemaining) async {
    try {
      await showNotification(
        title: 'Deadline Approaching',
        message: '$examName application deadline in $daysRemaining days',
        type: 'deadline',
        category: examName,
      );
    } catch (e) {
      _logger.e('Error sending deadline alert: $e');
    }
  }

  /// Send requirement update notification
  Future<void> sendRequirementUpdate(String examName, String update) async {
    try {
      await showNotification(
        title: 'Requirement Update',
        message: 'New requirement added for $examName: $update',
        type: 'requirement_update',
        category: examName,
      );
    } catch (e) {
      _logger.e('Error sending requirement update: $e');
    }
  }

  /// Send custom notification
  Future<void> sendCustomNotification({
    required String title,
    required String message,
    String type = 'other',
    String category = 'other',
  }) async {
    try {
      await showNotification(
        title: title,
        message: message,
        type: type,
        category: category,
      );
    } catch (e) {
      _logger.e('Error sending custom notification: $e');
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
      _logger.i('All notifications cancelled');
    } catch (e) {
      _logger.e('Error cancelling notifications: $e');
    }
  }

  /// Request notification permissions (Android 13+, iOS)
  Future<bool> requestPermissions() async {
    try {
      final result = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);

      return result ?? false;
    } catch (e) {
      _logger.e('Error requesting notification permissions: $e');
      return false;
    }
  }

  /// Schedule a notification
  Future<void> scheduleNotification({
    required String title,
    required String message,
    required DateTime scheduledDate,
    required String type,
    required String category,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'eduvault_channel',
            'EduVault Notifications',
            channelDescription: 'Notifications for EduVault app',
          );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final String notificationId = const Uuid().v4();

      // Calculate delay from now
      final delay = scheduledDate.difference(DateTime.now());
      if (delay.isNegative) {
        // If scheduled time is in the past, show immediately
        await _notificationsPlugin.show(
          notificationId.hashCode,
          title,
          message,
          notificationDetails,
          payload: notificationId,
        );
      } else {
        // Schedule for future
        await Future.delayed(delay, () async {
          await _notificationsPlugin.show(
            notificationId.hashCode,
            title,
            message,
            notificationDetails,
            payload: notificationId,
          );
        });
      }

      // Save to database
      final notification = NotificationItem(
        id: notificationId,
        title: title,
        message: message,
        type: type,
        category: category,
        scheduledAt: scheduledDate,
        isRead: false,
      );

      await _dbService.addNotification(notification);
      _logger.i('Notification scheduled: $notificationId');
    } catch (e) {
      _logger.e('Error scheduling notification: $e');
    }
  }
}
