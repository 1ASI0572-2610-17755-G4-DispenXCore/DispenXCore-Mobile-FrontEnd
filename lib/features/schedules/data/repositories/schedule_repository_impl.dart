import '../../domain/entities/schedule.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../datasources/schedule_remote_data_source.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final ScheduleRemoteDataSource dataSource;
  ScheduleRepositoryImpl({required this.dataSource});

  @override
  Future<List<Schedule>> getSchedules(int dispensatorId) async {
    try {
      return await dataSource.getSchedules(dispensatorId);
    } catch (e) {
      throw Exception('Error al obtener horarios: $e');
    }
  }

  @override
  Future<void> createSchedule(Schedule schedule) async {
    try {
      await dataSource.createSchedule(schedule);
    } catch (e) {
      throw Exception('Error al crear horario: $e');
    }
  }

  @override
  Future<void> updateSchedule(int id, Schedule schedule) async {
    try {
      await dataSource.updateSchedule(id, schedule);
    } catch (e) {
      throw Exception('Error al actualizar horario: $e');
    }
  }

  @override
  Future<void> deleteSchedule(int id) async {
    try {
      await dataSource.deleteSchedule(id);
    } catch (e) {
      throw Exception('Error al eliminar horario: $e');
    }
  }

  @override
  Future<void> toggleSchedule(int id) async {
    try {
      await dataSource.toggleSchedule(id);
    } catch (e) {
      throw Exception('Error al cambiar estado: $e');
    }
  }
}
