import '../../../../core/api/api_client.dart';

abstract class AlertsRemoteDataSource {
  Future<List<dynamic>> fetchActiveAlerts();
}

class AlertsRemoteDataSourceImpl implements AlertsRemoteDataSource {
  final ApiClient apiClient;

  AlertsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<dynamic>> fetchActiveAlerts() async {
    // CONEXIÓN CON BACKEND
    /*
    final response = await apiClient.get('api/v1.0/notificaciones');
    if (response.statusCode == 200) {
      return response.data as List<dynamic>;
    } else {
      throw Exception('Error al obtener alertas del servidor');
    }
    */

    await Future.delayed(const Duration(milliseconds: 600));

    // Retorna una lista con la misma estructura JSON que envía tu backend en .NET
    return [
      {
        "id": "101",
        "grano": "Arroz Costeño (Contenedor A)",
        "porcentajeActual": 12.0,
        "umbralDisparo": 20.0,
        "fechaCreacion": DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        "enviada": true
      },
      {
        "id": "102",
        "grano": "Azúcar Rubia (Contenedor B)",
        "porcentajeActual": 5.0,
        "umbralDisparo": 15.0,
        "fechaCreacion": DateTime.now().subtract(const Duration(minutes: 45)).toIso8601String(),
        "enviada": true
      },
      {
        "id": "103",
        "grano": "Lentejas Extra (Contenedor C)",
        "porcentajeActual": 18.0,
        "umbralDisparo": 10.0,
        "fechaCreacion": DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        "enviada": false
      }
    ];
  }
}