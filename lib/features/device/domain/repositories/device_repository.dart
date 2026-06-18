import 'package:dispenxcore_frontend/features/device/domain/entities/device_info.dart';

abstract class DeviceRepository {
  Future<DeviceInfo> getDevice();
  Future<DeviceInfo> updateDevice({required String name, required String location});
  Future<void> pingDevice();
}
