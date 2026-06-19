import '../../domain/entities/alert_grain.dart';
import '../../domain/repositories/alerts_repository.dart';
import '../datasources/alerts_remote_data_source.dart';

class AlertsRepositoryImpl implements AlertsRepository {
  final AlertsRemoteDataSource remoteDataSource;

  AlertsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<AppNotification>> getNotifications() async {
    try {
      final rawList = await remoteDataSource.fetchNotifications();
      return rawList
          .whereType<Map<String, dynamic>>()
          .map(AppNotification.fromJson)
          .toList();
    } catch (e) {
      throw Exception('Error al obtener notificaciones: $e');
    }
  }

  @override
  Future<void> markAsRead(String id) => remoteDataSource.markAsRead(id);

  @override
  Future<void> markAllAsRead(String userId) =>
      remoteDataSource.markAllAsRead(userId);
}