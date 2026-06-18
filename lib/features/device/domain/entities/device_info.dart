class DeviceInfo {
  final String id;
  final String name;
  final String model;
  final String location;
  final String serialNumber;
  final String registeredAt;
  final String lastSeen;

  const DeviceInfo({
    required this.id,
    required this.name,
    required this.model,
    required this.location,
    required this.serialNumber,
    required this.registeredAt,
    required this.lastSeen,
  });

  factory DeviceInfo.fromJson(Map<String, dynamic> json) => DeviceInfo(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        model: json['model'] as String? ?? '',
        location: json['location'] as String? ?? '',
        serialNumber: json['serialNumber'] as String? ?? '',
        registeredAt: json['registeredAt'] as String? ?? '',
        lastSeen: json['lastSeen'] as String? ?? '',
      );

  String get formattedLastSeen {
    if (lastSeen.isEmpty) return '—';
    try {
      final dt = DateTime.parse(lastSeen).toLocal();
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '${dt.day}/${dt.month}/${dt.year} $h:$m';
    } catch (_) {
      return lastSeen;
    }
  }
}
