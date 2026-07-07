import 'package:dispenxcore_frontend/core/utils/date_formatter.dart';

class AlertaStock {
  final String id;
  final String grano;
  final double porcentajeActual;
  final double umbralDisparo;
  final DateTime fechaCreacion;
  final bool enviada;

  const AlertaStock({
    required this.id,
    required this.grano,
    required this.porcentajeActual,
    required this.umbralDisparo,
    required this.fechaCreacion,
    required this.enviada,
  });

  factory AlertaStock.fromJson(Map<String, dynamic> json) {
    return AlertaStock(
      id: json['id'] as String,
      grano: json['grano'] as String,
      porcentajeActual: (json['porcentajeActual'] as num).toDouble(),
      umbralDisparo: (json['umbralDisparo'] as num).toDouble(),
      fechaCreacion: parseUtcToLocal(json['fechaCreacion'] as String),
      enviada: json['enviada'] as bool,
    );
  }

  bool get esCritica => porcentajeActual <= umbralDisparo;
}
