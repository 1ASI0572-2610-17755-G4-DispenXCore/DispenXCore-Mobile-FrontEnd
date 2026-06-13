import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            const Text(
              "BIENVENIDO DE NUEVO",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 4),

            const Text(
              "Hola, Juan",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // ACTION CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF009688),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  const Icon(Icons.pets, color: Colors.white, size: 32),

                  const SizedBox(height: 10),

                  const Text(
                    "Acción Rápida",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    "Inicie el proceso de dispensación automática para el dispositivo principal.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    width: double.infinity,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.play_arrow,
                          color: Color(0xFF009688)),
                      label: const Text(
                        "Dispensar Ahora",
                        style: TextStyle(
                          color: Color(0xFF009688),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 16),

            // CARDS ROW
            Row(
              children: [
                Expanded(child: _inventoryCard()),
                const SizedBox(width: 12),
                Expanded(child: _deviceCard()),
              ],
            ),

            const SizedBox(height: 16),

            // ACTIVIDAD RECIENTE
            _sectionTitle("ACTIVIDAD RECIENTE"),

            const SizedBox(height: 10),

            _activityItem(
              icon: Icons.check_circle,
              title: "Dispensación Completada",
              subtitle: "Dispositivo DX-400 • Hace 12 min",
              value: "2.5kg",
              color: Colors.green,
            ),

            _activityItem(
              icon: Icons.warning,
              title: "Stock Bajo Detectado",
              subtitle: "Silo Norte • Hace 1 hora",
              value: "15%",
              color: Colors.red,
            ),

            _activityItem(
              icon: Icons.sensors,
              title: "Nuevo Sensor Vinculado",
              subtitle: "Estación Central • Hace 3 horas",
              value: "",
              color: Colors.blue,
            ),

            const SizedBox(height: 16),

            // SYSTEM BANNER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: AssetImage("assets/system.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
              child: const Text(
                "ESTADO DEL SISTEMA\nTodos los nodos en línea",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // INVENTORY CARD
  Widget _inventoryCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          const Text("INVENTARIO",
              style: TextStyle(fontSize: 12, color: Colors.grey)),

          const SizedBox(height: 10),

          Container(
            height: 60,
            width: 60,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF009688),
            ),
            child: const Center(
              child: Text(
                "75%",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          const Text("Estado de Inventario",
              style: TextStyle(fontSize: 12)),

          const SizedBox(height: 6),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              "ÓPTIMO",
              style: TextStyle(fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  // DEVICE CARD
  Widget _deviceCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Column(
        children: [
          Text("DISPOSITIVOS",
              style: TextStyle(fontSize: 12, color: Colors.grey)),

          SizedBox(height: 10),

          Text(
            "08",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          SizedBox(height: 6),

          Text("Activos ahora", style: TextStyle(fontSize: 12)),

          SizedBox(height: 10),

          Text("• 3 ALERTAS",
              style: TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
      ),
    );
  }

  Widget _activityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle,
                    style:
                        const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),

          if (value.isNotEmpty)
            Text(value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                )),
        ],
      ),
    );
  }
}