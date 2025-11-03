import 'package:flutter/material.dart';
import 'package:flutter_frontend/domain/entities/reminder.dart';
import 'package:flutter_frontend/presentation/screens/main/widgets/mini_timeline_card.dart';

class ReminderCarousel extends StatefulWidget {
  final List<Reminder> reminders;
  final VoidCallback onSeeAll;

  const ReminderCarousel({
    super.key,
    required this.reminders,
    required this.onSeeAll,
  });

  @override
  State<ReminderCarousel> createState() => _ReminderCarouselState();
}

class _ReminderCarouselState extends State<ReminderCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _formatReminderDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final reminderDay = DateTime(date.year, date.month, date.day);

    if (reminderDay == today) {
      return 'Hoy';
    } else if (reminderDay == tomorrow) {
      return 'Mañana';
    } else {
      final difference = reminderDay.difference(today).inDays;
      if (difference > 0 && difference < 7) {
        return 'En $difference días';
      } else {
        // Formato: "15 de enero"
        const months = [
          'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
          'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
        ];
        return '${date.day} de ${months[date.month - 1]}';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.reminders.isEmpty) {
      return const SizedBox.shrink();
    }

    // Mostrar solo los primeros 5 recordatorios
    final displayReminders = widget.reminders.take(5).toList();
    final hasMore = widget.reminders.length > 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Carrusel de recordatorios
        SizedBox(
          height: 100,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: displayReminders.length,
            itemBuilder: (context, index) {
              final reminder = displayReminders[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: MiniTimelineCard(
                  title: _formatReminderDate(reminder.notificationDate),
                  subtitle: reminder.title,
                  onTap: () {
                    // TODO: Navegar a detalles del recordatorio o editarlo
                  },
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Indicadores de página + botón "Ver todos"
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Dots indicadores
              Row(
                children: List.generate(
                  displayReminders.length,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index
                          ? const Color(0xFF6366F1)
                          : Colors.grey[300],
                    ),
                  ),
                ),
              ),
              
              // Botón "Ver todos" si hay más recordatorios
              if (hasMore)
                TextButton(
                  onPressed: widget.onSeeAll,
                  child: const Text(
                    'Ver todos',
                    style: TextStyle(
                      color: Color(0xFF6366F1),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}