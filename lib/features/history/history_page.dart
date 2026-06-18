import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String _selectedTab = 'All Events';

  static const _teal = Color(0xFF009688);
  static const _tabs = ['All Events', 'Dispenses', 'Errors', 'Maintenance'];

  final List<Map<String, dynamic>> _events = [
    {
      'date': 'Oct 26, 2023',
      'title': 'Dispensación Silo A',
      'subtitle': '2.5 kg dispensado',
      'time': '14:22 · ZONA 402',
      'status': 'success',
      'icon': Icons.grain,
    },
    {
      'date': 'Oct 26, 2023',
      'title': 'Boquilla obstruida',
      'subtitle': 'Obstrucción detectada',
      'time': '11:05 · ROOM 108',
      'status': 'error',
      'icon': Icons.warning_amber_rounded,
    },
    {
      'date': 'Oct 26, 2023',
      'title': 'Dispensación Silo B',
      'subtitle': '5.0 kg dispensado',
      'time': '09:45 · ZONA 312',
      'status': 'success',
      'icon': Icons.grain,
    },
    {
      'date': 'Oct 25, 2023',
      'title': 'Dispensación Silo A',
      'subtitle': '2.5 kg dispensado',
      'time': '22:15 · ZONA 402',
      'status': 'success',
      'icon': Icons.grain,
    },
    {
      'date': 'Oct 25, 2023',
      'title': 'Reabastecimiento',
      'subtitle': 'Cartucho #09 reemplazado',
      'time': '18:30 · CENTRAL HUB',
      'status': 'system',
      'icon': Icons.inventory_2_outlined,
    },
  ];

  List<Map<String, dynamic>> get _filtered {
    if (_selectedTab == 'All Events') return _events;
    final map = {
      'Dispenses': 'success',
      'Errors': 'error',
      'Maintenance': 'system',
    };
    return _events
        .where((e) => e['status'] == map[_selectedTab])
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final e in _filtered) {
      final d = e['date'] as String;
      grouped.putIfAbsent(d, () => []).add(e);
    }

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Row(
              children: [
                _avatar(),
                const SizedBox(width: 10),
                const Text(
                  'DispenXCore',
                  style: TextStyle(
                    fontSize: 17,
                    fontFamily: 'Arimo',
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.open_in_new_rounded,
                    size: 18, color: Color(0xFF9CA3AF)),
                const SizedBox(width: 10),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.notifications_outlined,
                      color: Color(0xFF374151), size: 18),
                ),
              ],
            ),
          ),

          // Weekly stats header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'WEEKLY CONSUMPTION',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                    fontFamily: 'Arimo',
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Trend Analysis',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Arimo',
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: '42.8 ',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Arimo',
                              color: _teal,
                            ),
                          ),
                          TextSpan(
                            text: 'UNITS',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Arimo',
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Mini bar chart
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _WeeklyChart(),
          ),

          const SizedBox(height: 16),

          // Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _tabs.map((tab) {
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
                      child: Text(
                        tab,
                        style: TextStyle(
                          color: selected
                              ? Colors.white
                              : const Color(0xFF6B7280),
                          fontSize: 12,
                          fontFamily: 'Arimo',
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Date label + events
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                for (final entry in grouped.entries) ...[
                  _buildDateHeader(entry.key),
                  const SizedBox(height: 8),
                  ...entry.value.map(_buildEventItem),
                  const SizedBox(height: 6),
                ],
                const SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.history_rounded,
                          size: 20, color: Colors.grey.shade300),
                      const SizedBox(height: 4),
                      Text(
                        'Loading older records...',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade400,
                          fontFamily: 'Arimo',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        color: _teal,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text(
          'JD',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontFamily: 'Arimo',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildDateHeader(String date) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        date,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF9CA3AF),
          fontFamily: 'Arimo',
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEventItem(Map<String, dynamic> e) {
    final status = e['status'] as String;
    final Color iconColor;
    switch (status) {
      case 'success':
        iconColor = const Color(0xFF16A34A);
      case 'error':
        iconColor = const Color(0xFFEF4444);
      default:
        iconColor = const Color(0xFF2563EB);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(e['icon'] as IconData, color: iconColor, size: 17),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e['title'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Arimo',
                    fontSize: 13,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  e['subtitle'] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    fontFamily: 'Arimo',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  e['time'] as String,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                    fontFamily: 'Arimo',
                  ),
                ),
              ],
            ),
          ),
          _statusBadge(status),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    final Color bg;
    final Color fg;
    final String label;
    switch (status) {
      case 'success':
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF16A34A);
        label = 'Success';
      case 'error':
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFEF4444);
        label = 'Error';
      default:
        bg = const Color(0xFFEFF6FF);
        fg = const Color(0xFF2563EB);
        label = 'System';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 10,
          fontFamily: 'Arimo',
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  const _WeeklyChart();

  @override
  Widget build(BuildContext context) {
    const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    const values = [0.4, 0.6, 0.5, 0.75, 0.85, 1.0, 0.3];
    const selectedIdx = 5; // SAT

    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (i) {
          final selected = i == selectedIdx;
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 28,
                height: 60 * values[i],
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF009688)
                      : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                days[i],
                style: TextStyle(
                  fontSize: 9,
                  fontFamily: 'Arimo',
                  fontWeight:
                      selected ? FontWeight.w700 : FontWeight.w400,
                  color: selected
                      ? const Color(0xFF009688)
                      : const Color(0xFF9CA3AF),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
