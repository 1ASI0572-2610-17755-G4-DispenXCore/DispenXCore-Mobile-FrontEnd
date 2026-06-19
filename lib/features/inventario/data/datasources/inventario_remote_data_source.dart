import 'package:dispenxcore_frontend/core/api/api_client.dart';
import '../../domain/entities/grain_inventory.dart';

class InventarioRemoteDataSource {
  final ApiClient apiClient;
  InventarioRemoteDataSource({required this.apiClient});

  Future<List<GrainInventory>> getEstado() async {
    final data = await apiClient.get('/api/v1/inventario/estado');
    return (data as List<dynamic>)
        .map((e) => GrainInventory.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // POST usa query params, NO body JSON
  Future<void> registrarMedicion({
    required String contenedorId,
    required double peso,
    required double nivel,
    required double flujo,
  }) async {
    await apiClient.post(
      '/api/v1/inventario/medicion?contenedorId=$contenedorId'
      '&peso=$peso&nivel=$nivel&flujo=$flujo',
      requiresAuth: true,
    );
  }
}
