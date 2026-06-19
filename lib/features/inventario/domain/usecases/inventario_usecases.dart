import '../entities/grain_inventory.dart';
import '../repositories/inventario_repository.dart';

class GetInventarioEstado {
  final InventarioRepository repo;
  GetInventarioEstado(this.repo);
  Future<List<GrainInventory>> call() => repo.getEstado();
}

class RegistrarMedicion {
  final InventarioRepository repo;
  RegistrarMedicion(this.repo);
  Future<void> call({
    required String contenedorId,
    required double peso,
    required double nivel,
    required double flujo,
  }) => repo.registrarMedicion(
        contenedorId: contenedorId,
        peso: peso,
        nivel: nivel,
        flujo: flujo,
      );
}
