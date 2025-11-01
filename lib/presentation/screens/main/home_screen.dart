import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/services/memorial_service.dart';
import 'package:flutter_frontend/data/services/reminder_service.dart';
import 'package:flutter_frontend/data/services/notification_service.dart';
import 'package:flutter_frontend/domain/entities/memorial.dart';
import 'package:flutter_frontend/domain/entities/reminder.dart';
import 'package:flutter_frontend/presentation/screens/main/widgets/card_container.dart';
import 'package:flutter_frontend/presentation/screens/main/widgets/date_label_card.dart';
import 'package:flutter_frontend/presentation/screens/main/widgets/mini_timeline_card.dart';
import 'package:flutter_frontend/presentation/screens/main/widgets/personal_space_card.dart';
import 'package:flutter_frontend/presentation/screens/main/widgets/start_card.dart';
import 'package:flutter_frontend/presentation/screens/settings/widgets/reminder_carousel.dart';
import 'package:flutter_frontend/presentation/screens/memorial/memorial_grid.dart';
import 'package:flutter_frontend/presentation/screens/memorial/new_memorial_screen/relation_memorial_screen.dart';
import 'package:flutter_frontend/presentation/screens/settings/reminders_list_screen.dart';
import 'package:flutter_frontend/presentation/screens/notifications/notifications_screen.dart';
import '../../components/buttons/primary_button.dart';
import '../../components/buttons/secondary_button.dart';
import '../memories/personal_space/personal_space_screen.dart';
import '../memories/personal_space/new_personal_memory_screen.dart';
import '../memories/my_personal_space_screen.dart';
import '../memories/new_reflection_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _memorialService = MemorialService();
  final _reminderService = ReminderService();
  final _notificationService = NotificationService();
  
  late Future<List<Memorial>> _memorialsFuture;
  late Future<List<Reminder>> _remindersFuture;
  int _unreadNotificationsCount = 0;
  
  @override
  void initState() {
    super.initState();
    _memorialsFuture = _memorialService.getMemorials();
    _remindersFuture = _reminderService.getUpcomingReminders(days: 7);
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    try {
      final count = await _notificationService.getUnreadCount();
      setState(() {
        _unreadNotificationsCount = count;
      });
    } catch (e) {
      print('Error loading unread count: $e');
    }
  }

  // Navegación
  void _goToCreateMemorial() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NewMemorialRelationScreen()),
    );
  }
  void _goToPersonalSpace() => Navigator.push(
    context, 
    MaterialPageRoute(builder: (_) => const MyPersonalSpaceScreen()),
  );
  
  void _goToAddMemory() {
    //Botón de arriba
  }
  
  void _goToCreateReflection() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NewReflectionScreen()),
    );
  }
  
  void _openMemorial(Memorial m) {}
  
  void _goToAllReminders() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RemindersListScreen()),
    );
  }

  Future<void> _goToNotifications() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
    // Recargar el contador al volver
    _loadUnreadCount();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(
                'https://i.pravatar.cc/150?img=5',
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                  text: TextSpan(
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.black87),
                    children: const [
                      TextSpan(text: 'Hola, '),
                      TextSpan(
                        text: 'Fer!',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                Text(
                  '¿Qué momento especial quieres guardar hoy?',
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: Colors.black54),
                ),
              ],
            ),
          ],
        ),
        actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Stack(
            clipBehavior: Clip.none, // ✅ Importante para que el badge no se corte
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none),
                onPressed: () {
                  print('🛎️ DEBUG: Campana clickeada');
                  _goToNotifications();
                },
              ),
              // ✅ Badge SOLO si hay notificaciones no leídas
              if (_unreadNotificationsCount > 0)
                Positioned(
                  right: 6,  // ✅ Ajustado para mejor posicionamiento
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      _unreadNotificationsCount > 99 
                          ? '99+' 
                          : _unreadNotificationsCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
      ),
      body: FutureBuilder<List<Memorial>>(
        future: _memorialsFuture,
        builder: (context, memorialsSnap) {
          final widgets = <Widget>[];
          final memorials = memorialsSnap.data ?? <Memorial>[];
          
          if (memorials.isNotEmpty) {
            widgets.add(
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: FilledButton(
                          onPressed: _goToAddMemory,
                          child: const Text('Añadir un recuerdo'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: FilledButton(
                          onPressed: _goToCreateReflection,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                          ),
                          child: const Text('Crear reflexión'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          
          if (memorialsSnap.connectionState == ConnectionState.waiting) {
            widgets.add(const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(child: CircularProgressIndicator()),
            ));
            return ListView(children: widgets);
          }
          
          if (memorials.isEmpty) {
            widgets.addAll([
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: StartCard(onCreate: _goToCreateMemorial),
              ),
              const SizedBox(height: 16),
              const DateLabel(text: '3 de junio'),
            ]);
          } else {
            widgets.addAll([
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: MemorialesHeader(onSeeAll: () {
                  // TODO: navegar a la vista completa de memoriales
                }),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: MemorialGrid(
                  memorials: memorials,
                  onTap: _openMemorial,
                ),
              ),
              const SizedBox(height: 8),
            ]);
          }
          
          // Recordatorios próximos (carrusel)
          widgets.add(
            FutureBuilder<List<Reminder>>(
              future: _remindersFuture,
              builder: (context, remindersSnap) {
                if (remindersSnap.connectionState == ConnectionState.waiting) {
                  return const SizedBox.shrink();
                }
                final reminders = remindersSnap.data ?? <Reminder>[];
                if (reminders.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Column(
                  children: [
                    const SizedBox(height: 8),
                    ReminderCarousel(
                      reminders: reminders,
                      onSeeAll: _goToAllReminders,
                    ),
                  ],
                );
              },
            ),
          );
          
          // Resto de contenido
          widgets.addAll([
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: PersonalSpaceCard(onTap: _goToPersonalSpace),
            ),
            const SizedBox(height: 24),
          ]);
          
          return ListView(children: widgets);
        },
      ),
    );
  }
}

class MemorialesHeader extends StatelessWidget {
  final VoidCallback onSeeAll;
  
  const MemorialesHeader({super.key, required this.onSeeAll});
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Mis Memoriales',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: const Text(
            'Ver todos',
            style: TextStyle(
              color: Color(0xFF6366F1),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class DateLabel extends StatelessWidget {
  final String text;
  
  const DateLabel({super.key, required this.text});
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}