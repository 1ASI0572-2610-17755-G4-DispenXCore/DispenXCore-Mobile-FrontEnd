import 'package:flutter/material.dart';
import '../../domain/entities/alert_grain.dart';
import '../../domain/usecases/get_active_alerts.dart';
import '../widgets/alert_tile.dart';

class AlertsPage extends StatefulWidget {
  final GetActiveAlerts getActiveAlerts;

  const AlertsPage({
    super.key,
    required this.getActiveAlerts,
  });

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  late Future<List<AlertGrain>> _alertsFuture;

  @override
  void initState() {
    super.initState();
    _alertsFuture = widget.getActiveAlerts();
  }

  Future<void> _refreshAlerts() async {
    setState(() {
      _alertsFuture = widget.getActiveAlerts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertas Activas'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAlerts,
        child: FutureBuilder<List<AlertGrain>>(
          future: _alertsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error al conectar con el backend: \n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
                        SizedBox(height: 16),
                        Text(
                          '¡Todo está en orden!',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text('No hay alertas pendientes en este momento.'),
                      ],
                    ),
                  ),
                ],
              );
            }

            final alerts = snapshot.data!;
            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: alerts.length,
              itemBuilder: (context, index) {
                return AlertTile(alert: alerts[index]);
              },
            );
          },
        ),
      ),
    );
  }
}