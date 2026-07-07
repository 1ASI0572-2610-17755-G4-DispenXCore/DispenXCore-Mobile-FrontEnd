import 'package:dispenxcore_frontend/core/utils/date_formatter.dart';

class AppNotification {
  final String id;
  final String userId;
  final int type;
  final String title;
  final String time;
  final String message;
  final String? action;
  final bool unread;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.time,
    required this.message,
    required this.unread,
    required this.createdAt,
    this.action,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: json['type'] as int,
      title: json['title'] as String,
      time: json['time'] as String,
      message: json['message'] as String,
      action: json['action'] as String?,
      unread: json['unread'] as bool,
      createdAt: parseUtcToLocal(json['createdAt'] as String),
    );
  }
}