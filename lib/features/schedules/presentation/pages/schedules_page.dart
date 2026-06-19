import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/di/injector.dart';
import '../../domain/entities/schedule.dart';
import '../../domain/usecases/schedule_usecases.dart';

class SchedulesPage extends StatefulWidget {
  const SchedulesPage({super.key});

  @override
  State<SchedulesPage> createState() => _SchedulesPageState();
}

class _SchedulesPageState extends State<SchedulesPage> {
  static const _teal = Color(0xFF009688);
  static const _dispensatorId = 1;

  late final GetSchedules _getSchedules;
  late final CreateSchedule _createSchedule;
  late final UpdateSchedule _updateSchedule;
  late final DeleteSchedule _deleteSchedule;
  late final ToggleSchedule _toggleSchedule;

  List<Schedule> _schedules = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _getSchedules = injector<GetSchedules>();
    _createSchedule = injector<CreateSchedule>();
    _updateSchedule = injector<UpdateSchedule>();
    _deleteSchedule = injector<DeleteSchedule>();
    _toggleSchedule = injector<ToggleSchedule>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      final result = await _getSchedules(_dispensatorId);
      if (!mounted) return;
      setState(() { _schedules = result; _isLoading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
        _isLoading = false;
      });
    }
  }

  Future<void> _onToggle(Schedule s) async {
    // Optimistic update
    setState(() {
      final idx = _schedules.indexWhere((x) => x.id == s.id);
      if (idx != -1) _schedules[idx] = s.copyWith(isActive: !s.isActive);
    });
    try {
      await _toggleSchedule(s.id);
    } catch (e) {
      // Revert on error
      setState(() {
        final idx = _schedules.indexWhere((x) => x.id == s.id);
        if (idx != -1) _schedules[idx] = s;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cambiar estado: $e')),
        );
      }
    }
  }

  Future<void> _onDelete(Schedule s) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar horario',
            style: TextStyle(fontFamily: 'Arimo', fontWeight: FontWeight.w700)),
        content: Text('¿Eliminar "${s.name}"?',
            style: const TextStyle(fontFamily: 'Arimo')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar',
                style: TextStyle(color: Color(0xFF6B7280), fontFamily: 'Arimo')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar',
                style: TextStyle(color: Colors.red, fontFamily: 'Arimo')),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _deleteSchedule(s.id);
      setState(() => _schedules.removeWhere((x) => x.id == s.id));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _openForm({Schedule? editing}) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ScheduleFormSheet(
        existing: editing,
        dispensatorId: _dispensatorId,
        createSchedule: _createSchedule,
        updateSchedule: _updateSchedule,
      ),
    );
    if (result == true) await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Horarios',
            style: TextStyle(fontFamily: 'Arimo', fontWeight: FontWeight.w700)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F2937),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE5E7EB)),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        backgroundColor: _teal,
        child: const Icon(Icons.add_rounded, color: Colors.white),
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
                const Icon(Icons.cloud_off_rounded, size: 48, color: Color(0xFFD1D5DB)),
                const SizedBox(height: 12),
                Text(_error!, textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFF6B7280), fontFamily: 'Arimo')),
                const SizedBox(height: 20),
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
          ),
        ],
      );
    }
    if (_schedules.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.28),
          const Center(
            child: Column(children: [
              Icon(Icons.schedule_outlined, size: 64, color: Color(0xFFD1D5DB)),
              SizedBox(height: 16),
              Text('Sin horarios configurados',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                      fontFamily: 'Arimo', color: Color(0xFF1F2937))),
              SizedBox(height: 6),
              Text('Toca + para agregar un nuevo horario.',
                  style: TextStyle(color: Color(0xFF9CA3AF), fontFamily: 'Arimo')),
            ]),
          ),
        ],
      );
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _schedules.length,
      itemBuilder: (_, i) => _ScheduleCard(
        schedule: _schedules[i],
        onToggle: () => _onToggle(_schedules[i]),
        onEdit: () => _openForm(editing: _schedules[i]),
        onDelete: () => _onDelete(_schedules[i]),
      ),
    );
  }
}

// ─────────────── Schedule Card ───────────────

class _ScheduleCard extends StatelessWidget {
  final Schedule schedule;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ScheduleCard({
    required this.schedule,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  static const _dayLabels = {1: 'L', 2: 'M', 3: 'X', 4: 'J', 5: 'V', 6: 'S', 7: 'D'};
  static const _supplyLabels = {
    0: 'Estándar', 1: 'Reducido', 2: 'Completo', 3: 'Doble', 4: 'Personalizado',
  };

  String get _timeDisplay {
    final parts = schedule.scheduledTime.split(':');
    if (parts.length < 2) return schedule.scheduledTime;
    return '${parts[0]}:${parts[1]}';
  }

  @override
  Widget build(BuildContext context) {
    final active = schedule.isActive;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header row
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 0),
          child: Row(children: [
            Expanded(
              child: Text(schedule.name,
                  style: const TextStyle(fontFamily: 'Arimo',
                      fontWeight: FontWeight.w700, fontSize: 15,
                      color: Color(0xFF1F2937))),
            ),
            Switch(
              value: active,
              onChanged: (_) => onToggle(),
              activeThumbColor: const Color(0xFF009688),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ]),
        ),
        // Body
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 6),
            Row(children: [
              const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF9CA3AF)),
              const SizedBox(width: 4),
              Text(_timeDisplay,
                  style: const TextStyle(fontFamily: 'Arimo', fontSize: 13,
                      color: Color(0xFF374151), fontWeight: FontWeight.w600)),
              const SizedBox(width: 12),
              const Icon(Icons.grain, size: 14, color: Color(0xFF9CA3AF)),
              const SizedBox(width: 4),
              Text('${schedule.amount} g',
                  style: const TextStyle(fontFamily: 'Arimo', fontSize: 13,
                      color: Color(0xFF374151))),
              const SizedBox(width: 12),
              Text(_supplyLabels[schedule.supplyType] ?? 'Tipo ${schedule.supplyType}',
                  style: const TextStyle(fontFamily: 'Arimo', fontSize: 12,
                      color: Color(0xFF6B7280))),
            ]),
            const SizedBox(height: 8),
            // Day chips
            Row(children: [
              for (int d = 1; d <= 7; d++) ...[
                _DayChip(
                  label: _dayLabels[d]!,
                  active: schedule.frequencyDays.contains(d),
                ),
                if (d < 7) const SizedBox(width: 4),
              ],
              if (schedule.smartRefill) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Auto-recarga',
                      style: TextStyle(fontSize: 10, color: Color(0xFF2563EB),
                          fontFamily: 'Arimo', fontWeight: FontWeight.w600)),
                ),
              ],
            ]),
            const SizedBox(height: 10),
          ]),
        ),
        // Actions
        const Divider(height: 1, color: Color(0xFFF0F0F0)),
        Row(children: [
          Expanded(
            child: TextButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: const Text('Editar',
                  style: TextStyle(fontFamily: 'Arimo', fontSize: 13)),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF374151)),
            ),
          ),
          Container(width: 1, height: 36, color: const Color(0xFFF0F0F0)),
          Expanded(
            child: TextButton.icon(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline_rounded, size: 16),
              label: const Text('Eliminar',
                  style: TextStyle(fontFamily: 'Arimo', fontSize: 13)),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
          ),
        ]),
      ]),
    );
  }
}

class _DayChip extends StatelessWidget {
  final String label;
  final bool active;
  const _DayChip({required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26, height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF009688) : const Color(0xFFF3F4F6),
        shape: BoxShape.circle,
      ),
      child: Text(label,
          style: TextStyle(
            fontSize: 10,
            fontFamily: 'Arimo',
            fontWeight: FontWeight.w700,
            color: active ? Colors.white : const Color(0xFF9CA3AF),
          )),
    );
  }
}

// ─────────────── Form Bottom Sheet ───────────────

class _ScheduleFormSheet extends StatefulWidget {
  final Schedule? existing;
  final int dispensatorId;
  final CreateSchedule createSchedule;
  final UpdateSchedule updateSchedule;

  const _ScheduleFormSheet({
    this.existing,
    required this.dispensatorId,
    required this.createSchedule,
    required this.updateSchedule,
  });

  @override
  State<_ScheduleFormSheet> createState() => _ScheduleFormSheetState();
}

class _ScheduleFormSheetState extends State<_ScheduleFormSheet> {
  static const _teal = Color(0xFF009688);

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _amountCtrl;

  late TimeOfDay _time;
  late Set<int> _days;
  late int _supplyType;
  late bool _smartRefill;
  late bool _isActive;
  bool _saving = false;

  static const _supplyOptions = {
    0: 'Estándar', 1: 'Reducido', 2: 'Completo', 3: 'Doble', 4: 'Personalizado',
  };
  static const _dayLabels = {1: 'L', 2: 'M', 3: 'X', 4: 'J', 5: 'V', 6: 'S', 7: 'D'};

  @override
  void initState() {
    super.initState();
    final s = widget.existing;
    _nameCtrl = TextEditingController(text: s?.name ?? '');
    _amountCtrl = TextEditingController(text: s != null ? '${s.amount}' : '');
    _days = Set<int>.from(s?.frequencyDays ?? []);
    _supplyType = s?.supplyType ?? 0;
    _smartRefill = s?.smartRefill ?? false;
    _isActive = s?.isActive ?? true;

    if (s != null) {
      final parts = s.scheduledTime.split(':');
      _time = TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 7,
        minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
      );
    } else {
      _time = const TimeOfDay(hour: 7, minute: 0);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  String get _timeString {
    final h = _time.hour.toString().padLeft(2, '0');
    final m = _time.minute.toString().padLeft(2, '0');
    return '$h:$m:00';
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_days.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos un día.')),
      );
      return;
    }
    setState(() => _saving = true);

    final s = Schedule(
      id: widget.existing?.id ?? 0,
      dispensatorId: widget.dispensatorId,
      name: _nameCtrl.text.trim(),
      supplyType: _supplyType,
      amount: int.parse(_amountCtrl.text.trim()),
      scheduledTime: _timeString,
      frequencyDays: _days.toList()..sort(),
      smartRefill: _smartRefill,
      isActive: _isActive,
    );

    try {
      if (widget.existing == null) {
        await widget.createSchedule(s);
      } else {
        await widget.updateSchedule(widget.existing!.id, s);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst(RegExp(r'^Exception:\s*'), ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(children: [
          // Handle
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(children: [
              Text(isEdit ? 'Editar horario' : 'Nuevo horario',
                  style: const TextStyle(fontFamily: 'Arimo',
                      fontWeight: FontWeight.w700, fontSize: 18,
                      color: Color(0xFF1F2937))),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context, false),
                icon: const Icon(Icons.close_rounded, color: Color(0xFF6B7280)),
              ),
            ]),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(controller: controller, padding: const EdgeInsets.all(20),
              children: [
                Form(key: _formKey, child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    _label('Nombre'),
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: _inputDeco('ej. Comida-1'),
                      style: const TextStyle(fontFamily: 'Arimo'),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    // Amount
                    _label('Cantidad (gramos)'),
                    TextFormField(
                      controller: _amountCtrl,
                      decoration: _inputDeco('ej. 200'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(fontFamily: 'Arimo'),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Campo requerido';
                        final n = int.tryParse(v);
                        if (n == null || n <= 0) return 'Ingresa un valor válido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Time
                    _label('Hora de dispensación'),
                    InkWell(
                      onTap: _pickTime,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFD1D5DB)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(children: [
                          const Icon(Icons.access_time_rounded,
                              size: 18, color: Color(0xFF9CA3AF)),
                          const SizedBox(width: 10),
                          Text(_time.format(context),
                              style: const TextStyle(fontFamily: 'Arimo',
                                  fontSize: 15, color: Color(0xFF1F2937))),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Days
                    _label('Días de la semana'),
                    const SizedBox(height: 8),
                    Row(children: [
                      for (int d = 1; d <= 7; d++) ...[
                        _DayToggle(
                          label: _dayLabels[d]!,
                          selected: _days.contains(d),
                          onTap: () => setState(() {
                            if (_days.contains(d)) {
                              _days.remove(d);
                            } else {
                              _days.add(d);
                            }
                          }),
                        ),
                        if (d < 7) const SizedBox(width: 6),
                      ],
                    ]),
                    const SizedBox(height: 16),
                    // Supply type
                    _label('Tipo de suministro'),
                    DropdownButtonFormField<int>(
                      initialValue: _supplyType,
                      decoration: _inputDeco(null),
                      style: const TextStyle(fontFamily: 'Arimo',
                          color: Color(0xFF1F2937), fontSize: 14),
                      items: _supplyOptions.entries
                          .map((e) => DropdownMenuItem(
                              value: e.key,
                              child: Text(e.value,
                                  style: const TextStyle(fontFamily: 'Arimo'))))
                          .toList(),
                      onChanged: (v) => setState(() => _supplyType = v!),
                    ),
                    const SizedBox(height: 8),
                    // Toggles
                    _SwitchRow(
                      label: 'Auto-recarga inteligente',
                      value: _smartRefill,
                      onChanged: (v) => setState(() => _smartRefill = v),
                    ),
                    _SwitchRow(
                      label: 'Horario activo',
                      value: _isActive,
                      onChanged: (v) => setState(() => _isActive = v),
                    ),
                    const SizedBox(height: 24),
                    // Save button
                    SizedBox(
                      width: double.infinity, height: 50,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _teal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _saving
                            ? const SizedBox(width: 20, height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : Text(isEdit ? 'Guardar cambios' : 'Crear horario',
                                style: const TextStyle(fontFamily: 'Arimo',
                                    fontWeight: FontWeight.w700, fontSize: 15)),
                      ),
                    ),
                  ],
                )),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: const TextStyle(fontFamily: 'Arimo', fontSize: 13,
                fontWeight: FontWeight.w600, color: Color(0xFF374151))),
      );

  InputDecoration _inputDeco(String? hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontFamily: 'Arimo'),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF009688), width: 1.5)),
      );
}

class _DayToggle extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _DayToggle({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 36, height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF009688) : const Color(0xFFF3F4F6),
          shape: BoxShape.circle,
          border: selected ? null : Border.all(color: const Color(0xFFD1D5DB)),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 12, fontFamily: 'Arimo', fontWeight: FontWeight.w700,
              color: selected ? Colors.white : const Color(0xFF6B7280),
            )),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchRow({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: Text(label,
          style: const TextStyle(fontFamily: 'Arimo', fontSize: 14,
              color: Color(0xFF1F2937)))),
      Switch(value: value, onChanged: onChanged, activeThumbColor: const Color(0xFF009688)),
    ]);
  }
}
