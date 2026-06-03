import '../entities/alert_grain.dart';
import '../repositories/alerts_repository.dart';

class GetActiveAlerts {
  final AlertsRepository repository;

  GetActiveAlerts(this.repository);

  Future<List<AlertGrain>> call() async {
    return await repository.getActiveAlerts();
  }
}