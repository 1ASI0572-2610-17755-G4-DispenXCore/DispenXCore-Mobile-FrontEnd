import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String selectedTab = "All Events";

  final tabs = ["All Events", "Dispenses", "Errors", "Maintenance"];

  final List<Map<String, dynamic>> events = [
    {
      "title": "Insulin Core-V2",
      "subtitle": "2.5 units dispensed",
      "time": "12:22 • ROOM 402",
      "status": "success",
      "icon": Icons.medical_services,
    },
    {
      "title": "Saline Flow-X",
      "subtitle": "Clogged nozzle detected",
      "time": "11:05 • ROOM 103",
      "status": "error",
      "icon": Icons.warning,
    },
    {
      "title": "Heparin Prime",
      "subtitle": "5.0 units dispensed",
      "time": "09:45 • ROOM 312",
      "status": "success",
      "icon": Icons.local_hospital,
    },
    {
      "title": "Supply Restock",
      "subtitle": "Cartridge #09 replaced",
      "time": "18:30 • CENTRAL HUB",
      "status": "system",
      "icon": Icons.inventory,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "DispenXCore",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(Icons.notifications_none),
              ],
            ),

            const SizedBox(height: 16),

            // TREND SECTION
            const Text(
              "WEEKLY CONSUMPTION",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),

            const SizedBox(height: 6),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "Trend Analysis",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "42.8 units",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // MINI CHART PLACEHOLDER
            Container(
              height: 80,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text("📊 Weekly Chart"),
              ),
            ),

            const SizedBox(height: 16),

            // TABS
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: tabs.length,
                itemBuilder: (context, i) {
                  final t = tabs[i];
                  final isSelected = t == selectedTab;

                  return GestureDetector(
                    onTap: () => setState(() => selectedTab = t),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? Colors.teal : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        t,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // EVENTS LIST
            Expanded(
              child: ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, i) {
                  final e = events[i];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [

                        Icon(e["icon"], color: Colors.teal),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                e["title"],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                e["subtitle"],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                e["time"],
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),

                        _statusBadge(e["status"]),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    String text;

    switch (status) {
      case "success":
        color = Colors.green;
        text = "Success";
        break;
      case "error":
        color = Colors.red;
        text = "Error";
        break;
      default:
        color = Colors.blue;
        text = "System";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}