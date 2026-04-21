import 'package:flutter/material.dart';
import 'package:eduvault/models/notification_model.dart';
import 'package:eduvault/services/index.dart';

class NotificationProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  final NotificationService _notificationService = NotificationService();

  List<NotificationItem> _items = [];
  bool _isLoading = false;
  String? _error;

  List<NotificationItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _items.where((item) => item.isRead != true).length;

  Future<void> loadNotifications() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _items = _dbService.getAllNotifications()
        ..sort(
          (a, b) => (b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))
              .compareTo(a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)),
        );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String id) async {
    await _dbService.markNotificationAsRead(id);
    await loadNotifications();
  }

  Future<void> deleteNotification(String id) async {
    await _dbService.deleteNotification(id);
    await loadNotifications();
  }

  Future<void> clearAll() async {
    for (final item in _items) {
      if (item.id == null) continue;
      await _dbService.deleteNotification(item.id!);
    }
    await _notificationService.cancelAllNotifications();
    await loadNotifications();
  }

  Future<void> sendTestNotification() async {
    await _notificationService.sendCustomNotification(
      title: 'EduVault Test Notification',
      message: 'Notifications are working correctly.',
      type: 'other',
      category: 'system',
    );
    await loadNotifications();
  }
}
