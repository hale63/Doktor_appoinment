import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // Demo bildirim verileri
  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: '1',
      title: 'Randevu Onaylandı',
      message: 'Dr. Ahmet Yılmaz ile olan randevunuz onaylandı.',
      time: '2 saat önce',
      type: NotificationType.appointment,
      isRead: false,
    ),
    NotificationItem(
      id: '2',
      title: 'Randevu Hatırlatması',
      message: 'Yarın saat 14:00\'te randevunuz bulunmaktadır.',
      time: '1 gün önce',
      type: NotificationType.reminder,
      isRead: true,
    ),
    NotificationItem(
      id: '3',
      title: 'Sistem Güncellemesi',
      message: 'Uygulama yeni özellikler ile güncellendi.',
      time: '3 gün önce',
      type: NotificationType.system,
      isRead: true,
    ),
    NotificationItem(
      id: '4',
      title: 'Randevu İptal Edildi',
      message: 'Dr. Mehmet Kaya ile olan randevunuz iptal edildi.',
      time: '1 hafta önce',
      type: NotificationType.cancelled,
      isRead: false,
    ),
  ];

  void _markAsRead(String notificationId) {
    setState(() {
      final notification = _notifications.firstWhere((n) => n.id == notificationId);
      notification.isRead = true;
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification.isRead = true;
      }
    });
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.appointment:
        return Icons.check_circle_outline;
      case NotificationType.reminder:
        return Icons.access_time;
      case NotificationType.cancelled:
        return Icons.cancel_outlined;
      case NotificationType.system:
        return Icons.system_update;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.appointment:
        return Colors.green;
      case NotificationType.reminder:
        return Colors.orange;
      case NotificationType.cancelled:
        return Colors.red;
      case NotificationType.system:
        return const Color(0xFF6B46C1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      appBar: AppBar(
        title: const Text(
          'Bildirimler',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF6B46C1),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Tümünü Okundu İşaretle',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6B46C1),
              Color(0xFFF8F7FF),
            ],
            stops: [0.0, 0.15],
          ),
        ),
        child: _notifications.isEmpty
            ? _buildEmptyState()
            : Column(
          children: [
            // Okunmamış bildirim sayısı
            if (unreadCount > 0)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6B46C1).withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9500).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.notifications_active,
                        color: Color(0xFFFF9500),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$unreadCount okunmamış bildiriminiz var',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
              ),

            // Bildirim listesi
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  return _buildNotificationCard(notification);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: notification.isRead ? 2 : 6,
        shadowColor: const Color(0xFF6B46C1).withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _markAsRead(notification.id),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    notification.isRead
                        ? const Color(0xFFFAF9FF)
                        : const Color(0xFFF3F0FF),
                  ],
                ),
                border: Border.all(
                  color: notification.isRead
                      ? const Color(0xFF6B46C1).withOpacity(0.1)
                      : const Color(0xFF6B46C1).withOpacity(0.3),
                  width: notification.isRead ? 1 : 2,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getNotificationColor(notification.type).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getNotificationIcon(notification.type),
                        color: _getNotificationColor(notification.type),
                        size: 20,
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  notification.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: notification.isRead
                                        ? FontWeight.w600
                                        : FontWeight.bold,
                                    color: const Color(0xFF1F2937),
                                  ),
                                ),
                              ),
                              if (!notification.isRead)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF6B46C1),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          Text(
                            notification.message,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            notification.time,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz bildiriminiz yok',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Yeni bildirimler burada görünecek',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

// Bildirim modeli
class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String time;
  final NotificationType type;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    this.isRead = false,
  });
}

enum NotificationType {
  appointment,
  reminder,
  cancelled,
  system,
}
