import '../entities/alerta_stock.dart';

abstract class AlertasStockRepository {
  Future<List<AlertaStock>> getAlertasPorContenedor(String contenedorId);
  Future<void> evaluarAlerta({
    required String contenedorId,
    required double umbral,
    required String deviceToken,
  });
}
