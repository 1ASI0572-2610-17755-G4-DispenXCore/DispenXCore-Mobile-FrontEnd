import 'package:dispenxcore_frontend/features/dispensators/domain/entities/dispensator.dart';
import 'package:dispenxcore_frontend/features/dispensators/domain/repositories/dispensator_repository.dart';

class GetDispensators {
  final DispensatorRepository repository;
  GetDispensators(this.repository);

  Future<List<Dispensator>> call() => repository.getDispensators();
}
