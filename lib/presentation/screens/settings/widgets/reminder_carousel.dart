import 'package:flutter/material.dart';
import 'package:flutter_frontend/domain/entities/reminder.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';

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

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
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
          height: 90,
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
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildReminderCard(reminder),
              );
            },
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Indicadores de página + botón "Ver todos"
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
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
                          ? AppColors.primary
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
                      color: AppColors.primary,
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

  Widget _buildReminderCard(Reminder reminder) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icono
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.event,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Contenido
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  reminder.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      _formatReminderDate(reminder.notificationDate),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      ' • ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                    ),
                    Text(
                      _formatTime(reminder.notificationDate),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}