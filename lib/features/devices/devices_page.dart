import 'package:dispenxcore_frontend/core/di/injector.dart';
import 'package:dispenxcore_frontend/features/device/domain/entities/device_info.dart';
import 'package:dispenxcore_frontend/features/device/domain/usecases/get_device.dart';
import 'package:dispenxcore_frontend/features/device/domain/usecases/ping_device.dart';
import 'package:dispenxcore_frontend/features/device/domain/usecases/update_device.dart';
import 'package:dispenxcore_frontend/features/dispensators/domain/entities/dispensator.dart';
import 'package:dispenxcore_frontend/features/dispensators/domain/entities/dispensator_detail.dart';
import 'package:dispenxcore_frontend/features/dispensators/domain/usecases/get_dispensator_detail.dart';
import 'package:dispenxcore_frontend/features/dispensators/domain/usecases/get_dispensators.dart';
import 'package:flutter/material.dart';

class DevicesPage extends StatefulWidget {
  const DevicesPage({super.key});

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  static const _teal = Color(0xFF009688);
  static const _blue = Color(0xFF2563EB);

  DeviceInfo? _device;
  bool _isLoadingDevice = true;
  String? _deviceError;

  List<Dispensator> _dispensators = [];
  bool _isLoadingDispensators = true;
  String? _dispensatorsError;

  bool _pinging = false;

  late final GetDevice _getDevice;
  late final UpdateDevice _updateDevice;
  late final PingDevice _pingDevice;
  late final GetDispensators _getDispensators;
  late final GetDispensatorDetail _getDispensatorDetail;

  @override
  void initState() {
    super.initState();
    _getDevice = injector<GetDevice>();
    _updateDevice = injector<UpdateDevice>();
    _pingDevice = injector<PingDevice>();
    _getDispensators = injector<GetDispensators>();
    _getDispensatorDetail = injector<GetDispensatorDetail>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadAll();
    });
  }

  Future<void> _loadAll() async {
    _loadDevice();
    _loadDispensators();
  }

  Future<void> _loadDevice() async {
    if (!mounted) return;
    setState(() { _isLoadingDevice = true; _deviceError = null; });
    try {
      final device = await _getDevice.call();
      if (!mounted) return;
      setState(() { _device = device; _isLoadingDevice = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _deviceError = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
        _isLoadingDevice = false;
      });
    }
  }

  Future<void> _loadDispensators() async {
    if (!mounted) return;
    setState(() { _isLoadingDispensators = true; _dispensatorsError = null; });
    try {
      final list = await _getDispensators.call();
      if (!mounted) return;
      setState(() { _dispensators = list; _isLoadingDispensators = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _dispensatorsError =
            e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
        _isLoadingDispensators = false;
      });
    }
  }

  Future<void> _ping() async {
    if (_pinging || !mounted) return;
    setState(() => _pinging = true);
    try {
      await _pingDevice.call();
      if (!mounted) return;
      _snack('Ping enviado al dispositivo', success: true);
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      _snack(msg, success: false);
    } finally {
      if (mounted) setState(() => _pinging = false);
    }
  }

  void _snack(String msg, {required bool success}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'Arimo')),
      backgroundColor: success ? _teal : Colors.red.shade600,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  Future<void> _showDispensatorDetail(Dispensator dispensator) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DispensatorDetailSheet(
        dispensator: dispensator,
        getDetail: _getDispensatorDetail,
      ),
    );
  }

  Future<void> _showEditDeviceDialog() async {
    if (_device == null || !mounted) return;
    final updated = await showDialog<DeviceInfo>(
      context: context,
      builder: (ctx) => _EditDeviceDialog(
        device: _device!,
        updateDevice: _updateDevice,
      ),
    );
    if (updated != null && mounted) {
      setState(() => _device = updated);
      _snack('Dispositivo actualizado', success: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopHeader(),
            const SizedBox(height: 20),
            _buildDeviceCard(),
            const SizedBox(height: 14),
            if (_device != null)
              Row(children: [
                Expanded(child: _buildInfoTile(
                  icon: Icons.location_on_outlined,
                  label: 'UBICACIÓN',
                  value: _device!.location,
                  color: _blue,
                )),
                const SizedBox(width: 12),
                Expanded(child: _buildInfoTile(
                  icon: Icons.memory_outlined,
                  label: 'MODELO',
                  value: _device!.model,
                  color: _teal,
                )),
              ]),
            const SizedBox(height: 26),
            _buildSectionTitle('Dispensadores'),
            const SizedBox(height: 12),
            _buildDispensatorsList(),
            const SizedBox(height: 24),
            _buildPingAction(),
            const SizedBox(height: 14),
            if (_device != null) _buildDeviceDetailsCard(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    final name = _device?.name ?? 'Mi dispositivo';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('DISPOSITIVO CONECTADO',
                style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF),
                    fontFamily: 'Arimo', fontWeight: FontWeight.w600,
                    letterSpacing: 0.7)),
            const SizedBox(height: 2),
            Text(name, style: const TextStyle(fontSize: 20,
                fontWeight: FontWeight.w700, fontFamily: 'Arimo',
                color: Color(0xFF1F2937))),
          ]),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(20)),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            CircleAvatar(radius: 3.5, backgroundColor: Color(0xFF16A34A)),
            SizedBox(width: 5),
            Text('En línea', style: TextStyle(fontSize: 12,
                fontFamily: 'Arimo', fontWeight: FontWeight.w600,
                color: Color(0xFF16A34A))),
          ]),
        ),
      ],
    );
  }

  Widget _buildDeviceCard() {
    if (_isLoadingDevice) {
      return _loadingCard(height: 100);
    }
    if (_deviceError != null) {
      return _errorCard(_deviceError!, onRetry: _loadDevice);
    }
    final dev = _device!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF00897B), _teal],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: _teal.withValues(alpha: 0.28),
            blurRadius: 18, offset: const Offset(0, 6))],
      ),
      child: Row(children: [
        Container(width: 48, height: 48,
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.router_outlined,
                color: Colors.white, size: 24)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Estado del dispositivo',
              style: TextStyle(color: Colors.white70, fontSize: 12,
                  fontFamily: 'Arimo')),
          const SizedBox(height: 2),
          Text(dev.name, style: const TextStyle(color: Colors.white,
              fontSize: 16, fontFamily: 'Arimo', fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(dev.id, style: const TextStyle(color: Colors.white54,
              fontSize: 11, fontFamily: 'Arimo')),
        ])),
        IconButton(
          onPressed: _showEditDeviceDialog,
          icon: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.edit_outlined, size: 16, color: Colors.white),
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ]),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF0F0F0)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 10, color: color,
              fontFamily: 'Arimo', fontWeight: FontWeight.w600, letterSpacing: 0.4)),
        ]),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontSize: 13,
            fontWeight: FontWeight.w600, fontFamily: 'Arimo',
            color: Color(0xFF1F2937)), maxLines: 2,
            overflow: TextOverflow.ellipsis),
      ]),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 15,
        fontWeight: FontWeight.w700, fontFamily: 'Arimo',
        color: Color(0xFF1F2937)));
  }

  Widget _buildDispensatorsList() {
    if (_isLoadingDispensators) return _loadingCard(height: 80);

    if (_dispensatorsError != null) {
      return _errorCard(_dispensatorsError!, onRetry: _loadDispensators);
    }

    if (_dispensators.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFF0F0F0))),
        child: const Center(child: Column(children: [
          Icon(Icons.inventory_2_outlined, color: Color(0xFF9CA3AF), size: 32),
          SizedBox(height: 8),
          Text('No hay dispensadores registrados',
              style: TextStyle(color: Color(0xFF9CA3AF),
                  fontFamily: 'Arimo', fontSize: 13)),
        ])),
      );
    }

    return Column(children: _dispensators
        .map((d) => _buildDispensatorTile(d))
        .toList());
  }

  Widget _buildDispensatorTile(Dispensator d) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF0F0F0)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6, offset: const Offset(0, 2))]),
      child: ListTile(
        onTap: () => _showDispensatorDetail(d),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(width: 40, height: 40,
            decoration: BoxDecoration(
                color: _teal.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.grain, color: _teal, size: 20)),
        title: Text(d.name, style: const TextStyle(fontWeight: FontWeight.w600,
            fontFamily: 'Arimo', fontSize: 13, color: Color(0xFF1F2937))),
        subtitle: Text('Cap. máx: ${d.maxCapacity} g',
            style: const TextStyle(fontSize: 11,
                color: Color(0xFF9CA3AF), fontFamily: 'Arimo')),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: d.isActive
                  ? const Color(0xFFDCFCE7)
                  : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(d.isActive ? 'Activo' : 'Inactivo',
                style: TextStyle(fontSize: 10, fontFamily: 'Arimo',
                    fontWeight: FontWeight.w600,
                    color: d.isActive
                        ? const Color(0xFF16A34A)
                        : const Color(0xFF9CA3AF))),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right_rounded,
              color: Color(0xFFD1D5DB), size: 18),
        ]),
      ),
    );
  }

  Widget _buildPingAction() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 38, height: 38,
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 20)),
          const SizedBox(width: 12),
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Dispensación manual',
                style: TextStyle(color: Colors.white, fontSize: 14,
                    fontFamily: 'Arimo', fontWeight: FontWeight.w700)),
            Text('Acción inmediata',
                style: TextStyle(color: Colors.white54, fontSize: 12,
                    fontFamily: 'Arimo')),
          ]),
        ]),
        const SizedBox(height: 12),
        const Text('Envía un ping al dispositivo para activar una dispensación.',
            style: TextStyle(color: Colors.white54, fontSize: 12,
                fontFamily: 'Arimo', height: 1.4)),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity, height: 44,
          child: ElevatedButton.icon(
            onPressed: _pinging ? null : _ping,
            style: ElevatedButton.styleFrom(
                backgroundColor: _teal,
                disabledBackgroundColor: Colors.white12,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            icon: _pinging
                ? const SizedBox(width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2,
                        color: Colors.white))
                : const Icon(Icons.play_arrow_rounded,
                    color: Colors.white, size: 20),
            label: const Text('Dispensar ahora',
                style: TextStyle(color: Colors.white, fontSize: 14,
                    fontFamily: 'Arimo', fontWeight: FontWeight.w600)),
          ),
        ),
      ]),
    );
  }

  Widget _buildDeviceDetailsCard() {
    final dev = _device!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF0F0F0)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(children: [
        _detailRow(Icons.qr_code_rounded, 'Número de serie', dev.serialNumber),
        const Divider(height: 16, color: Color(0xFFF0F0F0)),
        _detailRow(Icons.access_time_rounded, 'Último contacto',
            dev.formattedLastSeen),
      ]),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(children: [
      Container(width: 34, height: 34,
          decoration: BoxDecoration(
              color: _blue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: _blue, size: 16)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 10,
            color: Color(0xFF9CA3AF), fontFamily: 'Arimo',
            fontWeight: FontWeight.w500)),
        const SizedBox(height: 1),
        Text(value, style: const TextStyle(fontSize: 13,
            fontWeight: FontWeight.w600, fontFamily: 'Arimo',
            color: Color(0xFF1F2937))),
      ])),
    ]);
  }

  Widget _loadingCard({double height = 80}) {
    return Container(
      height: height, width: double.infinity,
      decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF0F0F0))),
      child: const Center(child: SizedBox(width: 22, height: 22,
          child: CircularProgressIndicator(strokeWidth: 2,
              color: Color(0xFF009688)))),
    );
  }

  Widget _errorCard(String msg, {required VoidCallback onRetry}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFFFFF5F5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFEE2E2))),
      child: Row(children: [
        const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(msg, style: const TextStyle(
            color: Color(0xFFEF4444), fontFamily: 'Arimo', fontSize: 12))),
        IconButton(onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded,
                color: Color(0xFFEF4444), size: 18),
            padding: EdgeInsets.zero, constraints: const BoxConstraints()),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom Sheet: detalle de dispensador
// ─────────────────────────────────────────────────────────────────────────────
class _DispensatorDetailSheet extends StatefulWidget {
  final Dispensator dispensator;
  final GetDispensatorDetail getDetail;

  const _DispensatorDetailSheet({
    required this.dispensator,
    required this.getDetail,
  });

  @override
  State<_DispensatorDetailSheet> createState() =>
      _DispensatorDetailSheetState();
}

class _DispensatorDetailSheetState extends State<_DispensatorDetailSheet> {
  static const _teal = Color(0xFF009688);

  DispensatorDetail? _detail;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final detail = await widget.getDetail.call(widget.dispensator.id);
      if (!mounted) return;
      setState(() { _detail = detail; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Handle
        Container(width: 40, height: 4,
            decoration: BoxDecoration(color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 16),
        Row(children: [
          Container(width: 42, height: 42,
              decoration: BoxDecoration(
                  color: _teal.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.grain, color: _teal, size: 22)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.dispensator.name,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
                    fontFamily: 'Arimo', color: Color(0xFF1F2937))),
            const Text('Detalle del dispensador',
                style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF),
                    fontFamily: 'Arimo')),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: widget.dispensator.isActive
                  ? const Color(0xFFDCFCE7)
                  : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(widget.dispensator.isActive ? 'Activo' : 'Inactivo',
                style: TextStyle(fontSize: 11, fontFamily: 'Arimo',
                    fontWeight: FontWeight.w600,
                    color: widget.dispensator.isActive
                        ? const Color(0xFF16A34A)
                        : const Color(0xFF9CA3AF))),
          ),
        ]),
        const SizedBox(height: 20),
        if (_loading)
          const Padding(padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(color: _teal, strokeWidth: 2))
        else if (_error != null)
          Padding(padding: const EdgeInsets.all(16),
              child: Text(_error!, style: const TextStyle(
                  color: Color(0xFFEF4444), fontFamily: 'Arimo', fontSize: 13)))
        else if (_detail != null)
          _buildDetail(_detail!),
      ]),
    );
  }

  Widget _buildDetail(DispensatorDetail d) {
    final pct = d.capacityPercent;
    final statusLabel = pct > 0.5
        ? 'ÓPTIMO'
        : pct > 0.1
            ? 'NORMAL'
            : 'BAJO';
    final statusColor = pct > 0.5
        ? const Color(0xFF16A34A)
        : pct > 0.1
            ? const Color(0xFFF59E0B)
            : const Color(0xFFEF4444);
    final statusBg = pct > 0.5
        ? const Color(0xFFDCFCE7)
        : pct > 0.1
            ? const Color(0xFFFEF3C7)
            : const Color(0xFFFEE2E2);

    return Column(children: [
      // Capacity donut
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Stack(alignment: Alignment.center, children: [
          SizedBox(width: 100, height: 100,
              child: CircularProgressIndicator(
                value: pct, strokeWidth: 8,
                backgroundColor: const Color(0xFFE5E7EB),
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                strokeCap: StrokeCap.round,
              )),
          Column(mainAxisSize: MainAxisSize.min, children: [
            Text('${(pct * 100).round()}%',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
                    fontFamily: 'Arimo', color: statusColor)),
            const Text('lleno', style: TextStyle(fontSize: 10,
                color: Color(0xFF9CA3AF), fontFamily: 'Arimo')),
          ]),
        ]),
        const SizedBox(width: 24),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _statItem('Actual', '${d.currentCapacity} g', _teal),
          const SizedBox(height: 8),
          _statItem('Máximo', '${d.maxCapacity} g', const Color(0xFF6B7280)),
          const SizedBox(height: 8),
          _statItem('Hoy', '${d.dailyTotal} g', const Color(0xFF2563EB)),
        ]),
      ]),
      const SizedBox(height: 20),
      // Next dispense
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB))),
        child: Row(children: [
          const Icon(Icons.schedule_outlined,
              size: 16, color: Color(0xFF6B7280)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Próxima dispensación',
                style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF),
                    fontFamily: 'Arimo', fontWeight: FontWeight.w500)),
            Text(d.formattedNextDispense,
                style: const TextStyle(fontSize: 13,
                    fontWeight: FontWeight.w600, fontFamily: 'Arimo',
                    color: Color(0xFF1F2937))),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: statusBg,
                borderRadius: BorderRadius.circular(20)),
            child: Text(statusLabel,
                style: TextStyle(fontSize: 10, fontFamily: 'Arimo',
                    fontWeight: FontWeight.w700, color: statusColor)),
          ),
        ]),
      ),
    ]);
  }

  Widget _statItem(String label, String value, Color color) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 10,
          color: Color(0xFF9CA3AF), fontFamily: 'Arimo')),
      Text(value, style: TextStyle(fontSize: 15,
          fontWeight: FontWeight.w700, fontFamily: 'Arimo', color: color)),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Diálogo: Editar Dispositivo (PATCH /api/v1/device)
// ─────────────────────────────────────────────────────────────────────────────
class _EditDeviceDialog extends StatefulWidget {
  final DeviceInfo device;
  final UpdateDevice updateDevice;

  const _EditDeviceDialog({required this.device, required this.updateDevice});

  @override
  State<_EditDeviceDialog> createState() => _EditDeviceDialogState();
}

class _EditDeviceDialogState extends State<_EditDeviceDialog> {
  static const _teal = Color(0xFF009688);
  late final TextEditingController _nameCtrl;
  late final TextEditingController _locationCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.device.name);
    _locationCtrl = TextEditingController(text: widget.device.location);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final loc = _locationCtrl.text.trim();
    if (name.isEmpty) return;

    setState(() => _saving = true);
    try {
      final updated = await widget.updateDevice.call(
          name: name, location: loc);
      if (!mounted) return;
      Navigator.pop(context, updated);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      final msg = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: 'Arimo')),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Editar Dispositivo',
          style: TextStyle(fontFamily: 'Arimo',
              fontWeight: FontWeight.w700, fontSize: 17)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        _field(ctrl: _nameCtrl, label: 'Nombre', hint: 'Dispositivo Principal'),
        const SizedBox(height: 12),
        _field(ctrl: _locationCtrl, label: 'Ubicación', hint: 'Sala principal'),
      ]),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancelar',
              style: TextStyle(color: Color(0xFF9CA3AF), fontFamily: 'Arimo')),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          style: ElevatedButton.styleFrom(
              backgroundColor: _teal, elevation: 0,
              shape: const StadiumBorder()),
          child: _saving
              ? const SizedBox(width: 16, height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2,
                      color: Colors.white))
              : const Text('Guardar',
                  style: TextStyle(fontFamily: 'Arimo', color: Colors.white)),
        ),
      ],
    );
  }

  Widget _field({
    required TextEditingController ctrl,
    required String label,
    required String hint,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12,
          fontWeight: FontWeight.w600, fontFamily: 'Arimo',
          color: Color(0xFF374151))),
      const SizedBox(height: 6),
      TextField(
        controller: ctrl,
        style: const TextStyle(fontFamily: 'Arimo', fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFFD1D5DB), fontFamily: 'Arimo'),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _teal, width: 1.6)),
        ),
      ),
    ]);
  }
}
