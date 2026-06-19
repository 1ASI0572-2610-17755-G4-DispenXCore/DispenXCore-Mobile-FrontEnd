import '../entities/dispenser_event.dart';

abstract class HistoryRepository {
  Future<List<DispenserEvent>> getEvents(int dispensatorId);
}
