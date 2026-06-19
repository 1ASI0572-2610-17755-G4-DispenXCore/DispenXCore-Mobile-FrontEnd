import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/di/injector.dart';
import 'domain/entities/dispenser_event.dart';
import 'domain/usecases/get_dispenser_events.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  static const _teal = Color(0xFF009688);
  static const _dispensatorId = 1;

  // Tabs: label → trigger int filter (null = todos)
  static const _tabs = <String, int?>{
    'Todos': null,
    'Programado': 0,
    'Manual': 1,
    'Automático': 2,
  };

  String _selectedTab = 'Todos';
  List<DispenserEvent> _events = [];
  bool _isLoading = true;
  String? _error;

  late final GetDispenserEvents _getEvents;

  @override
  void initState() {
    super.initState();
    _getEvents = injector<GetDispenserEvents>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      final result = await _getEvents(_dispensatorId);
      // Sort descending by dispensedAt
      result.sort((a, b) => b.dispensedAt.compareTo(a.dispensedAt));
      if (!mounted) return;
      setState(() { _events = result; _isLoading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
        _isLoading = false;
      });
    }
  }

  List<DispenserEvent> get _filtered {
    final triggerFilter = _tabs[_selectedTab];
    if (triggerFilter == null) return _events;
    return _events.where((e) => e.trigger == triggerFilter).toList();
  }

  // Total grams per ISO weekday (1=Mon…7=Sun) for chart
  Map<int, int> get _weeklyTotals {
    final now = DateTime.now();
    final cutoff = now.subtract(const Duration(days: 7));
    final totals = <int, int>{for (var i = 1; i <= 7; i++) i: 0};
    for (final e in _events) {
      if (e.dispensedAt.isAfter(cutoff)) {
        totals[e.dispensedAt.weekday] =
            (totals[e.dispensedAt.weekday] ?? 0) + e.amountDispensed;
      }
    }
    return totals;
  }

  int get _weeklyTotal =>
      _weeklyTotals.values.fold(0, (sum, v) => sum + v);

  // Group filtered events by date label (descending — already sorted)
  Map<String, List<DispenserEvent>> get _grouped {
    final map = <String, List<DispenserEvent>>{};
    for (final e in _filtered) {
      final label = DateFormat('dd MMM yyyy').format(e.dispensedAt.toLocal());
      map.putIfAbsent(label, () => []).add(e);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Row(children: [
              _avatar(),
              const SizedBox(width: 10),
              const Text('DispenXCore',
                  style: TextStyle(fontSize: 17, fontFamily: 'Arimo',
                      fontWeight: FontWeight.w700, color: Color(0xFF1F2937))),
              const Spacer(),
              GestureDetector(
                onTap: _load,
                child: const Icon(Icons.refresh_rounded,
                    size: 18, color: Color(0xFF9CA3AF)),
              ),
              const SizedBox(width: 10),
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.notifications_outlined,
                    color: Color(0xFF374151), size: 18),
              ),
            ]),
          ),

          // Weekly stats header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('CONSUMO SEMANAL',
                  style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF),
                      fontFamily: 'Arimo', fontWeight: FontWeight.w600,
                      letterSpacing: 0.8)),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Análisis de Tendencia',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
                          fontFamily: 'Arimo', color: Color(0xFF1F2937))),
                  _isLoading
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2,
                              color: _teal))
                      : RichText(
                          text: TextSpan(children: [
                            TextSpan(
                              text: '${(_weeklyTotal / 1000).toStringAsFixed(1)} ',
                              style: const TextStyle(fontSize: 22,
                                  fontWeight: FontWeight.w700, fontFamily: 'Arimo',
                                  color: _teal),
                            ),
                            const TextSpan(text: 'KG',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                                  fontFamily: 'Arimo', color: Color(0xFF9CA3AF)),
                            ),
                          ]),
                        ),
                ],
              ),
            ]),
          ),

          const SizedBox(height: 14),

          // Weekly bar chart
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _WeeklyChart(totals: _weeklyTotals),
          ),

          const SizedBox(height: 16),

          // Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _tabs.keys.map((tab) {
                  final selected = tab == _selectedTab;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedTab = tab),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? _teal : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(tab,
                          style: TextStyle(
                            color: selected ? Colors.white
                                : const Color(0xFF6B7280),
                            fontSize: 12, fontFamily: 'Arimo',
                            fontWeight: selected ? FontWeight.w600
                                : FontWeight.w400,
                          )),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Event list
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: _teal));
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.cloud_off_rounded, size: 48,
                color: Color(0xFFD1D5DB)),
            const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF6B7280),
                    fontFamily: 'Arimo')),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar',
                  style: TextStyle(fontFamily: 'Arimo')),
              style: ElevatedButton.styleFrom(backgroundColor: _teal,
                  foregroundColor: Colors.white),
            ),
          ]),
        ),
      );
    }

    final grouped = _grouped;

    if (grouped.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.history_rounded, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            _selectedTab == 'Todos'
                ? 'Sin eventos registrados'
                : 'Sin eventos de tipo "$_selectedTab"',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade400,
                fontFamily: 'Arimo'),
          ),
        ]),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: _teal,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          for (final entry in grouped.entries) ...[
            _buildDateHeader(entry.key),
            const SizedBox(height: 8),
            ...entry.value.map(_buildEventItem),
            const SizedBox(height: 6),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDateHeader(String date) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(date,
            style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF),
                fontFamily: 'Arimo', fontWeight: FontWeight.w500)),
      );

  Widget _buildEventItem(DispenserEvent e) {
    final (IconData icon, Color color, String badge, String triggerLabel) =
        _triggerStyle(e.trigger);

    final timeLabel = DateFormat('HH:mm').format(e.dispensedAt.toLocal());
    final supplyLabel = _supplyLabel(e.supplyType);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 17),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${e.amountDispensed} g dispensado',
                style: const TextStyle(fontWeight: FontWeight.w600,
                    fontFamily: 'Arimo', fontSize: 13,
                    color: Color(0xFF1F2937))),
            const SizedBox(height: 2),
            Text(supplyLabel,
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280),
                    fontFamily: 'Arimo')),
            const SizedBox(height: 2),
            Text('$timeLabel · $triggerLabel',
                style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF),
                    fontFamily: 'Arimo')),
          ]),
        ),
        _statusBadge(badge, color),
      ]),
    );
  }

  (IconData, Color, String, String) _triggerStyle(int trigger) {
    return switch (trigger) {
      1 => (Icons.touch_app_rounded, const Color(0xFF2563EB), 'Manual', 'Manual'),
      2 => (Icons.auto_mode_rounded, const Color(0xFF009688), 'Auto', 'Automático'),
      _ => (Icons.schedule_rounded, const Color(0xFF16A34A), 'Progr.', 'Programado'),
    };
  }

  String _supplyLabel(int type) => switch (type) {
    1 => 'Tipo Reducido',
    2 => 'Tipo Completo',
    3 => 'Tipo Doble',
    4 => 'Tipo Personalizado',
    _ => 'Tipo Estándar',
  };

  Widget _statusBadge(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20)),
        child: Text(label,
            style: TextStyle(color: color, fontSize: 10, fontFamily: 'Arimo',
                fontWeight: FontWeight.w700)),
      );

  Widget _avatar() => Container(
        width: 36, height: 36,
        decoration: const BoxDecoration(color: _teal, shape: BoxShape.circle),
        child: const Center(
          child: Text('DX',
              style: TextStyle(color: Colors.white, fontSize: 12,
                  fontFamily: 'Arimo', fontWeight: FontWeight.w700)),
        ),
      );
}

// ─── Weekly Bar Chart ───

class _WeeklyChart extends StatelessWidget {
  final Map<int, int> totals;
  const _WeeklyChart({required this.totals});

  @override
  Widget build(BuildContext context) {
    const days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    final maxVal = totals.values.fold(0, (m, v) => v > m ? v : m);
    final today = DateTime.now().weekday; // 1=Mon…7=Sun

    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (i) {
          final weekday = i + 1;
          final val = totals[weekday] ?? 0;
          final fraction = maxVal > 0 ? val / maxVal : 0.0;
          final isToday = weekday == today;

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 28,
                height: (60 * fraction).clamp(4.0, 60.0),
                decoration: BoxDecoration(
                  color: isToday ? const Color(0xFF009688)
                      : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 5),
              Text(days[i],
                  style: TextStyle(fontSize: 9, fontFamily: 'Arimo',
                    fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                    color: isToday ? const Color(0xFF009688)
                        : const Color(0xFF9CA3AF),
                  )),
            ],
          );
        }),
      ),
    );
  }
}
