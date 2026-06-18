import 'package:dispenxcore_frontend/features/device/domain/entities/device_info.dart';
import 'package:dispenxcore_frontend/features/device/domain/repositories/device_repository.dart';

class GetDevice {
  final DeviceRepository repository;
  GetDevice(this.repository);

  Future<DeviceInfo> call() => repository.getDevice();
}
