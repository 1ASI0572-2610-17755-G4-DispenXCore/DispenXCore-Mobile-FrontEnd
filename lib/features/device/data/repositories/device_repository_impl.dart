import 'package:dispenxcore_frontend/features/device/data/datasources/device_remote_data_source.dart';
import 'package:dispenxcore_frontend/features/device/domain/entities/device_info.dart';
import 'package:dispenxcore_frontend/features/device/domain/repositories/device_repository.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  final DeviceRemoteDataSource remoteDataSource;
  DeviceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<DeviceInfo> getDevice() => remoteDataSource.getDevice();

  @override
  Future<DeviceInfo> updateDevice({
    required String name,
    required String location,
  }) =>
      remoteDataSource.updateDevice(name: name, location: location);

  @override
  Future<void> pingDevice() => remoteDataSource.pingDevice();
}
