import '../entities/alert_grain.dart';

abstract class AlertsRepository {
  Future<List<AppNotification>> getNotifications();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead(String userId);
}