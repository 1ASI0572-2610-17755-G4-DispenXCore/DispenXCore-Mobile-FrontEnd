import '../entities/grain_inventory.dart';

abstract class InventarioRepository {
  Future<List<GrainInventory>> getEstado();
  Future<void> registrarMedicion({
    required String contenedorId,
    required double peso,
    required double nivel,
    required double flujo,
  });
}
