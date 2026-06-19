import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injector.dart';
import '../../domain/entities/alerta_stock.dart';
import '../../domain/usecases/alertas_stock_usecases.dart';

class AlertasStockPage extends StatefulWidget {
  final String contenedorId;
  final String grano;

  const AlertasStockPage({
    super.key,
    required this.contenedorId,
    required this.grano,
  });

  @override
  State<AlertasStockPage> createState() => _AlertasStockPageState();
}

class _AlertasStockPageState extends State<AlertasStockPage> {
  static const _teal = Color(0xFF009688);

  late final GetAlertasStock _getAlertas;
  List<AlertaStock> _alertas = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _getAlertas = injector<GetAlertasStock>();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      final result = await _getAlertas(widget.contenedorId);
      result.sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));
      if (!mounted) return;
      setState(() { _alertas = result; _isLoading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text('Alertas · ${widget.grano}',
            style: const TextStyle(fontFamily: 'Arimo',
                fontWeight: FontWeight.w700)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F2937),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE5E7EB)),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: _teal,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: _teal));
    }

    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(children: [
                const Icon(Icons.cloud_off_rounded, size: 48,
                    color: Color(0xFFD1D5DB)),
                const SizedBox(height: 12),
                Text(_error!, textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFF6B7280),
                        fontFamily: 'Arimo')),
              ]),
            ),
          ),
        ],
      );
    }

    if (_alertas.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.28),
          const Center(
            child: Column(children: [
              Icon(Icons.check_circle_outline_rounded, size: 64,
                  color: Color(0xFF16A34A)),
              SizedBox(height: 16),
              Text('Sin alertas activas',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                      fontFamily: 'Arimo', color: Color(0xFF1F2937))),
              SizedBox(height: 6),
              Text('El nivel de stock está dentro del rango normal.',
                  style: TextStyle(color: Color(0xFF9CA3AF),
                      fontFamily: 'Arimo')),
            ]),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _alertas.length,
      itemBuilder: (_, i) => _AlertaStockCard(alerta: _alertas[i]),
    );
  }
}

class _AlertaStockCard extends StatelessWidget {
  final AlertaStock alerta;
  const _AlertaStockCard({required this.alerta});

  @override
  Widget build(BuildContext context) {
    final critica = alerta.esCritica;
    final color = critica ? const Color(0xFFEF4444) : const Color(0xFFF59E0B);
    final bgColor = critica ? const Color(0xFFFEE2E2) : const Color(0xFFFEF3C7);
    final icon = critica ? Icons.gpp_bad_rounded : Icons.warning_amber_rounded;
    final fecha = DateFormat('dd/MM/yyyy HH:mm')
        .format(alerta.fechaCreacion.toLocal());

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: Container(
          width: 42, height: 42,
          decoration: BoxDecoration(color: bgColor,
              borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(alerta.grano,
            style: const TextStyle(fontFamily: 'Arimo',
                fontWeight: FontWeight.w700, fontSize: 14,
                color: Color(0xFF1F2937))),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 3),
          Text('Umbral: ${alerta.umbralDisparo.toStringAsFixed(0)}%  ·  '
              '${alerta.enviada ? "Notificada" : "Pendiente"}',
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280),
                  fontFamily: 'Arimo')),
          const SizedBox(height: 2),
          Text(fecha,
              style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF),
                  fontFamily: 'Arimo')),
        ]),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: color,
              borderRadius: BorderRadius.circular(12)),
          child: Text('${alerta.porcentajeActual.toStringAsFixed(0)}%',
              style: const TextStyle(color: Colors.white,
                  fontWeight: FontWeight.w700, fontFamily: 'Arimo',
                  fontSize: 13)),
        ),
      ),
    );
  }
}
