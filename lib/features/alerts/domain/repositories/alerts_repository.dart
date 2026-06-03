import '../entities/alert_grain.dart';

abstract class AlertsRepository {
  Future<List<AlertGrain>> getActiveAlerts();
}