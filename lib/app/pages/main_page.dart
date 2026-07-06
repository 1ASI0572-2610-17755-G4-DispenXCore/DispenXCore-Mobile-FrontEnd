import 'package:flutter/material.dart';
import '../../core/di/injector.dart';
import '../../core/services/scheduler_service.dart';
import '../../features/home/home_page.dart';
import '../../features/devices/devices_page.dart';
import '../../features/history/history_page.dart';
import '../../features/schedules/presentation/pages/schedules_page.dart';
import '../../features/settings/settings_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int index = 0;

  final pages = const [
    HomePage(),
    DevicesPage(),
    HistoryPage(),
    SchedulesPage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    final scheduler = injector<SchedulerService>();
    scheduler.onTriggered = _onScheduleTriggered;
    scheduler.start();
  }

  @override
  void dispose() {
    final scheduler = injector<SchedulerService>();
    scheduler.stop();
    scheduler.onTriggered = null;
    super.dispose();
  }

  void _onScheduleTriggered(schedule, success, error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Horario programado "${schedule.name}" activado: Dispensación iniciada.'
              : 'Error al activar horario programado "${schedule.name}": $error',
          style: const TextStyle(fontFamily: 'Arimo'),
        ),
        backgroundColor: success ? const Color(0xFF009688) : Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E7EB)),
          BottomNavigationBar(
            currentIndex: index,
            onTap: (i) => setState(() => index = i),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF009688),
            unselectedItemColor: const Color(0xFF9CA3AF),
            elevation: 0,
            selectedLabelStyle: const TextStyle(
              fontFamily: 'Arimo',
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontFamily: 'Arimo',
              fontSize: 11,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.router_outlined),
                activeIcon: Icon(Icons.router_rounded),
                label: 'Devices',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history_rounded),
                activeIcon: Icon(Icons.history_rounded),
                label: 'History',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.schedule_outlined),
                activeIcon: Icon(Icons.schedule_rounded),
                label: 'Horarios',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                activeIcon: Icon(Icons.settings_rounded),
                label: 'Settings',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
