import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/services/notification_service.dart';
import 'package:flutter_frontend/domain/entities/notification.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  List<AppNotification> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final notifications = await _notificationService.getNotifications();
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar notificaciones: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(AppNotification notification) async {
    if (notification.isRead) return;

    try {
      await _notificationService.markAsRead(notification.idNotification!);
      setState(() {
        final index = _notifications.indexWhere(
          (n) => n.idNotification == notification.idNotification,
        );
        if (index != -1) {
          _notifications[index] = notification.copyWith(
            isRead: true,
            readDate: DateTime.now(),
          );
        }
      });
    } catch (e) {
      print('Error marking as read: $e');
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();
      setState(() {
        _notifications = _notifications.map((n) {
          return n.copyWith(isRead: true, readDate: DateTime.now());
        }).toList();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Todas las notificaciones marcadas como leídas'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteNotification(AppNotification notification) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar notificación'),
        content: const Text('¿Estás seguro de eliminar esta notificación?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _notificationService.deleteNotification(
          notification.idNotification!,
        );
        setState(() {
          _notifications.removeWhere(
            (n) => n.idNotification == notification.idNotification,
          );
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notificación eliminada'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _handleNotificationTap(AppNotification notification) {
    // Marcar como leída
    _markAsRead(notification);

    // Navegar según el tipo de notificación
    switch (notification.type) {
      case NotificationType.REMINDER:
        // TODO: Navegar a detalles del recordatorio
        print('Navigate to reminder: ${notification.relatedEntityId}');
        break;
      case NotificationType.COMMENT:
        // TODO: Navegar al memorial con el comentario
        print('Navigate to memorial: ${notification.relatedEntityId}');
        break;
      case NotificationType.LIKE:
        // TODO: Navegar a la memoria que recibió like
        break;
      default:
        break;
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.REMINDER:
        return Icons.event;
      case NotificationType.COMMENT:
        return Icons.comment;
      case NotificationType.LIKE:
        return Icons.favorite;
      case NotificationType.MEMORIAL_SHARED:
        return Icons.share;
      case NotificationType.SYSTEM:
        return Icons.info;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.REMINDER:
        return const Color(0xFF6366F1);
      case NotificationType.COMMENT:
        return Colors.blue;
      case NotificationType.LIKE:
        return Colors.pink;
      case NotificationType.MEMORIAL_SHARED:
        return Colors.purple;
      case NotificationType.SYSTEM:
        return Colors.grey;
    }
  }

  /// ✅ Formatea el tiempo transcurrido de forma inteligente
  String _formatTimeAgo(DateTime dateTime) {
  // ✅ CRÍTICO: El backend envía UTC, convertir a hora local del dispositivo
  final localTime = dateTime.toLocal();
  final now = DateTime.now();
  final difference = now.difference(localTime);
  
  // DEBUG
  print('🕐 Date from backend (UTC): $dateTime');
  print('🕐 Converted to local: $localTime');
  print('🕐 Now: $now');
  print('🕐 Difference: ${difference.inMinutes} minutes');
  
  if (difference.isNegative) {
    return 'Ahora'; // Si la fecha es futura por alguna razón
  }
  
  if (difference.inSeconds < 60) {
    return 'Ahora';
  } else if (difference.inMinutes < 2) {
    return 'Hace 1 minuto';
  } else if (difference.inMinutes < 60) {
    return 'Hace ${difference.inMinutes} minutos';
  } else if (difference.inHours < 2) {
    return 'Hace 1 hora';
  } else if (difference.inHours < 24) {
    return 'Hace ${difference.inHours} horas';
  } else if (difference.inDays < 2) {
    return 'Ayer';
  } else if (difference.inDays < 7) {
    return 'Hace ${difference.inDays} días';
  } else if (difference.inDays < 30) {
    final weeks = (difference.inDays / 7).floor();
    return weeks == 1 ? 'Hace 1 semana' : 'Hace $weeks semanas';
  } else if (difference.inDays < 365) {
    final months = (difference.inDays / 30).floor();
    return months == 1 ? 'Hace 1 mes' : 'Hace $months meses';
  } else {
    final years = (difference.inDays / 365).floor();
    return years == 1 ? 'Hace 1 año' : 'Hace $years años';
  }
}

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'Notificaciones',
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.black),
      actions: [
        // ✅ SOLO mostrar botón si hay notificaciones no leídas
        if (unreadCount > 0 && !_isLoading)
          TextButton(
            onPressed: _markAllAsRead,
            child: const Text(
              'Marcar todas',
              style: TextStyle(
                color: Color(0xFF6366F1),
                fontSize: 13,
              ),
            ),
          ),
      ],
    ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadNotifications,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                          ),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                )
              : _notifications.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_none,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No tienes notificaciones',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Cuando recibas notificaciones, aparecerán aquí',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadNotifications,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                          final notification = _notifications[index];
                          return _buildNotificationCard(notification);
                        },
                      ),
                    ),
    );
  }

  Widget _buildNotificationCard(AppNotification notification) {
    final color = _getNotificationColor(notification.type);
    final timeAgo = _formatTimeAgo(notification.createdDate);

    return Dismissible(
      key: Key('notification_${notification.idNotification}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 28,
        ),
      ),
      onDismissed: (direction) {
        _deleteNotification(notification);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notification.isRead 
                ? Colors.grey[300]! 
                : color.withOpacity(0.3),
            width: notification.isRead ? 1 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: () => _handleNotificationTap(notification),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icono
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getNotificationIcon(notification.type),
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                // Contenido
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
                                    ? FontWeight.w500 
                                    : FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        timeAgo,
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
    );
  }
}