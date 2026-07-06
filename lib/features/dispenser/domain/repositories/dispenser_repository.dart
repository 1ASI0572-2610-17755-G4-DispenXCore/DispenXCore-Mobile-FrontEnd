import '../entities/dispense_result.dart';

abstract class DispenserRepository {
  Future<DispenseResult> activarDispensador({
    required String deviceId,
    String? supplyType,
  });
}
