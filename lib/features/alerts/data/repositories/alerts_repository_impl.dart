import '../../domain/entities/alert_grain.dart';
import '../../domain/repositories/alerts_repository.dart';
import '../datasources/alerts_remote_data_source.dart';

class AlertsRepositoryImpl implements AlertsRepository {
  final AlertsRemoteDataSource remoteDataSource;

  AlertsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<AlertGrain>> getActiveAlerts() async {
    try {
      final rawList = await remoteDataSource.fetchActiveAlerts();

      return rawList.map((item) {
        return AlertGrain(
          id: item['id'].toString(),
          grano: item['grano'] ?? 'Desconocido',
          porcentajeActual: (item['porcentajeActual'] as num).toDouble(),
          umbralDisparo: (item['umbralDisparo'] as num).toDouble(),
          fechaCreacion: DateTime.parse(item['fechaCreacion']),
          enviada: item['enviada'] ?? false,
        );
      }).toList();
    } catch (e) {
      throw Exception("Error procesando los datos de alertas: $e");
    }
  }
}