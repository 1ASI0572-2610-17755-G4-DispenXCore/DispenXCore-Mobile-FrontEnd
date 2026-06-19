import '../entities/dispenser_event.dart';
import '../repositories/history_repository.dart';

class GetDispenserEvents {
  final HistoryRepository repo;
  GetDispenserEvents(this.repo);

  Future<List<DispenserEvent>> call(int dispensatorId) =>
      repo.getEvents(dispensatorId);
}
