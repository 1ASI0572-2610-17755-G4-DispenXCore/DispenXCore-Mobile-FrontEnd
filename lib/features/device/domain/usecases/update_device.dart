import 'package:dispenxcore_frontend/features/device/domain/entities/device_info.dart';
import 'package:dispenxcore_frontend/features/device/domain/repositories/device_repository.dart';

class UpdateDevice {
  final DeviceRepository repository;
  UpdateDevice(this.repository);

  Future<DeviceInfo> call({required String name, required String location}) =>
      repository.updateDevice(name: name, location: location);
}
