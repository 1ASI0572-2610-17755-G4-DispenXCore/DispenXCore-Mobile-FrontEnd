import 'package:dispenxcore_frontend/core/api/api_client.dart';
import '../../domain/entities/schedule.dart';

class ScheduleRemoteDataSource {
  final ApiClient apiClient;
  ScheduleRemoteDataSource({required this.apiClient});

  Future<List<Schedule>> getSchedules(int dispensatorId) async {
    final data = await apiClient.get(
      '/api/v1/schedules',
      queryParams: {'dispensatorId': dispensatorId},
    );
    return (data as List<dynamic>)
        .map((e) => Schedule.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> createSchedule(Schedule schedule) async {
    await apiClient.post(
      '/api/v1/schedules',
      body: schedule.toJson(),
      requiresAuth: true,
    );
  }

  Future<void> updateSchedule(int id, Schedule schedule) async {
    await apiClient.put('/api/v1/schedules/$id', body: schedule.toJson());
  }

  Future<void> deleteSchedule(int id) async {
    await apiClient.delete('/api/v1/schedules/$id');
  }

  Future<void> toggleSchedule(int id) async {
    await apiClient.patch('/api/v1/schedules/$id/toggle');
  }
}
