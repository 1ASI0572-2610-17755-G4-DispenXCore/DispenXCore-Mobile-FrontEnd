import 'package:dispenxcore_frontend/features/dispensators/domain/entities/dispensator.dart';
import 'package:dispenxcore_frontend/features/dispensators/domain/entities/dispensator_detail.dart';

abstract class DispensatorRepository {
  Future<List<Dispensator>> getDispensators();
  Future<DispensatorDetail> getDispensatorDetail(int id);
}
