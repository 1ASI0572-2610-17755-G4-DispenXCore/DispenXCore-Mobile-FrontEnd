import 'package:dispenxcore_frontend/core/api/api_client.dart';
import 'package:dispenxcore_frontend/features/device/domain/entities/device_info.dart';

class DeviceRemoteDataSource {
  final ApiClient apiClient;
  DeviceRemoteDataSource({required this.apiClient});

  Future<DeviceInfo> getDevice() async {
    final data = await apiClient.get('/api/v1/device');
    return DeviceInfo.fromJson(data as Map<String, dynamic>);
  }

  Future<DeviceInfo> updateDevice({
    required String name,
    required String location,
  }) async {
    final data = await apiClient.patch(
      '/api/v1/device',
      body: {'name': name, 'location': location},
    );
    if (data is Map<String, dynamic>) return DeviceInfo.fromJson(data);
    return getDevice();
  }

  Future<void> pingDevice() async {
    await apiClient.post('/api/v1/device/ping', body: {}, requiresAuth: true);
  }
}
