class Schedule {
  final int id;
  final int dispensatorId;
  final String name;
  final int supplyType;
  final int amount;
  final String scheduledTime;
  final List<int> frequencyDays;
  final bool smartRefill;
  final bool isActive;

  const Schedule({
    required this.id,
    required this.dispensatorId,
    required this.name,
    required this.supplyType,
    required this.amount,
    required this.scheduledTime,
    required this.frequencyDays,
    required this.smartRefill,
    required this.isActive,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    final freqRaw = json['frequencyDays'];
    List<int> days = [];
    if (freqRaw is Map<String, dynamic>) {
      final d = freqRaw['days'];
      if (d is List) days = List<int>.from(d);
    } else if (freqRaw is List) {
      days = List<int>.from(freqRaw);
    }
    return Schedule(
      id: json['id'] as int,
      dispensatorId: json['dispensatorId'] as int,
      name: json['name'] as String,
      supplyType: json['supplyType'] as int,
      amount: json['amount'] as int,
      scheduledTime: json['scheduledTime'] as String,
      frequencyDays: days,
      smartRefill: json['smartRefill'] as bool,
      isActive: json['isActive'] as bool,
    );
  }

  // POST/PUT body — frequencyDays se envía como array directo
  Map<String, dynamic> toJson() => {
        'dispensatorId': dispensatorId,
        'name': name,
        'supplyType': supplyType.toString(),
        'amount': amount,
        'scheduledTime': scheduledTime,
        'frequencyDays': frequencyDays,
        'smartRefill': smartRefill,
        'isActive': isActive,
      };

  Schedule copyWith({bool? isActive}) => Schedule(
        id: id,
        dispensatorId: dispensatorId,
        name: name,
        supplyType: supplyType,
        amount: amount,
        scheduledTime: scheduledTime,
        frequencyDays: frequencyDays,
        smartRefill: smartRefill,
        isActive: isActive ?? this.isActive,
      );
}
