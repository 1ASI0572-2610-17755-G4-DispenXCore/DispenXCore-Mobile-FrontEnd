import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const _teal = Color(0xFF009688);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBar(),
            const SizedBox(height: 20),
            _buildGreeting(),
            const SizedBox(height: 20),
            _buildActionCard(),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _buildInventoryCard()),
                const SizedBox(width: 12),
                Expanded(child: _buildDevicesCard()),
              ],
            ),
            const SizedBox(height: 26),
            _buildSectionHeader(
              title: 'ACTIVIDAD RECIENTE',
              trailing: const Icon(Icons.open_in_new_rounded,
                  size: 16, color: Color(0xFF9CA3AF)),
            ),
            const SizedBox(height: 12),
            _buildActivityItem(
              icon: Icons.check_circle_outline_rounded,
              title: 'Dispensación Completada',
              subtitle: 'Dispositivo DX-400 · Hace 12 min',
              value: '2.5 kg',
              color: const Color(0xFF16A34A),
            ),
            _buildActivityItem(
              icon: Icons.warning_amber_rounded,
              title: 'Stock Bajo Detectado',
              subtitle: 'Silo Norte · Hace 1 hora',
              value: '15%',
              color: const Color(0xFFF59E0B),
            ),
            _buildActivityItem(
              icon: Icons.sensors_rounded,
              title: 'Nuevo Sensor Vinculado',
              subtitle: 'Estación Central · Hace 3 horas',
              value: '',
              color: const Color(0xFF2563EB),
            ),
            const SizedBox(height: 22),
            _buildSystemStatus(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        // Avatar
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
    );
  }

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'BIENVENIDO DE NUEVO',
          style: TextStyle(
            fontSize: 11,
            color: Color(0xFF9CA3AF),
            fontFamily: 'Arimo',
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
        SizedBox(height: 3),
        Text(
          'Hola, Juan',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            fontFamily: 'Arimo',
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF00897B), _teal],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _teal.withValues(alpha: 0.30),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.grain, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 10),
          const Text(
            'Acción Rápida',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontFamily: 'Arimo',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Inicie el proceso de dispensación automática\npara el dispositivo principal.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontFamily: 'Arimo',
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: TextButton.icon(
              onPressed: () {},
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                shape: const StadiumBorder(),
              ),
              icon: const Icon(Icons.play_circle_outline_rounded,
                  color: _teal, size: 20),
              label: const Text(
                'Dispensar Ahora',
                style: TextStyle(
                  color: _teal,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Arimo',
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'INVENTARIO',
            style: TextStyle(
              fontSize: 10,
              color: Color(0xFF9CA3AF),
              fontFamily: 'Arimo',
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 62,
                  height: 62,
                  child: CircularProgressIndicator(
                    value: 0.75,
                    strokeWidth: 5,
                    backgroundColor: const Color(0xFFE5E7EB),
                    valueColor: const AlwaysStoppedAnimation(_teal),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                const Text(
                  '75%',
                  style: TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 14,
                    fontFamily: 'Arimo',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Center(
            child: Text(
              'Estado de\nInventario',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF374151),
                fontFamily: 'Arimo',
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'ÓPTIMO',
                style: TextStyle(
                  fontSize: 9,
                  color: Color(0xFF16A34A),
                  fontFamily: 'Arimo',
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDevicesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DISPOSITIVOS',
            style: TextStyle(
              fontSize: 10,
              color: Color(0xFF9CA3AF),
              fontFamily: 'Arimo',
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '08',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              fontFamily: 'Arimo',
              color: Color(0xFF1F2937),
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Activos ahora',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF374151),
              fontFamily: 'Arimo',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFFF59E0B),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              const Text(
                '• 3 ALERTAS',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF9CA3AF),
                  fontFamily: 'Arimo',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
      {required String title, required Widget trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            fontFamily: 'Arimo',
            color: Color(0xFF9CA3AF),
            letterSpacing: 0.6,
          ),
        ),
        trailing,
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required Color color,
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
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
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
          if (value.isNotEmpty) ...[
            const SizedBox(width: 8),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontFamily: 'Arimo',
                fontSize: 13,
                color: color,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSystemStatus() {
    return Container(
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        // Reemplazar con: DecorationImage(image: AssetImage('assets/system.jpg'), fit: BoxFit.cover)
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1F2937), Color(0xFF374151)],
        ),
      ),
      child: Stack(
        children: [
          // decoración
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'ESTADO DEL SISTEMA',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 10,
                    fontFamily: 'Arimo',
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Todos los nodos en línea',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Arimo',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
