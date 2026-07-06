import 'package:dispenxcore_frontend/features/dispenser/domain/entities/dispense_result.dart';
import 'package:dispenxcore_frontend/features/dispenser/domain/repositories/dispenser_repository.dart';

class ActivateDispenser {
  final DispenserRepository repository;
  ActivateDispenser(this.repository);

  Future<DispenseResult> call({
    required String deviceId,
    String? supplyType,
  }) =>
      repository.activarDispensador(deviceId: deviceId, supplyType: supplyType);
}
