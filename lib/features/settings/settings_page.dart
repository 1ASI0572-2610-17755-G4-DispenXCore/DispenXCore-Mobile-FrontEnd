import 'package:dispenxcore_frontend/app/router/app_router.dart';
import 'package:dispenxcore_frontend/core/di/injector.dart';
import 'package:dispenxcore_frontend/features/auth/domain/entities/user.dart';
import 'package:dispenxcore_frontend/features/users/domain/usecases/change_password.dart';
import 'package:dispenxcore_frontend/features/users/domain/usecases/get_current_user.dart';
import 'package:dispenxcore_frontend/features/users/domain/usecases/update_user.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SettingsPage
// ─────────────────────────────────────────────────────────────────────────────
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _stockAlert = true;
  bool _deliveryAlert = true;

  User? _user;
  bool _isLoadingUser = true;
  String? _loadError;
  String? _edgeIp;

  static const _teal = Color(0xFF009688);

  late final GetCurrentUser _getCurrentUser;
  late final UpdateUser _updateUser;
  late final ChangePassword _changePassword;

  @override
  void initState() {
    super.initState();
    _getCurrentUser = injector<GetCurrentUser>();
    _updateUser = injector<UpdateUser>();
    _changePassword = injector<ChangePassword>();
    // Espera al primer frame para garantizar que el widget esté montado
    // antes de comenzar cualquier operación asíncrona.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadUser();
        _loadEdgeIp();
      }
    });
  }

  Future<void> _loadUser() async {
    if (!mounted) return;
    setState(() { _isLoadingUser = true; _loadError = null; });
    try {
      final user = await _getCurrentUser.call();
      if (!mounted) return;
      setState(() { _user = user; _isLoadingUser = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
        _isLoadingUser = false;
      });
    }
  }

  Future<void> _loadEdgeIp() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _edgeIp = prefs.getString('edge_ip') ?? 'localhost';
    });
  }

  Future<void> _showEdgeIpDialog() async {
    final prefs = await SharedPreferences.getInstance();
    final currentIp = prefs.getString('edge_ip') ?? 'localhost';
    final ctrl = TextEditingController(text: currentIp);
    final formKey = GlobalKey<FormState>();

    if (!mounted) return;

    final updated = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Configurar Servidor Edge',
            style: TextStyle(fontFamily: 'Arimo', fontWeight: FontWeight.w700)),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Ingrese la IP local del Servidor Edge (Flask):',
                  style: TextStyle(fontFamily: 'Arimo', fontSize: 13, color: Color(0xFF6B7280))),
              const SizedBox(height: 12),
              TextFormField(
                controller: ctrl,
                style: const TextStyle(fontFamily: 'Arimo', fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'ej. 192.168.1.100',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _teal, width: 1.6),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'La IP es requerida';
                  final regex = RegExp(r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$');
                  if (!regex.hasMatch(v.trim()) && v.trim() != 'localhost') {
                    return 'Ingrese una dirección IP válida';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Color(0xFF6B7280), fontFamily: 'Arimo')),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx, ctrl.text.trim());
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _teal,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Guardar', style: TextStyle(color: Colors.white, fontFamily: 'Arimo')),
          ),
        ],
      ),
    );

    if (updated != null && mounted) {
      await prefs.setString('edge_ip', updated);
      setState(() {
        _edgeIp = updated;
      });
      _snack('IP del Servidor Edge guardada', success: true);
    }
  }

  String get _initials {
    final f = (_user?.firstName.isNotEmpty == true) ? _user!.firstName[0] : '';
    final l = (_user?.lastName.isNotEmpty == true) ? _user!.lastName[0] : '';
    return '${f.toUpperCase()}${l.toUpperCase()}';
  }

  String get _fullName =>
      _user != null ? '${_user!.firstName} ${_user!.lastName}'.trim() : '—';

  void _snack(String msg, {required bool success}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'Arimo')),
      backgroundColor: success ? _teal : Colors.red.shade600,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  // Cada diálogo es su propia StatefulWidget → tiene su propio dispose()
  // y sus propios TextEditingControllers. Esto elimina el _dependents.isEmpty.
  Future<void> _showEditProfileDialog() async {
    if (_user == null || !mounted) return;
    final updated = await showDialog<User>(
      context: context,
      builder: (ctx) => _EditProfileDialog(
        user: _user!,
        updateUser: _updateUser,
      ),
    );
    if (updated != null && mounted) {
      setState(() => _user = updated);
      _snack('Perfil actualizado', success: true);
    }
  }

  Future<void> _showChangePasswordDialog() async {
    if (_user == null || !mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => _ChangePasswordDialog(
        userId: _user!.id,
        changePassword: _changePassword,
      ),
    );
    if (ok == true && mounted) {
      _snack('Contraseña actualizada', success: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        children: [
          // ── Top bar ──────────────────────────────────────────
          Row(children: [
            _smallAvatar(),
            const SizedBox(width: 10),
            const Text('DispenXCore',
                style: TextStyle(fontSize: 17, fontFamily: 'Arimo',
                    fontWeight: FontWeight.w700, color: Color(0xFF1F2937))),
            const Spacer(),
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.notifications_outlined,
                  color: Color(0xFF374151), size: 18),
            ),
          ]),

          const SizedBox(height: 20),
          _buildProfileCard(),
          const SizedBox(height: 24),

          const Text('Configuración',
              style: TextStyle(fontSize: 22, fontFamily: 'Arimo',
                  fontWeight: FontWeight.w700, color: Color(0xFF1F2937))),
          const SizedBox(height: 4),
          const Text('Gestiona tus dispositivos y preferencias de cuenta.',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 13,
                  fontFamily: 'Arimo', height: 1.4)),
          const SizedBox(height: 24),

          // ── Notificaciones ──────────────────────────────────
          _sectionLabel('PREFERENCIAS DE NOTIFICACIÓN'),
          const SizedBox(height: 10),
          _switchTile(
            icon: Icons.inventory_2_outlined, title: 'Stock Bajo',
            subtitle: 'Avisar cuando quede < 10%',
            value: _stockAlert, onChanged: (v) => setState(() => _stockAlert = v),
          ),
          _switchTile(
            icon: Icons.swap_horiz_rounded, title: 'Dispensación',
            subtitle: 'Confirmación de entrega',
            value: _deliveryAlert, onChanged: (v) => setState(() => _deliveryAlert = v),
          ),
          const SizedBox(height: 20),

          // ── Red ─────────────────────────────────────────────
          _sectionLabel('CONFIGURACIÓN DE RED'),
          const SizedBox(height: 10),
          _navTile(icon: Icons.wifi_rounded, title: 'Red Wi-Fi',
              subtitle: 'Conectado: DispenX_Main_5G', onTap: () {}),
          _navTile(icon: Icons.lan_outlined, title: 'IP del Servidor Edge',
              subtitle: _edgeIp ?? 'No configurado', onTap: _showEdgeIpDialog),
          _navTile(icon: Icons.hub_outlined, title: 'Protocolo MQTT',
              subtitle: 'Cloud Integration Active', onTap: () {}),
          const SizedBox(height: 20),

          // ── Cuenta ──────────────────────────────────────────
          _sectionLabel('AJUSTES DE CUENTA'),
          const SizedBox(height: 10),
          _navTile(icon: Icons.person_outline_rounded, title: 'Editar Perfil',
              subtitle: '', onTap: _showEditProfileDialog),
          _navTile(icon: Icons.lock_outline_rounded, title: 'Cambiar Contraseña',
              subtitle: '', onTap: _showChangePasswordDialog),
          _navTile(icon: Icons.help_outline_rounded, title: 'Centro de Ayuda',
              subtitle: '', onTap: () {}),
          const SizedBox(height: 28),

          // ── Logout ──────────────────────────────────────────
          SizedBox(
            width: double.infinity, height: 52,
            child: OutlinedButton.icon(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                if (!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                    context, AppRouter.login, (route) => false);
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFFEE2E2)),
                backgroundColor: const Color(0xFFFFF5F5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.logout_rounded,
                  color: Color(0xFFEF4444), size: 18),
              label: const Text('Cerrar Sesión',
                  style: TextStyle(color: Color(0xFFEF4444), fontSize: 15,
                      fontFamily: 'Arimo', fontWeight: FontWeight.w600)),
            ),
          ),

          const SizedBox(height: 16),
          const Center(child: Text('Versión 2.4.1-rc (Build 890)',
              style: TextStyle(fontSize: 11,
                  color: Color(0xFF9CA3AF), fontFamily: 'Arimo'))),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ── Tarjeta de perfil ────────────────────────────────────────
  Widget _buildProfileCard() {
    if (_isLoadingUser) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: _cardDecoration(),
        child: const Row(children: [
          SizedBox(width: 20, height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: _teal)),
          SizedBox(width: 14),
          Text('Cargando perfil…',
              style: TextStyle(color: Color(0xFF9CA3AF),
                  fontFamily: 'Arimo', fontSize: 13)),
        ]),
      );
    }

    if (_loadError != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF5F5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFEE2E2)),
        ),
        child: Row(children: [
          const Icon(Icons.error_outline,
              color: Color(0xFFEF4444), size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(_loadError!,
              style: const TextStyle(color: Color(0xFFEF4444),
                  fontFamily: 'Arimo', fontSize: 12))),
          IconButton(
            onPressed: _loadUser,
            icon: const Icon(Icons.refresh_rounded,
                color: Color(0xFFEF4444), size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ]),
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Row(children: [
        Container(
          width: 58, height: 58,
          decoration: const BoxDecoration(color: _teal, shape: BoxShape.circle),
          clipBehavior: Clip.antiAlias,
          child: (_user?.photoUrl != null && _user!.photoUrl!.isNotEmpty)
              ? Image.network(_user!.photoUrl!, fit: BoxFit.cover,
                  errorBuilder: (ctx, err, st) => _initialsCenter(20))
              : _initialsCenter(20),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_fullName,
              style: const TextStyle(fontWeight: FontWeight.w700,
                  fontFamily: 'Arimo', fontSize: 16, color: Color(0xFF1F2937))),
          const SizedBox(height: 3),
          Text(_user?.email ?? '',
              style: const TextStyle(fontSize: 12,
                  color: Color(0xFF6B7280), fontFamily: 'Arimo')),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _teal.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _user?.role == Role.admin ? 'Administrador' : 'Usuario',
              style: const TextStyle(fontSize: 10, color: _teal,
                  fontFamily: 'Arimo', fontWeight: FontWeight.w700),
            ),
          ),
        ])),
        IconButton(
          onPressed: _showEditProfileDialog,
          icon: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.edit_outlined,
                size: 16, color: Color(0xFF374151)),
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ]),
    );
  }

  Widget _initialsCenter(double fontSize) => Center(
    child: Text(_initials.isNotEmpty ? _initials : '?',
        style: TextStyle(color: Colors.white, fontSize: fontSize,
            fontFamily: 'Arimo', fontWeight: FontWeight.w700)),
  );

  Widget _smallAvatar() => Container(
    width: 36, height: 36,
    decoration: const BoxDecoration(color: _teal, shape: BoxShape.circle),
    child: Center(
      child: Text(_initials.isNotEmpty ? _initials : '—',
          style: const TextStyle(color: Colors.white, fontSize: 12,
              fontFamily: 'Arimo', fontWeight: FontWeight.w700)),
    ),
  );

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: Colors.white, borderRadius: BorderRadius.circular(20),
    border: Border.all(color: const Color(0xFFF0F0F0)),
    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04),
        blurRadius: 10, offset: const Offset(0, 3))],
  );

  Widget _sectionLabel(String text) => Text(text, style: const TextStyle(
    fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'Arimo',
    color: Color(0xFF9CA3AF), letterSpacing: 0.7));

  Widget _switchTile({
    required IconData icon, required String title,
    required String subtitle, required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        Container(width: 36, height: 36,
            decoration: BoxDecoration(color: _teal.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: _teal, size: 18)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600,
              fontFamily: 'Arimo', fontSize: 13, color: Color(0xFF1F2937))),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 11,
              color: Color(0xFF9CA3AF), fontFamily: 'Arimo')),
        ])),
        Switch(
          value: value, onChanged: onChanged,
          activeTrackColor: const Color(0xFF16A34A),
          inactiveTrackColor: const Color(0xFFE5E7EB),
          activeThumbColor: Colors.white, inactiveThumbColor: Colors.white,
          trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
        ),
      ]),
    );
  }

  Widget _navTile({
    required IconData icon, required String title,
    required String subtitle, required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(width: 36, height: 36,
            decoration: BoxDecoration(color: _teal.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: _teal, size: 18)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600,
            fontFamily: 'Arimo', fontSize: 13, color: Color(0xFF1F2937))),
        subtitle: subtitle.isNotEmpty
            ? Text(subtitle, style: const TextStyle(fontSize: 11,
                color: Color(0xFF009688), fontFamily: 'Arimo'))
            : null,
        trailing: const Icon(Icons.chevron_right_rounded,
            color: Color(0xFFD1D5DB), size: 20),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Diálogo: Editar Perfil
// StatefulWidget propio → sus TextEditingControllers se disponen en dispose()
// sin depender del ciclo de vida del padre.
// ─────────────────────────────────────────────────────────────────────────────
class _EditProfileDialog extends StatefulWidget {
  final User user;
  final UpdateUser updateUser;

  const _EditProfileDialog({required this.user, required this.updateUser});

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  late final TextEditingController _firstCtrl;
  late final TextEditingController _lastCtrl;
  bool _saving = false;

  static const _teal = Color(0xFF009688);

  @override
  void initState() {
    super.initState();
    _firstCtrl = TextEditingController(text: widget.user.firstName);
    _lastCtrl = TextEditingController(text: widget.user.lastName);
  }

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final fn = _firstCtrl.text.trim();
    final ln = _lastCtrl.text.trim();
    if (fn.isEmpty || ln.isEmpty) return;

    setState(() => _saving = true);
    try {
      final updated = await widget.updateUser.call(
        widget.user.id,
        firstName: fn,
        lastName: ln,
        photoUrl: widget.user.photoUrl,
      );
      if (!mounted) return;
      // Devuelve el User actualizado al padre vía pop.
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
      title: const Text('Editar Perfil',
          style: TextStyle(fontFamily: 'Arimo',
              fontWeight: FontWeight.w700, fontSize: 17)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        _field(ctrl: _firstCtrl, label: 'Nombre', hint: 'John'),
        const SizedBox(height: 12),
        _field(ctrl: _lastCtrl, label: 'Apellido', hint: 'Doe'),
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
    bool obscure = false,
    VoidCallback? toggle,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12,
          fontWeight: FontWeight.w600, fontFamily: 'Arimo',
          color: Color(0xFF374151))),
      const SizedBox(height: 6),
      TextField(
        controller: ctrl, obscureText: obscure,
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
          suffixIcon: toggle != null
              ? IconButton(
                  onPressed: toggle,
                  icon: Icon(obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                      size: 18, color: const Color(0xFF9CA3AF)))
              : null,
        ),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Diálogo: Cambiar Contraseña
// ─────────────────────────────────────────────────────────────────────────────
class _ChangePasswordDialog extends StatefulWidget {
  final String userId;
  final ChangePassword changePassword;

  const _ChangePasswordDialog(
      {required this.userId, required this.changePassword});

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  late final TextEditingController _currentCtrl;
  late final TextEditingController _newCtrl;
  late final TextEditingController _confirmCtrl;
  bool _saving = false;
  bool _showCurrent = false;
  bool _showNew = false;

  static const _teal = Color(0xFF009688);

  @override
  void initState() {
    super.initState();
    _currentCtrl = TextEditingController();
    _newCtrl = TextEditingController();
    _confirmCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'Arimo')),
      backgroundColor: Colors.red.shade600,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  Future<void> _save() async {
    final cur = _currentCtrl.text.trim();
    final nw = _newCtrl.text.trim();
    final cf = _confirmCtrl.text.trim();

    if (cur.isEmpty || nw.isEmpty) return;
    if (nw != cf) { _showSnack('Las contraseñas no coinciden'); return; }
    if (nw.length < 6) { _showSnack('Mínimo 6 caracteres'); return; }

    setState(() => _saving = true);
    try {
      await widget.changePassword.call(
        widget.userId,
        currentPassword: cur,
        newPassword: nw,
      );
      if (!mounted) return;
      // Devuelve true al padre para mostrar el SnackBar de éxito.
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      final msg = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      _showSnack(msg);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Cambiar Contraseña',
          style: TextStyle(fontFamily: 'Arimo',
              fontWeight: FontWeight.w700, fontSize: 17)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        _field(
          ctrl: _currentCtrl, label: 'Contraseña actual', hint: '••••••••',
          obscure: !_showCurrent,
          toggle: () => setState(() => _showCurrent = !_showCurrent),
        ),
        const SizedBox(height: 12),
        _field(
          ctrl: _newCtrl, label: 'Nueva contraseña', hint: '••••••••',
          obscure: !_showNew,
          toggle: () => setState(() => _showNew = !_showNew),
        ),
        const SizedBox(height: 12),
        _field(
          ctrl: _confirmCtrl, label: 'Confirmar nueva', hint: '••••••••',
          obscure: !_showNew,
        ),
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
              : const Text('Cambiar',
                  style: TextStyle(fontFamily: 'Arimo', color: Colors.white)),
        ),
      ],
    );
  }

  Widget _field({
    required TextEditingController ctrl,
    required String label,
    required String hint,
    bool obscure = false,
    VoidCallback? toggle,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12,
          fontWeight: FontWeight.w600, fontFamily: 'Arimo',
          color: Color(0xFF374151))),
      const SizedBox(height: 6),
      TextField(
        controller: ctrl, obscureText: obscure,
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
          suffixIcon: toggle != null
              ? IconButton(
                  onPressed: toggle,
                  icon: Icon(obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                      size: 18, color: const Color(0xFF9CA3AF)))
              : null,
        ),
      ),
    ]);
  }
}
