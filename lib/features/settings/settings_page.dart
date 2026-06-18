import 'package:dispenxcore_frontend/app/router/app_router.dart';
import 'package:dispenxcore_frontend/core/di/injector.dart';
import 'package:dispenxcore_frontend/features/auth/domain/entities/user.dart';
import 'package:dispenxcore_frontend/features/users/domain/usecases/change_password.dart';
import 'package:dispenxcore_frontend/features/users/domain/usecases/get_current_user.dart';
import 'package:dispenxcore_frontend/features/users/domain/usecases/update_user.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final user = await _getCurrentUser.call();
      if (mounted) setState(() { _user = user; _isLoadingUser = false; });
    } catch (e) {
      if (mounted) {
        setState(() { _loadError = _msg(e); _isLoadingUser = false; });
      }
    }
  }

  String _msg(Object e) =>
      e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');

  String get _initials {
    final f = (_user?.firstName.isNotEmpty == true) ? _user!.firstName[0] : '';
    final l = (_user?.lastName.isNotEmpty == true) ? _user!.lastName[0] : '';
    return '${f.toUpperCase()}${l.toUpperCase()}';
  }

  String get _fullName =>
      _user != null ? '${_user!.firstName} ${_user!.lastName}'.trim() : '—';

  // ── Diálogo editar perfil ─────────────────────────────────────
  Future<void> _showEditProfileDialog() async {
    if (_user == null) return;
    final firstCtrl = TextEditingController(text: _user!.firstName);
    final lastCtrl = TextEditingController(text: _user!.lastName);

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) {
          bool saving = false;
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Editar Perfil',
                style: TextStyle(fontFamily: 'Arimo', fontWeight: FontWeight.w700, fontSize: 17)),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              _dialogField(ctrl: firstCtrl, label: 'Nombre', hint: 'John'),
              const SizedBox(height: 12),
              _dialogField(ctrl: lastCtrl, label: 'Apellido', hint: 'Doe'),
            ]),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar',
                    style: TextStyle(color: Color(0xFF9CA3AF), fontFamily: 'Arimo')),
              ),
              StatefulBuilder(
                builder: (_, setSaveBtn) => ElevatedButton(
                  onPressed: saving
                      ? null
                      : () async {
                          final fn = firstCtrl.text.trim();
                          final ln = lastCtrl.text.trim();
                          if (fn.isEmpty || ln.isEmpty) return;
                          setSaveBtn(() => saving = true);
                          try {
                            final updated = await _updateUser.call(
                              _user!.id,
                              firstName: fn,
                              lastName: ln,
                              photoUrl: _user!.photoUrl,
                            );
                            if (!mounted) return;
                            setState(() => _user = updated);
                            if (ctx.mounted) Navigator.pop(ctx);
                            _snack('Perfil actualizado', success: true);
                          } catch (e) {
                            setSaveBtn(() => saving = false);
                            _snack(_msg(e), success: false);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _teal, elevation: 0, shape: const StadiumBorder()),
                  child: saving
                      ? const SizedBox(width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Guardar',
                          style: TextStyle(fontFamily: 'Arimo', color: Colors.white)),
                ),
              ),
            ],
          );
        },
      ),
    );

    firstCtrl.dispose();
    lastCtrl.dispose();
  }

  // ── Diálogo cambiar contraseña ────────────────────────────────
  Future<void> _showChangePasswordDialog() async {
    if (_user == null) return;
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) {
          bool saving = false;
          bool showCurrent = false;
          bool showNew = false;
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Cambiar Contraseña',
                style: TextStyle(fontFamily: 'Arimo', fontWeight: FontWeight.w700, fontSize: 17)),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              _dialogField(
                ctrl: currentCtrl, label: 'Contraseña actual', hint: '••••••••',
                obscure: !showCurrent,
                toggle: () => setLocal(() => showCurrent = !showCurrent),
              ),
              const SizedBox(height: 12),
              _dialogField(
                ctrl: newCtrl, label: 'Nueva contraseña', hint: '••••••••',
                obscure: !showNew,
                toggle: () => setLocal(() => showNew = !showNew),
              ),
              const SizedBox(height: 12),
              _dialogField(
                ctrl: confirmCtrl, label: 'Confirmar nueva', hint: '••••••••',
                obscure: !showNew,
              ),
            ]),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar',
                    style: TextStyle(color: Color(0xFF9CA3AF), fontFamily: 'Arimo')),
              ),
              StatefulBuilder(
                builder: (_, setSaveBtn) => ElevatedButton(
                  onPressed: saving
                      ? null
                      : () async {
                          final cur = currentCtrl.text.trim();
                          final nw = newCtrl.text.trim();
                          final cf = confirmCtrl.text.trim();
                          if (cur.isEmpty || nw.isEmpty) return;
                          if (nw != cf) { _snack('Las contraseñas no coinciden', success: false); return; }
                          if (nw.length < 6) { _snack('Mínimo 6 caracteres', success: false); return; }
                          setSaveBtn(() => saving = true);
                          try {
                            await _changePassword.call(
                              _user!.id,
                              currentPassword: cur,
                              newPassword: nw,
                            );
                            if (ctx.mounted) Navigator.pop(ctx);
                            _snack('Contraseña actualizada', success: true);
                          } catch (e) {
                            setSaveBtn(() => saving = false);
                            _snack(_msg(e), success: false);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _teal, elevation: 0, shape: const StadiumBorder()),
                  child: saving
                      ? const SizedBox(width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Cambiar',
                          style: TextStyle(fontFamily: 'Arimo', color: Colors.white)),
                ),
              ),
            ],
          );
        },
      ),
    );

    currentCtrl.dispose();
    newCtrl.dispose();
    confirmCtrl.dispose();
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
                color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.notifications_outlined,
                  color: Color(0xFF374151), size: 18),
            ),
          ]),

          const SizedBox(height: 20),

          // ── Tarjeta de perfil ─────────────────────────────────
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

          // ── Notificaciones ────────────────────────────────────
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

          // ── Red ───────────────────────────────────────────────
          _sectionLabel('CONFIGURACIÓN DE RED'),
          const SizedBox(height: 10),
          _navTile(icon: Icons.wifi_rounded, title: 'Red Wi-Fi',
              subtitle: 'Conectado: DispenX_Main_5G', onTap: () {}),
          _navTile(icon: Icons.hub_outlined, title: 'Protocolo MQTT',
              subtitle: 'Cloud Integration Active', onTap: () {}),

          const SizedBox(height: 20),

          // ── Cuenta ────────────────────────────────────────────
          _sectionLabel('AJUSTES DE CUENTA'),
          const SizedBox(height: 10),
          _navTile(icon: Icons.person_outline_rounded, title: 'Editar Perfil',
              subtitle: '', onTap: _showEditProfileDialog),
          _navTile(icon: Icons.lock_outline_rounded, title: 'Cambiar Contraseña',
              subtitle: '', onTap: _showChangePasswordDialog),
          _navTile(icon: Icons.help_outline_rounded, title: 'Centro de Ayuda',
              subtitle: '', onTap: () {}),

          const SizedBox(height: 28),

          // ── Logout ────────────────────────────────────────────
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
              icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 18),
              label: const Text('Cerrar Sesión',
                  style: TextStyle(color: Color(0xFFEF4444), fontSize: 15,
                      fontFamily: 'Arimo', fontWeight: FontWeight.w600)),
            ),
          ),

          const SizedBox(height: 16),
          const Center(child: Text('Versión 2.4.1-rc (Build 890)',
              style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF), fontFamily: 'Arimo'))),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ── Tarjeta de perfil ──────────────────────────────────────────
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
              style: TextStyle(color: Color(0xFF9CA3AF), fontFamily: 'Arimo', fontSize: 13)),
        ]),
      );
    }

    if (_loadError != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF5F5), borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFEE2E2)),
        ),
        child: Row(children: [
          const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(_loadError!,
              style: const TextStyle(color: Color(0xFFEF4444), fontFamily: 'Arimo', fontSize: 12))),
          IconButton(
            onPressed: () {
              setState(() { _isLoadingUser = true; _loadError = null; });
              _loadUser();
            },
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFFEF4444), size: 18),
            padding: EdgeInsets.zero, constraints: const BoxConstraints(),
          ),
        ]),
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Row(children: [
        // Avatar: foto de red si existe, iniciales si no
        Container(
          width: 58, height: 58,
          decoration: const BoxDecoration(color: _teal, shape: BoxShape.circle),
          clipBehavior: Clip.antiAlias,
          child: (_user?.photoUrl != null && _user!.photoUrl!.isNotEmpty)
              ? Image.network(_user!.photoUrl!, fit: BoxFit.cover,
                  errorBuilder: (_, a, b) => _initialsCenter(20))
              : _initialsCenter(20),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_fullName,
              style: const TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Arimo',
                  fontSize: 16, color: Color(0xFF1F2937))),
          const SizedBox(height: 3),
          Text(_user?.email ?? '',
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280), fontFamily: 'Arimo')),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _teal.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(20)),
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
              color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF374151)),
          ),
          padding: EdgeInsets.zero, constraints: const BoxConstraints(),
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
    boxShadow: [BoxShadow(
        color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3))],
  );

  Widget _dialogField({
    required TextEditingController ctrl,
    required String label,
    required String hint,
    bool obscure = false,
    VoidCallback? toggle,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
          fontFamily: 'Arimo', color: Color(0xFF374151))),
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
                  icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      size: 18, color: const Color(0xFF9CA3AF)))
              : null,
        ),
      ),
    ]);
  }

  Widget _sectionLabel(String text) => Text(text, style: const TextStyle(
    fontSize: 11, fontWeight: FontWeight.w700,
    fontFamily: 'Arimo', color: Color(0xFF9CA3AF), letterSpacing: 0.7));

  Widget _switchTile({
    required IconData icon, required String title,
    required String subtitle, required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF0F0F0)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6, offset: const Offset(0, 2))]),
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
        Switch(value: value, onChanged: onChanged,
            activeTrackColor: const Color(0xFF16A34A),
            inactiveTrackColor: const Color(0xFFE5E7EB),
            activeThumbColor: Colors.white, inactiveThumbColor: Colors.white,
            trackOutlineColor: WidgetStateProperty.all(Colors.transparent)),
      ]),
    );
  }

  Widget _navTile({
    required IconData icon, required String title,
    required String subtitle, required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF0F0F0)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6, offset: const Offset(0, 2))]),
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
