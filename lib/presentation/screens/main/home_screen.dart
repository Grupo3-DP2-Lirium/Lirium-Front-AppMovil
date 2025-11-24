import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/services/memorial_service.dart';
import 'package:flutter_frontend/data/services/reminder_service.dart';
import 'package:flutter_frontend/data/services/notification_service.dart';
import 'package:flutter_frontend/data/services/storage_service.dart';
import 'package:flutter_frontend/domain/entities/memorial.dart';
import 'package:flutter_frontend/domain/entities/memory.dart';
import 'package:flutter_frontend/domain/entities/reminder.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';
import 'package:flutter_frontend/presentation/screens/settings/plans_lirium/get_premium_screen.dart';
import 'package:flutter_frontend/presentation/screens/settings/widgets/reminder_carousel.dart';
import 'package:flutter_frontend/presentation/screens/memorial/new_memorial_screen/relation_memorial_screen.dart';
import 'package:flutter_frontend/presentation/screens/settings/reminders_list_screen.dart';
import 'package:flutter_frontend/presentation/screens/notifications/notifications_screen.dart';
import 'package:flutter_frontend/providers/memory_provider.dart';
import 'package:flutter_frontend/providers/plan_provider.dart';
import 'package:provider/provider.dart';
import '../memories/my_personal_space_screen.dart';
import '../memories/new_reflection_screen.dart';
import '../memories/memories_grid_screen.dart';
import '../memorial/profiles_screen.dart';
import '../memorial/memorial_detail_screen.dart';
import '../memories/create_memory_for_a_memorial/create_memory_to_memorial.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onTabChange;
  const HomeScreen({super.key, this.onTabChange});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _memorialService = MemorialService();
  final _reminderService = ReminderService();
  final _notificationService = NotificationService();
  String? _currentEmail;
  String? _currentName;
  late Future<List<Memorial>> _memorialsFuture;
  late Future<List<Reminder>> _remindersFuture;
  int _unreadNotificationsCount = 0;

  Future<void> _loadUserData() async {
    try {
      final email = await StorageService.getEmail();
      print("Email guardado del usuario: $email");
      final name = await StorageService.getName();
      print("Email guardado del usuario: $name");

      setState(() {
        _currentEmail = email;
        _currentName = name;
      });
    } catch (e, stack) {
      print("Error cargando usuario: $e");
      print(stack);
      _currentName = null;
      _currentEmail = null;
    }
  }

  @override
  void initState() {
    super.initState();
    _memorialsFuture = _memorialService.getMemorials();
    _remindersFuture = _reminderService.getUpcomingReminders(days: 7);
    _loadUnreadCount();
    _loadUserData();
  }

  Future<void> _loadUnreadCount() async {
    try {
      final count = await _notificationService.getUnreadCount();
      if (mounted) {
        setState(() {
          _unreadNotificationsCount = count;
        });
      }
    } catch (e) {
      print('Error loading unread count: $e');
    }
  }

  Future<void> _goToCreateMemory() async {
    final prov = context.read<MemoryProvider>();

    final createdMemory = await Navigator.push<Memory>(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateMemoryToMemorial(),
      ),
    );

    if (createdMemory != null) {
      prov.agregarMemoria(createdMemory);
    }
  }


  Future<void> _goToNotifications() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
    _loadUnreadCount();
  }

  void _goToCreateMemorial() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NewMemorialRelationScreen()),
    );
  }

  void _goToPersonalSpace() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MyPersonalSpaceScreen()),
    );
  }

  void _goToCreateReflection() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NewReflectionScreen()),
    );
  }

  void _goToAllReminders() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RemindersListScreen()),
    );
  }

  void _openMemorial(Memorial m) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MemorialDetailScreen(memorialId: m.idMemorial),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subProvider = context.watch<SubscriptionProvider>();

    if (!subProvider.isLoaded) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App Bar con diseño clean
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            expandedHeight: 100,
            flexibleSpace: FlexibleSpaceBar(
              background: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: const CircleAvatar(
                          radius: 22,
                          backgroundImage: NetworkImage(
                            'https://i.pravatar.cc/150?img=5',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Saludo + pregunta al lado del avatar
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 24,
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Inter',
                                ),
                                children: [
                                  const TextSpan(text: 'Hola, '),
                                  TextSpan(
                                    text: _currentName ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const TextSpan(text: ' 👋'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '¿Qué momento quieres guardar hoy?',
                              style: AppColors.bodySmall.copyWith(
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),


                      // Botón de notificaciones
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.notifications_outlined),
                              onPressed: _goToNotifications,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (_unreadNotificationsCount > 0)
                            Positioned(
                              right: 6,
                              top: 6,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.error,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 18,
                                  minHeight: 18,
                                ),
                                child: Text(
                                  _unreadNotificationsCount > 9
                                      ? '9+'
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
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ✨ CONTENIDO PRINCIPAL
          SliverToBoxAdapter(
            child: FutureBuilder<List<Memorial>>(
              future: _memorialsFuture,
              builder: (context, memorialsSnap) {
                if (memorialsSnap.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  );
                }

                final memorials = memorialsSnap.data ?? <Memorial>[];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✨ SECCIÓN: Estado vacío o acciones rápidas
                    if (memorials.isEmpty)
                      _buildEmptyState(subProvider)
                    else
                      _buildQuickActions(subProvider),

                    const SizedBox(height: 24),

                    // ✨ SECCIÓN: Mis Memoriales
                    if (memorials.isNotEmpty) ...[
                      _buildSectionHeader(
                        'Mis Memoriales',
                        'Tus legados digitales con valor emocional',
                        icon: Icons.favorite_border,
                          onSeeAll: () {
                            widget.onTabChange?.call(1); // Ir al tab de Memoriales
                          }
                      ),
                      const SizedBox(height: 16),
                      _buildMemorialsList(memorials, subProvider),
                      const SizedBox(height: 32),
                    ],

                    // ✨ SECCIÓN: Recordatorios
                    FutureBuilder<List<Reminder>>(
                      future: _remindersFuture,
                      builder: (context, remindersSnap) {
                        final reminders = remindersSnap.data ?? <Reminder>[];
                        if (reminders.isEmpty) return const SizedBox.shrink();

                        return Column(
                          children: [
                            _buildSectionHeader(
                              'Próximos Recordatorios',
                              'Momentos especiales que no querrás olvidar',
                              icon: Icons.event_outlined,
                              onSeeAll: _goToAllReminders,
                            ),
                            const SizedBox(height: 16),
                            ReminderCarousel(
                              reminders: reminders,
                              onSeeAll: _goToAllReminders,
                            ),
                            const SizedBox(height: 32),
                          ],
                        );
                      },
                    ),

                    // ✨ SECCIÓN: Crea tu contenido
                    //_buildContentCreationSection(),
                    //const SizedBox(height: 32),

                    // ✨ SECCIÓN: Mi Espacio Personal
                    _buildPersonalSpaceCard(),
                    const SizedBox(height: 32),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ESTADO VACÍO - Primera impresión
  Widget _buildEmptyState(SubscriptionProvider subProvider) {
    final hasPremiumPermission = subProvider.permissions.contains("CREATE_MEMORIALS");

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.08),
            AppColors.secondary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Comienza tu legado digital',
            style: AppColors.h4,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.favorite,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Crea tu primer memorial para preservar los recuerdos que más valoras y construye una memoria colaborativa con valor emocional',
            style: AppColors.bodyMedium.copyWith(
              color: Colors.grey[700],
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: Opacity(
              opacity: hasPremiumPermission ? 1.0 : 0.6,
              child: ElevatedButton(
                onPressed: hasPremiumPermission
                    ? _goToCreateMemorial
                    : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GetPremiumScreen()),
                  ).then((_) async {
                    await subProvider.refreshPlan();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_circle_outline, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      'Crear mi primer memorial',
                      style: AppColors.labelLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ACCIONES RÁPIDAS
  Widget _buildQuickActions(SubscriptionProvider subProvider) {
    final hasPremiumPermission = subProvider.permissions.contains("CREATE_MEMORIALS");

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              icon: Icons.photo_library_outlined,
              label: 'Añadir\nrecuerdo',
              color: AppColors.primary,
              onTap: hasPremiumPermission
                  ? _goToCreateMemory
                  : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GetPremiumScreen()),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              icon: Icons.edit_note_outlined,
              label: 'Crear\nreflexión',
              color: AppColors.accent,
              onTap: hasPremiumPermission
                  ? _goToCreateReflection
                  : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GetPremiumScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.2),
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
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 10),
            Text(
              label,
              style: AppColors.labelSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  // ✨ HEADER DE SECCIÓN
  Widget _buildSectionHeader(
      String title,
      String subtitle, {
        IconData? icon,
        VoidCallback? onSeeAll,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 22, color: AppColors.primary),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(title, style: AppColors.h5),
              ),
              if (onSeeAll != null)
                TextButton(
                  onPressed: onSeeAll,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: Text(
                    'Ver todos',
                    style: AppColors.labelMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: AppColors.bodySmall.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // ✨ LISTA DE MEMORIALES (Horizontal Carousel)
  Widget _buildMemorialsList(List<Memorial> memorials, SubscriptionProvider subProvider) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: memorials.length + 1,
        itemBuilder: (context, index) {
          if (index == memorials.length) {
            return _buildCreateMemorialCard(subProvider);
          }

          final memorial = memorials[index];
          return Padding(
            padding: const EdgeInsets.only(right: 14),
            child: _buildMemorialCard(memorial),
          );
        },
      ),
    );
  }

  Widget _buildMemorialCard(Memorial memorial) {
    return GestureDetector(
      onTap: () => _openMemorial(memorial),
      child: Container(
        width: 170,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen con overlay gradient
            Stack(
              children: [
                Container(
                  height: 140,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    color: Colors.grey[200],
                    image: memorial.profilePhotoUrl != null
                        ? DecorationImage(
                      image: NetworkImage(memorial.profilePhotoUrl!),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: memorial.profilePhotoUrl == null
                      ? Center(
                    child: Icon(
                      Icons.person_outline,
                      size: 56,
                      color: Colors.grey[400],
                    ),
                  )
                      : null,
                ),
                // Gradient overlay sutil
                Container(
                  height: 140,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.1),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Info del memorial
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    memorial.name,
                    style: AppColors.labelMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    memorial.nickname.isEmpty
                        ? memorial.relation
                        : memorial.nickname,
                    style: AppColors.bodySmall.copyWith(
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateMemorialCard(SubscriptionProvider subProvider) {
    final hasPremiumPermission = subProvider.permissions.contains("CREATE_MEMORIALS");

    return GestureDetector(
      onTap: hasPremiumPermission
          ? _goToCreateMemorial
          : () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GetPremiumScreen()),
        );
      },
      child: Opacity(
        opacity: hasPremiumPermission ? 1.0 : 0.6, // visualmente deshabilitado si no tiene permiso
        child: Container(
          width: 170,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColors.primary.withOpacity(0.08),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_rounded,
                  size: 36,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Crear nuevo\nmemorial',
                style: AppColors.labelMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✨ SECCIÓN: Creación de Contenido
  Widget _buildContentCreationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.auto_awesome_outlined,
                    size: 22,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Text('Crea tu contenido', style: AppColors.h5),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Múltiples formatos para preservar tus recuerdos',
                style: AppColors.bodySmall.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Grid de opciones
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildContentTypeCard(
                icon: Icons.photo_library_outlined,
                title: 'Fotos',
                color: AppColors.primary,
                onTap: () {
                  // TODO: Añadir fotos
                },
              ),
              _buildContentTypeCard(
                icon: Icons.videocam_outlined,
                title: 'Videos',
                color: AppColors.accent,
                onTap: () {
                  // TODO: Añadir videos
                },
              ),
              _buildContentTypeCard(
                icon: Icons.mic_outlined,
                title: 'Audios',
                color: AppColors.secondary,
                onTap: () {
                  // TODO: Añadir audios
                },
              ),
              _buildContentTypeCard(
                icon: Icons.description_outlined,
                title: 'Textos',
                color: AppColors.primary2,
                onTap: () {
                  // TODO: Añadir textos
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContentTypeCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.15),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: AppColors.labelMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✨ CARD: Mi Espacio Personal
  Widget _buildPersonalSpaceCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: _goToPersonalSpace,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.accent,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.psychology_outlined,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Privado',
                          style: AppColors.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.lock_outline,
                          color: Colors.white,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Mi Espacio Personal',
                style: AppColors.h4.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tu refugio íntimo para reflexiones, pensamientos y recuerdos que son solo tuyos',
                style: AppColors.bodyMedium.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    'Explorar',
                    style: AppColors.labelLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}