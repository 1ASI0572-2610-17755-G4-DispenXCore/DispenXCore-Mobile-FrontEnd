import 'dart:async';
import 'package:dispenxcore_frontend/core/di/injector.dart';
import 'package:dispenxcore_frontend/features/device/domain/usecases/get_device.dart';
import 'package:dispenxcore_frontend/features/schedules/domain/entities/schedule.dart';
import 'package:dispenxcore_frontend/features/schedules/domain/usecases/schedule_usecases.dart';
import 'edge_service.dart';

typedef OnTriggerCallback = void Function(Schedule schedule, bool success, String? error);

class SchedulerService {
  final GetSchedules getSchedules;
  final GetDevice getDevice;
  final EdgeService edgeService;

  SchedulerService({
    required this.getSchedules,
    required this.getDevice,
    required this.edgeService,
  });

  Timer? _timer;
  List<Schedule> _schedules = [];
  bool _isLoading = false;
  OnTriggerCallback? onTriggered;

  // Track triggered schedules by format "scheduleId_dateString_hourMinute"
  // to avoid triggering multiple times within the same minute.
  final Set<String> _triggeredKeys = {};

  Future<void> start() async {
    if (_timer != null) return;
    
    // Initial load
    await loadSchedules();

    // Check every 30 seconds
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _checkSchedules());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> loadSchedules() async {
    if (_isLoading) return;
    _isLoading = true;
    try {
      // Assuming dispensatorId = 1 is the main dispensator
      final list = await getSchedules(1);
      _schedules = list.where((s) => s.isActive).toList();
    } catch (e) {
      print('SchedulerService: Error loading schedules: $e');
    } finally {
      _isLoading = false;
    }
  }

  Future<void> _checkSchedules() async {
    final now = DateTime.now();
    final currentWeekday = now.weekday; // 1 = Monday, 7 = Sunday
    final currentHour = now.hour;
    final currentMinute = now.minute;
    final hourMinuteStr = '${currentHour.toString().padLeft(2, '0')}:${currentMinute.toString().padLeft(2, '0')}';
    
    // Format: YYYY-MM-DD to clear triggers from previous days
    final dateStr = '${now.year}-${now.month}-${now.day}';

    for (final schedule in _schedules) {
      // Extract hour and minute from schedule.scheduledTime ("HH:mm:ss" or "HH:mm")
      final parts = schedule.scheduledTime.split(':');
      if (parts.length < 2) continue;
      final schedHour = int.tryParse(parts[0]);
      final schedMinute = int.tryParse(parts[1]);
      if (schedHour == null || schedMinute == null) continue;

      // Check if time matches
      if (schedHour == currentHour && schedMinute == currentMinute) {
        // Check if current weekday matches
        if (schedule.frequencyDays.contains(currentWeekday)) {
          final triggerKey = '${schedule.id}_${dateStr}_$hourMinuteStr';
          
          if (!_triggeredKeys.contains(triggerKey)) {
            _triggeredKeys.add(triggerKey);
            _executeScheduleDispense(schedule);
          }
        }
      }
    }

    // Clean up old triggered keys to prevent memory leak
    if (_triggeredKeys.length > 100) {
      _triggeredKeys.retainWhere((key) => key.contains(dateStr));
    }
  }

  Future<void> _executeScheduleDispense(Schedule schedule) async {
    try {
      final device = await getDevice();
      if (device.id.isEmpty) {
        throw Exception('Dispositivo no configurado');
      }

      // Convert supplyType int to name
      // 0: Estándar (General), 1: Reducido, 2: Completo, 3: Doble, 4: Personalizado
      // Edge expects a supply type string, e.g. "General", "Arroz", "Legumbres", etc.
      final supplyLabels = {
        0: 'General',
        1: 'Reducido',
        2: 'Completo',
        3: 'Doble',
        4: 'Personalizado',
      };
      final supplyTypeStr = supplyLabels[schedule.supplyType] ?? 'General';

      await edgeService.activateDispense(
        deviceId: device.id,
        supplyType: supplyTypeStr,
      );

      if (onTriggered != null) {
        onTriggered!(schedule, true, null);
      }
    } catch (e) {
      print('SchedulerService: Error triggering schedule: $e');
      if (onTriggered != null) {
        onTriggered!(schedule, false, e.toString());
      }
    }
  }
}
