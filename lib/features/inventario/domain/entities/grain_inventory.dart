class GrainInventory {
  final String id;
  final String grano;
  final int porcentajeRestante;
  final int pesoActual;
  final int nivelActual;

  const GrainInventory({
    required this.id,
    required this.grano,
    required this.porcentajeRestante,
    required this.pesoActual,
    required this.nivelActual,
  });

  factory GrainInventory.fromJson(Map<String, dynamic> json) {
    return GrainInventory(
      id: json['id'] as String,
      grano: json['grano'] as String,
      porcentajeRestante: (json['porcentajeRestante'] as num).toInt(),
      pesoActual: (json['pesoActual'] as num).toInt(),
      nivelActual: (json['nivelActual'] as num).toInt(),
    );
  }

  double get fraction => (porcentajeRestante / 100).clamp(0.0, 1.0);
}
