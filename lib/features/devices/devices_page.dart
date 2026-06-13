import 'package:flutter/material.dart';

class DevicesPage extends StatefulWidget {
  const DevicesPage({super.key});

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  bool isOnline = true;

  // 🔥 DATA ESTÁTICA
  final Map<String, dynamic> device = {
    "id": 1,
    "name": "PetFeeder Pro",
    "foodLevel": 1.2,
    "battery": 84,
    "network": "Home_WiFi_2.4GHz"
  };

  void togglePower(bool value) {
    setState(() {
      isOnline = value;
    });
  }

  void dispenseManual() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("🐾 Dispensando alimento..."),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "PetFeeder Pro",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.wifi,
                      color: isOnline ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(isOnline ? "ONLINE" : "OFFLINE"),
                  ],
                )
              ],
            ),

            const SizedBox(height: 20),

            // STATUS CARD
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 10,
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("DEVICE STATUS"),
                      SizedBox(height: 6),
                      Text(
                        "Operational",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  Switch(
                    value: isOnline,
                    onChanged: togglePower,
                    activeColor: Colors.teal,
                  )
                ],
              ),
            ),

            const SizedBox(height: 16),

            // INFO CARDS
            Row(
              children: [
                Expanded(
                  child: _card(
                    "BATTERY",
                    "${device["battery"]}%",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _card(
                    "FOOD LEVEL",
                    "${device["foodLevel"]}kg",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              "Configurations",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            _config("PORCIÓN (g)", "45g", "5g - 200g"),
            const SizedBox(height: 10),
            _config("FRECUENCIA", "3x / día", "1x - 6x"),

            const SizedBox(height: 20),

            // QUICK ACTION
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("⚡ QUICK ACTION"),
                  const SizedBox(height: 6),
                  const Text(
                    "Manual Feed",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.all(14),
                      ),
                      onPressed: dispenseManual,
                      icon: const Icon(Icons.flash_on),
                      label: const Text("Dispensar Manual"),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 16),

            // NETWORK
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("NETWORK"),
                      const SizedBox(height: 6),
                      Text(device["network"]),
                    ],
                  ),
                  const Icon(Icons.signal_cellular_4_bar,
                      color: Colors.green),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _config(String title, String value, String range) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title),
              const SizedBox(height: 4),
              Text(range,
                  style: const TextStyle(
                      fontSize: 10, color: Colors.grey)),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }
}