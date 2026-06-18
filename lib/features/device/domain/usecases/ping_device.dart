import 'package:dispenxcore_frontend/features/device/domain/repositories/device_repository.dart';

class PingDevice {
  final DeviceRepository repository;
  PingDevice(this.repository);

  Future<void> call() => repository.pingDevice();
}
