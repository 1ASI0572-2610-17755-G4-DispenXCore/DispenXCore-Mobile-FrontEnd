import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/alert_grain.dart';

class AlertTile extends StatelessWidget {
  final AlertGrain alert;

  const AlertTile({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    // Evaluamos si el stock es bajo (menor al umbral)
    final bool isCritical = alert.porcentajeActual <= alert.umbralDisparo;
    final String formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(alert.fechaCreacion.toLocal());

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isCritical ? Colors.red.shade100 : Colors.amber.shade100,
          child: Icon(
            isCritical ? Icons.gpp_bad : Icons.warning_amber_rounded,
            color: isCritical ? Colors.red : Colors.amber.shade800,
          ),
        ),
        title: Text(
          alert.grano,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Umbral Configurado: ${alert.umbralDisparo.toStringAsFixed(0)}%'),
            Text('Detectado: $formattedDate', style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isCritical ? Colors.red : Colors.amber.shade700,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${alert.porcentajeActual.toStringAsFixed(0)}%',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}