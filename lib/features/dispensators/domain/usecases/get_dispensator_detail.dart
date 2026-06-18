import 'package:dispenxcore_frontend/features/dispensators/domain/entities/dispensator_detail.dart';
import 'package:dispenxcore_frontend/features/dispensators/domain/repositories/dispensator_repository.dart';

class GetDispensatorDetail {
  final DispensatorRepository repository;
  GetDispensatorDetail(this.repository);

  Future<DispensatorDetail> call(int id) => repository.getDispensatorDetail(id);
}
