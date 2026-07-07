import 'package:dispenxcore_frontend/core/utils/date_formatter.dart';

class DispensatorDetail {
  final int id;
  final int dispensatorId;
  final bool isActive;
  final int currentCapacity;
  final int maxCapacity;
  final int dailyTotal;
  final String nextDispenseAt;

  const DispensatorDetail({
    required this.id,
    required this.dispensatorId,
    required this.isActive,
    required this.currentCapacity,
    required this.maxCapacity,
    required this.dailyTotal,
    required this.nextDispenseAt,
  });

  factory DispensatorDetail.fromJson(Map<String, dynamic> json) =>
      DispensatorDetail(
        id: json['id'] as int? ?? 0,
        dispensatorId: json['dispensatorId'] as int? ?? 0,
        isActive: json['isActive'] as bool? ?? false,
        currentCapacity: json['currentCapacity'] as int? ?? 0,
        maxCapacity: json['maxCapacity'] as int? ?? 1,
        dailyTotal: json['dailyTotal'] as int? ?? 0,
        nextDispenseAt: json['nextDispenseAt'] as String? ?? '',
      );

  double get capacityPercent =>
      maxCapacity > 0 ? (currentCapacity / maxCapacity).clamp(0.0, 1.0) : 0.0;

  String get formattedNextDispense {
    if (nextDispenseAt.isEmpty) return '—';
    try {
      final dt = parseUtcToLocal(nextDispenseAt);
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m · ${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return nextDispenseAt;
    }
  }
}
