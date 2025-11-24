import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/models/subscription_response.dart';
import 'package:flutter_frontend/data/services/auth_storage.dart';
import 'package:flutter_frontend/data/services/storage_service.dart';
import 'package:flutter_frontend/data/services/subscription_service.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';
import 'package:flutter_frontend/presentation/screens/videos/videos_screen.dart';
import 'package:flutter_frontend/providers/plan_provider.dart';
import 'package:provider/provider.dart';
import '../../../data/services/web_socket_service.dart';
import '../memories/organize_memories/timeline_screen.dart';
import '../memorial/profiles_screen.dart';
import '../memories/memories_grid_screen.dart';
import '../chat/chat_screen.dart';
import '../settings/settings_screen.dart';
import 'home_screen.dart';
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final WebSocketService _webSocketService = WebSocketService();
  final AuthStorage _authStorage = AuthStorage(); // <- instancia aquí

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
    _loadCurrentSubscription();
  }

  Future<void> _loadCurrentSubscription() async {
    try {
      final subscriptionService = SubscriptionService();

      SubscriptionResponse subscription = await subscriptionService.getCurrentSubscription();

      // Imprimir toda la suscripción
      print('📝 Suscripción completa: ${subscription.toJson()}');

      // Obtener permisos también si los necesitas
      final permissions = await subscriptionService.getPlanPermissions(subscription.planId ?? 'FREE_PLAN');
      print('📝 Permisos recibidos: $permissions');

      // Actualizar el provider
      if (mounted) {
        context.read<SubscriptionProvider>().setFromLogin(
          subscription: subscription,
          permissions: permissions,
          extraStorage: subscription.extraStorage ?? [],
        );
      }

      print('✅ SubscriptionProvider actualizado con plan: ${subscription.planName}');
    } catch (e) {
      print('❌ Error cargando suscripción: $e');
    }
  }

  Future<void> _connectWebSocket() async {
    final token = await _authStorage.readAccess(); // <- obtiene el token guardado
    if (token != null && token.isNotEmpty) {
      _webSocketService.connect(token, (message) {
        print("Mensaje recibido: $message");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("🔔 $message"),
            duration: const Duration(seconds: 3),
          ),
        );
      });
    }
  }


  @override
  void dispose() {
    // Desconectar al salir
    _webSocketService.disconnect();
    super.dispose();
  }

  void _changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  List<Widget> get _screens => [
    HomeScreen(onTabChange: _changeTab),
    const ProfilesScreen(),
    const MemoriesGridScreen(),
    const VideosScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: _changeTab,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Memoriales'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'Recuerdos'),
          BottomNavigationBarItem(icon: Icon(Icons.movie_creation_outlined), label: 'Videos'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outlined), label: 'Cuenta'),
        ],
      ),
    );
  }
}
