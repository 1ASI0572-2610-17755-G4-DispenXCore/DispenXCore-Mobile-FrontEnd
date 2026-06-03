class AlertGrain {
  final String id;
  final String grano;
  final double porcentajeActual;
  final double umbralDisparo;
  final DateTime fechaCreacion;
  final bool enviada;

  AlertGrain({
    required this.id,
    required this.grano,
    required this.porcentajeActual,
    required this.umbralDisparo,
    required this.fechaCreacion,
    required this.enviada,
  });
}