import 'package:dispenxcore_frontend/features/dispensators/data/datasources/dispensator_remote_data_source.dart';
import 'package:dispenxcore_frontend/features/dispensators/domain/entities/dispensator.dart';
import 'package:dispenxcore_frontend/features/dispensators/domain/entities/dispensator_detail.dart';
import 'package:dispenxcore_frontend/features/dispensators/domain/repositories/dispensator_repository.dart';

class DispensatorRepositoryImpl implements DispensatorRepository {
  final DispensatorRemoteDataSource remoteDataSource;
  DispensatorRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Dispensator>> getDispensators() =>
      remoteDataSource.getDispensators();

  @override
  Future<DispensatorDetail> getDispensatorDetail(int id) =>
      remoteDataSource.getDispensatorDetail(id);
}
