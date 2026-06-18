import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/router/app_router.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _stockAlert = true;
  bool _deliveryAlert = true;

  static const _teal = Color(0xFF009688);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        children: [
          // Top bar
          Row(
            children: [
              Container(
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
              ),
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

          const SizedBox(height: 24),

          const Text(
            'Configuración',
            style: TextStyle(
              fontSize: 22,
              fontFamily: 'Arimo',
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Gestiona tus dispositivos y preferencias de cuenta.',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 13,
              fontFamily: 'Arimo',
              height: 1.4,
            ),
          ),

          const SizedBox(height: 24),

          _sectionLabel('PREFERENCIAS DE NOTIFICACIÓN'),
          const SizedBox(height: 10),

          _switchTile(
            icon: Icons.inventory_2_outlined,
            title: 'Stock Bajo',
            subtitle: 'Avisar cuando quede < 10%',
            value: _stockAlert,
            onChanged: (v) => setState(() => _stockAlert = v),
          ),
          _switchTile(
            icon: Icons.swap_horiz_rounded,
            title: 'Dispensación',
            subtitle: 'Confirmación de entrega',
            value: _deliveryAlert,
            onChanged: (v) => setState(() => _deliveryAlert = v),
          ),

          const SizedBox(height: 20),

          _sectionLabel('CONFIGURACIÓN DE RED'),
          const SizedBox(height: 10),

          _navTile(
            icon: Icons.wifi_rounded,
            title: 'Red Wi-Fi',
            subtitle: 'Conectado: DispenX_Main_5G',
            onTap: () {},
          ),
          _navTile(
            icon: Icons.hub_outlined,
            title: 'Protocolo MQTT',
            subtitle: 'Cloud Integration Active',
            onTap: () {},
          ),

          const SizedBox(height: 20),

          _sectionLabel('AJUSTES DE CUENTA'),
          const SizedBox(height: 10),

          _navTile(
            icon: Icons.person_outline_rounded,
            title: 'Editar Perfil',
            subtitle: '',
            onTap: () {},
          ),
          _navTile(
            icon: Icons.shield_outlined,
            title: 'Seguridad y Privacidad',
            subtitle: '',
            onTap: () {},
          ),
          _navTile(
            icon: Icons.help_outline_rounded,
            title: 'Centro de Ayuda',
            subtitle: '',
            onTap: () {},
          ),

          const SizedBox(height: 28),

          // Logout
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                if (!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRouter.login,
                  (route) => false,
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFFEE2E2)),
                backgroundColor: const Color(0xFFFFF5F5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.logout_rounded,
                  color: Color(0xFFEF4444), size: 18),
              label: const Text(
                'Cerrar Sesión',
                style: TextStyle(
                  color: Color(0xFFEF4444),
                  fontSize: 15,
                  fontFamily: 'Arimo',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          const Center(
            child: Text(
              'Versión 2.4.1-rc (Build 890)',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF9CA3AF),
                fontFamily: 'Arimo',
              ),
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        fontFamily: 'Arimo',
        color: Color(0xFF9CA3AF),
        letterSpacing: 0.7,
      ),
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _teal.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _teal, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Arimo',
                    fontSize: 13,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                    fontFamily: 'Arimo',
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: const Color(0xFF16A34A),
            inactiveTrackColor: const Color(0xFFE5E7EB),
            activeThumbColor: Colors.white,
            inactiveThumbColor: Colors.white,
            trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
          ),
        ],
      ),
    );
  }

  Widget _navTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
      child: ListTile(
        onTap: onTap,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _teal.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: _teal, size: 18),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: 'Arimo',
            fontSize: 13,
            color: Color(0xFF1F2937),
          ),
        ),
        subtitle: subtitle.isNotEmpty
            ? Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF009688),
                  fontFamily: 'Arimo',
                ),
              )
            : null,
        trailing: const Icon(Icons.chevron_right_rounded,
            color: Color(0xFFD1D5DB), size: 20),
      ),
    );
  }
}
