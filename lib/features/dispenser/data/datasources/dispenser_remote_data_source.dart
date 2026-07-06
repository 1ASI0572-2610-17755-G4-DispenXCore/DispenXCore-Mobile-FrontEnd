import 'package:dispenxcore_frontend/core/api/api_client.dart';

class DispenserRemoteDataSource {
  final ApiClient apiClient;
  DispenserRemoteDataSource({required this.apiClient});

  Future<Map<String, dynamic>> activarDispensador({
    required String deviceId,
    String? supplyType,
  }) async {
    return await apiClient.post(
      '/api/v1/dispenser/activate',
      body: {
        'device_id': deviceId,
        'supply_type': supplyType ?? 'General',
      },
      requiresAuth: false,
    );
  }
}
