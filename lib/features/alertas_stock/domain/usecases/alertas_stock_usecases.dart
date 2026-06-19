import '../entities/alerta_stock.dart';
import '../repositories/alertas_stock_repository.dart';

class GetAlertasStock {
  final AlertasStockRepository repo;
  GetAlertasStock(this.repo);
  Future<List<AlertaStock>> call(String contenedorId) =>
      repo.getAlertasPorContenedor(contenedorId);
}

class EvaluarAlertaStock {
  final AlertasStockRepository repo;
  EvaluarAlertaStock(this.repo);
  Future<void> call({
    required String contenedorId,
    required double umbral,
    required String deviceToken,
  }) => repo.evaluarAlerta(
        contenedorId: contenedorId,
        umbral: umbral,
        deviceToken: deviceToken,
      );
}
