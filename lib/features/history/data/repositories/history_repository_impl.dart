import '../../domain/entities/dispenser_event.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/history_remote_data_source.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryRemoteDataSource dataSource;
  HistoryRepositoryImpl({required this.dataSource});

  @override
  Future<List<DispenserEvent>> getEvents(int dispensatorId) async {
    try {
      return await dataSource.getEvents(dispensatorId);
    } catch (e) {
      throw Exception('Error al obtener historial: $e');
    }
  }
}
