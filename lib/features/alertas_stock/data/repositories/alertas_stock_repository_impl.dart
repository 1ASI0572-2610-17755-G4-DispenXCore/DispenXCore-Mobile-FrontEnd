import '../../domain/entities/alerta_stock.dart';
import '../../domain/repositories/alertas_stock_repository.dart';
import '../datasources/alertas_stock_remote_data_source.dart';

class AlertasStockRepositoryImpl implements AlertasStockRepository {
  final AlertasStockRemoteDataSource dataSource;
  AlertasStockRepositoryImpl({required this.dataSource});

  @override
  Future<List<AlertaStock>> getAlertasPorContenedor(String contenedorId) async {
    try {
      return await dataSource.getAlertasPorContenedor(contenedorId);
    } catch (e) {
      throw Exception('Error al obtener alertas de stock: $e');
    }
  }

  @override
  Future<void> evaluarAlerta({
    required String contenedorId,
    required double umbral,
    required String deviceToken,
  }) async {
    try {
      await dataSource.evaluarAlerta(
        contenedorId: contenedorId,
        umbral: umbral,
        deviceToken: deviceToken,
      );
    } catch (e) {
      throw Exception('Error al evaluar alerta: $e');
    }
  }
}
