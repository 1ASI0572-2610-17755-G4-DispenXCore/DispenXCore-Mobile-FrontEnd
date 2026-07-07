import 'package:dispenxcore_frontend/core/utils/date_formatter.dart';

class DispenserEvent {
  final int id;
  final int dispensatorId;
  final int? scheduleId;
  final int trigger;
  final int supplyType;
  final int amountDispensed;
  final DateTime dispensedAt;

  const DispenserEvent({
    required this.id,
    required this.dispensatorId,
    required this.scheduleId,
    required this.trigger,
    required this.supplyType,
    required this.amountDispensed,
    required this.dispensedAt,
  });

  factory DispenserEvent.fromJson(Map<String, dynamic> json) {
    return DispenserEvent(
      id: json['id'] as int,
      dispensatorId: json['dispensatorId'] as int,
      scheduleId: json['scheduleId'] as int?,
      trigger: json['trigger'] as int,
      supplyType: json['supplyType'] as int,
      amountDispensed: json['amountDispensed'] as int,
      dispensedAt: parseUtcToLocal(json['dispensedAt'] as String),
    );
  }
}
