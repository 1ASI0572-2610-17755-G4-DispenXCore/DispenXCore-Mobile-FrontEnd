class Dispensator {
  final int id;
  final String name;
  final String status;
  final int maxCapacity;

  const Dispensator({
    required this.id,
    required this.name,
    required this.status,
    required this.maxCapacity,
  });

  factory Dispensator.fromJson(Map<String, dynamic> json) => Dispensator(
        id: json['id'] as int? ?? 0,
        name: json['name'] as String? ?? '',
        status: json['status'] as String? ?? 'active',
        maxCapacity: json['maxCapacity'] as int? ?? 0,
      );

  bool get isActive => status.toLowerCase() == 'active';
}
