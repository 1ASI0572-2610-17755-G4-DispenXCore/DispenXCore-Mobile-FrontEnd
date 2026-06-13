import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/router/app_router.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool stockAlert = true;
  bool deliveryAlert = true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // TITLE
          const Text(
            "Configuración",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),

          const Text(
            "Gestiona tus dispositivos y preferencias de cuenta.",
            style: TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 20),

          // NOTIFICATIONS
          _sectionTitle("PREFERENCIAS DE NOTIFICACIÓN"),

          const SizedBox(height: 10),

          _switchTile(
            icon: Icons.inventory_2_outlined,
            title: "Stock Bajo",
            subtitle: "Avisar cuando quede < 10%",
            value: stockAlert,
            onChanged: (v) => setState(() => stockAlert = v),
          ),

          _switchTile(
            icon: Icons.local_shipping_outlined,
            title: "Dispensación",
            subtitle: "Confirmación de entrega",
            value: deliveryAlert,
            onChanged: (v) => setState(() => deliveryAlert = v),
          ),

          const SizedBox(height: 20),

          // NETWORK
          _sectionTitle("CONFIGURACIÓN DE RED"),

          const SizedBox(height: 10),

          _tile(
            icon: Icons.wifi,
            title: "Red Wi-Fi",
            subtitle: "Conectado: DispenX_Main_5G",
            onTap: () {},
          ),

          _tile(
            icon: Icons.hub,
            title: "Protocolo MQTT",
            subtitle: "Cloud Integration Active",
            onTap: () {},
          ),

          const SizedBox(height: 20),

          // ACCOUNT
          _sectionTitle("AJUSTES DE CUENTA"),

          const SizedBox(height: 10),

          _tile(
            icon: Icons.person_outline,
            title: "Editar Perfil",
            subtitle: "",
            onTap: () {},
          ),

          _tile(
            icon: Icons.security_outlined,
            title: "Seguridad y Privacidad",
            subtitle: "",
            onTap: () {},
          ),

          _tile(
            icon: Icons.help_outline,
            title: "Centro de Ayuda",
            subtitle: "",
            onTap: () {},
          ),

          const SizedBox(height: 30),

          // LOGOUT BUTTON
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.red.shade50,
            ),
            child: TextButton.icon(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();

                // limpiar sesión
                await prefs.clear();

                // ir a login (IMPORTANTE)
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRouter.login,
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                "Cerrar Sesión",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ),

          const SizedBox(height: 10),

          const Center(
            child: Text(
              "Versión 2.4.1-rc (Build 890)",
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
      ),
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),

          Switch(
            value: value,
            activeColor: Colors.teal,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, color: Colors.teal),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  if (subtitle.isNotEmpty)
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),

            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}