import '../../domain/entities/dispense_result.dart';
import '../../domain/repositories/dispenser_repository.dart';
import '../datasources/dispenser_remote_data_source.dart';

class DispenserRepositoryImpl implements DispenserRepository {
  final DispenserRemoteDataSource dataSource;
  DispenserRepositoryImpl({required this.dataSource});

  @override
  Future<DispenseResult> activarDispensador({
    required String deviceId,
    String? supplyType,
  }) async {
    try {
      final data = await dataSource.activarDispensador(
        deviceId: deviceId,
        supplyType: supplyType,
      );
      return DispenseResult.fromJson(data);
    } catch (e) {
      throw Exception('Error al activar dispensador: $e');
    }
  }
}
