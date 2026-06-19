import '../../domain/entities/grain_inventory.dart';
import '../../domain/repositories/inventario_repository.dart';
import '../datasources/inventario_remote_data_source.dart';

class InventarioRepositoryImpl implements InventarioRepository {
  final InventarioRemoteDataSource dataSource;
  InventarioRepositoryImpl({required this.dataSource});

  @override
  Future<List<GrainInventory>> getEstado() async {
    try {
      return await dataSource.getEstado();
    } catch (e) {
      throw Exception('Error al obtener inventario: $e');
    }
  }

  @override
  Future<void> registrarMedicion({
    required String contenedorId,
    required double peso,
    required double nivel,
    required double flujo,
  }) async {
    try {
      await dataSource.registrarMedicion(
        contenedorId: contenedorId,
        peso: peso,
        nivel: nivel,
        flujo: flujo,
      );
    } catch (e) {
      throw Exception('Error al registrar medición: $e');
    }
  }
}
