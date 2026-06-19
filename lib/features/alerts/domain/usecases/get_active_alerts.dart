import '../entities/alert_grain.dart';
import '../repositories/alerts_repository.dart';

class GetNotifications {
  final AlertsRepository repository;
  GetNotifications(this.repository);
  Future<List<AppNotification>> call() => repository.getNotifications();
}

class MarkNotificationAsRead {
  final AlertsRepository repository;
  MarkNotificationAsRead(this.repository);
  Future<void> call(String id) => repository.markAsRead(id);
}

class MarkAllNotificationsAsRead {
  final AlertsRepository repository;
  MarkAllNotificationsAsRead(this.repository);
  Future<void> call(String userId) => repository.markAllAsRead(userId);
}