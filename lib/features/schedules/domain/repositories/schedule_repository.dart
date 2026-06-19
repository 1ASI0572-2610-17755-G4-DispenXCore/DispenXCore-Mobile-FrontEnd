import '../entities/schedule.dart';

abstract class ScheduleRepository {
  Future<List<Schedule>> getSchedules(int dispensatorId);
  Future<void> createSchedule(Schedule schedule);
  Future<void> updateSchedule(int id, Schedule schedule);
  Future<void> deleteSchedule(int id);
  Future<void> toggleSchedule(int id);
}
