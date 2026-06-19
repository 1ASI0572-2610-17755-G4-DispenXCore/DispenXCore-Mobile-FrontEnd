import 'package:dispenxcore_frontend/core/api/api_client.dart';
import '../../domain/entities/dispenser_event.dart';

class HistoryRemoteDataSource {
  final ApiClient apiClient;
  HistoryRemoteDataSource({required this.apiClient});

  Future<List<DispenserEvent>> getEvents(int dispensatorId) async {
    final data = await apiClient.get(
      '/api/v1/dispenser-events',
      queryParams: {'dispensatorId': dispensatorId},
    );
    return (data as List<dynamic>)
        .map((e) => DispenserEvent.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
