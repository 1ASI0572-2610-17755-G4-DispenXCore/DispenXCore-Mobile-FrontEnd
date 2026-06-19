import '../entities/schedule.dart';
import '../repositories/schedule_repository.dart';

class GetSchedules {
  final ScheduleRepository repo;
  GetSchedules(this.repo);
  Future<List<Schedule>> call(int dispensatorId) => repo.getSchedules(dispensatorId);
}

class CreateSchedule {
  final ScheduleRepository repo;
  CreateSchedule(this.repo);
  Future<void> call(Schedule schedule) => repo.createSchedule(schedule);
}

class UpdateSchedule {
  final ScheduleRepository repo;
  UpdateSchedule(this.repo);
  Future<void> call(int id, Schedule schedule) => repo.updateSchedule(id, schedule);
}

class DeleteSchedule {
  final ScheduleRepository repo;
  DeleteSchedule(this.repo);
  Future<void> call(int id) => repo.deleteSchedule(id);
}

class ToggleSchedule {
  final ScheduleRepository repo;
  ToggleSchedule(this.repo);
  Future<void> call(int id) => repo.toggleSchedule(id);
}
