import 'package:flutter/material.dart';
import '../../domain/entities/alert_grain.dart';

class AlertTile extends StatelessWidget {
  final AppNotification notification;
  final Future<void> Function(AppNotification) onMarkAsRead;

  const AlertTile({
    super.key,
    required this.notification,
    required this.onMarkAsRead,
  });

  @override
  Widget build(BuildContext context) {
    final unread = notification.unread;

    final (IconData icon, Color iconColor, Color iconBg) = switch (notification.type) {
      1 => (Icons.check_circle_rounded, const Color(0xFF16A34A), const Color(0xFFDCFCE7)),
      2 => (Icons.info_rounded, const Color(0xFF2563EB), const Color(0xFFDBEAFE)),
      _ => (Icons.warning_amber_rounded, const Color(0xFFF59E0B), const Color(0xFFFEF3C7)),
    };

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: unread ? const Color(0xFFF0FDF9) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: unread ? const Color(0xFF99F6E4) : const Color(0xFFF0F0F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontFamily: 'Arimo',
            fontWeight: unread ? FontWeight.w600 : FontWeight.w400,
            fontSize: 14,
            color: const Color(0xFF1F2937),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 3),
            Text(
              notification.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF374151),
                fontFamily: 'Arimo',
              ),
            ),
            const SizedBox(height: 3),
            Text(
              notification.time,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF9CA3AF),
                fontFamily: 'Arimo',
              ),
            ),
          ],
        ),
        trailing: unread
            ? TextButton(
                onPressed: () => onMarkAsRead(notification),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Leído',
                  style: TextStyle(
                    color: Color(0xFF009688),
                    fontSize: 12,
                    fontFamily: 'Arimo',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
