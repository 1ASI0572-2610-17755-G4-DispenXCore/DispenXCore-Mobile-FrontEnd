import '../../../../core/api/api_client.dart';
import '../../../../core/storage/token_storage.dart';

abstract class AlertsRemoteDataSource {
  Future<List<dynamic>> fetchNotifications();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead(String userId);
}

class AlertsRemoteDataSourceImpl implements AlertsRemoteDataSource {
  final ApiClient apiClient;
  final TokenStorage tokenStorage;

  AlertsRemoteDataSourceImpl({required this.apiClient, required this.tokenStorage});

  @override
  Future<List<dynamic>> fetchNotifications() async {
    final userId = await tokenStorage.getUserId();
    final data = await apiClient.get(
      '/api/v1/notifications',
      queryParams: userId != null ? {'userId': userId} : null,
    );
    if (data is List) return data;
    return [];
  }

  @override
  Future<void> markAsRead(String id) async {
    await apiClient.patch('/api/v1/notifications/$id/read');
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    await apiClient.patch('/api/v1/notifications/read-all?userId=$userId');
  }
}