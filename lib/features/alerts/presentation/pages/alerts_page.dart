import 'package:flutter/material.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/alert_grain.dart';
import '../../domain/usecases/get_active_alerts.dart';
import '../widgets/alert_tile.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  static const _teal = Color(0xFF009688);

  late final GetNotifications _getNotifications;
  late final MarkAllNotificationsAsRead _markAllAsRead;
  late final MarkNotificationAsRead _markAsRead;
  late final TokenStorage _tokenStorage;

  List<AppNotification> _notifications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _getNotifications = injector<GetNotifications>();
    _markAllAsRead = injector<MarkAllNotificationsAsRead>();
    _markAsRead = injector<MarkNotificationAsRead>();
    _tokenStorage = injector<TokenStorage>();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      final result = await _getNotifications();
      if (!mounted) return;
      setState(() { _notifications = result; _isLoading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
        _isLoading = false;
      });
    }
  }

  Future<void> _onMarkAsRead(AppNotification n) async {
    try {
      await _markAsRead(n.id);
      setState(() {
        final idx = _notifications.indexWhere((x) => x.id == n.id);
        if (idx != -1) {
          _notifications = List.from(_notifications)
            ..[idx] = AppNotification(
              id: n.id,
              userId: n.userId,
              type: n.type,
              title: n.title,
              time: n.time,
              message: n.message,
              action: n.action,
              unread: false,
              createdAt: n.createdAt,
            );
        }
      });
    } catch (_) {}
  }

  Future<void> _onMarkAllAsRead() async {
    final userId = await _tokenStorage.getUserId();
    if (userId == null) return;
    try {
      await _markAllAsRead(userId);
      setState(() {
        _notifications = _notifications
            .map((n) => AppNotification(
                  id: n.id,
                  userId: n.userId,
                  type: n.type,
                  title: n.title,
                  time: n.time,
                  message: n.message,
                  action: n.action,
                  unread: false,
                  createdAt: n.createdAt,
                ))
            .toList();
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => n.unread).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones',
            style: TextStyle(fontFamily: 'Arimo', fontWeight: FontWeight.w700)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F2937),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE5E7EB)),
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _onMarkAllAsRead,
              child: const Text('Leer todo',
                  style: TextStyle(color: _teal, fontFamily: 'Arimo',
                      fontWeight: FontWeight.w600)),
            ),
        ],
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
                const Icon(Icons.cloud_off_rounded, size: 48,
                    color: Color(0xFFD1D5DB)),
                const SizedBox(height: 12),
                Text(_error!, textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFF6B7280),
                        fontFamily: 'Arimo')),
              ]),
            ),
          ),
        ],
      );
    }

    if (_notifications.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.28),
          const Center(
            child: Column(children: [
              Icon(Icons.notifications_none_rounded, size: 64,
                  color: Color(0xFFD1D5DB)),
              SizedBox(height: 16),
              Text('Sin notificaciones',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                      fontFamily: 'Arimo', color: Color(0xFF1F2937))),
              SizedBox(height: 6),
              Text('Todo en orden. No hay alertas pendientes.',
                  style: TextStyle(color: Color(0xFF9CA3AF),
                      fontFamily: 'Arimo')),
            ]),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        return AlertTile(
          notification: _notifications[index],
          onMarkAsRead: _onMarkAsRead,
        );
      },
    );
  }
}
