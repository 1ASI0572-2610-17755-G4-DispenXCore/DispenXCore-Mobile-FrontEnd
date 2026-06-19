import 'package:dispenxcore_frontend/core/api/api_client.dart';
import '../../domain/entities/alerta_stock.dart';

class AlertasStockRemoteDataSource {
  final ApiClient apiClient;
  AlertasStockRemoteDataSource({required this.apiClient});

  Future<List<AlertaStock>> getAlertasPorContenedor(String contenedorId) async {
    final data = await apiClient.get('/api/v1/alertas-stock/$contenedorId');
    return (data as List<dynamic>)
        .map((e) => AlertaStock.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // POST usa query params, NO body JSON
  Future<void> evaluarAlerta({
    required String contenedorId,
    required double umbral,
    required String deviceToken,
  }) async {
    await apiClient.post(
      '/api/v1/alertas-stock/evaluar?contenedorId=$contenedorId'
      '&umbral=$umbral&deviceToken=$deviceToken',
      requiresAuth: true,
    );
  }
}
