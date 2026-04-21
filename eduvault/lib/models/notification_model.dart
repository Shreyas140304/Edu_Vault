import 'package:hive/hive.dart';

part 'notification_model.g.dart';

@HiveType(typeId: 3)
class NotificationItem extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? title;

  @HiveField(2)
  String? message;

  @HiveField(3)
  String? type; // deadline, missing_doc, requirement_update, other

  @HiveField(4)
  String? category; // Class10, Class12, GATE, CAT, etc.

  @HiveField(5)
  DateTime? createdAt;

  @HiveField(6)
  DateTime? scheduledAt;

  @HiveField(7)
  bool? isRead;

  @HiveField(8)
  bool? isActionRequired;

  @HiveField(9)
  String? actionPath; // Route to navigate on tap

  @HiveField(10)
  Map<String, dynamic>? actionData;

  NotificationItem({
    this.id,
    this.title,
    this.message,
    this.type,
    this.category,
    this.createdAt,
    this.scheduledAt,
    this.isRead = false,
    this.isActionRequired = false,
    this.actionPath,
    this.actionData,
  });

  /// Get icon based on notification type
  String getIcon() {
    switch (type) {
      case 'deadline':
        return '⏰';
      case 'missing_doc':
        return '📄';
      case 'requirement_update':
        return '📢';
      default:
        return '📧';
    }
  }

  /// Get color based on notification type
  String getColor() {
    switch (type) {
      case 'deadline':
        return '#F39C12'; // Warning
      case 'missing_doc':
        return '#E74C3C'; // Error
      case 'requirement_update':
        return '#3498DB'; // Info
      default:
        return '#95A5A6'; // Secondary
    }
  }

  /// Format creation date for display
  String getFormattedDate() {
    if (createdAt == null) return 'Just now';

    final now = DateTime.now();
    final difference = now.difference(createdAt!);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${createdAt!.day}/${createdAt!.month}/${createdAt!.year}';
    }
  }

  /// Copy with new values
  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    String? category,
    DateTime? createdAt,
    DateTime? scheduledAt,
    bool? isRead,
    bool? isActionRequired,
    String? actionPath,
    Map<String, dynamic>? actionData,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      isRead: isRead ?? this.isRead,
      isActionRequired: isActionRequired ?? this.isActionRequired,
      actionPath: actionPath ?? this.actionPath,
      actionData: actionData ?? this.actionData,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'category': category,
      'createdAt': createdAt?.toIso8601String(),
      'scheduledAt': scheduledAt?.toIso8601String(),
      'isRead': isRead,
      'isActionRequired': isActionRequired,
      'actionPath': actionPath,
      'actionData': actionData,
    };
  }

  /// Create from JSON
  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      type: json['type'],
      category: json['category'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      scheduledAt: json['scheduledAt'] != null
          ? DateTime.parse(json['scheduledAt'])
          : null,
      isRead: json['isRead'] ?? false,
      isActionRequired: json['isActionRequired'] ?? false,
      actionPath: json['actionPath'],
      actionData: json['actionData'],
    );
  }
}
