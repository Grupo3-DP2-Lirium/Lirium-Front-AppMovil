import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../../data/services/auth_event_service.dart';
import '../../providers/memorial_provider.dart';
import '../../providers/memory_provider.dart';
import '../../providers/documentary_provider.dart';
import '../../providers/capsule_provider.dart';
import '../../providers/reflection_provider.dart';
import '../../providers/plan_provider.dart';
import '../../providers/memories_by_memorial_provider.dart';
import '../../providers/user_provider.dart';
import '../screens/auth/login_screen.dart';

/// Widget que escucha eventos de autenticación globalmente
class AuthListenerWrapper extends StatefulWidget {
  final Widget child;

  const AuthListenerWrapper({super.key, required this.child});

  @override
  State<AuthListenerWrapper> createState() => _AuthListenerWrapperState();
}

class _AuthListenerWrapperState extends State<AuthListenerWrapper> {
  StreamSubscription<AuthEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    _listenToAuthEvents();
  }

  void _listenToAuthEvents() {
    print('👂 AuthListenerWrapper: Iniciando escucha de eventos');
    _subscription = AuthEventService().events.listen((event) {
      print('📬 AuthListenerWrapper: Evento recibido: $event');
      if (!mounted) {
        print('⚠️ AuthListenerWrapper: Widget no montado, ignorando evento');
        return;
      }

      switch (event) {
        case AuthEvent.accountSuspended:
          print('🚫 AuthListenerWrapper: Manejando cuenta suspendida');
          _handleAccountSuspended();
          break;
        case AuthEvent.tokenExpired:
          print('🔓 AuthListenerWrapper: Manejando token expirado');
          _handleTokenExpired();
          break;
        case AuthEvent.loggedOut:
          print('👋 AuthListenerWrapper: Manejando logout');
          _handleLoggedOut();
          break;
      }
    });
  }

  /// Limpia todos los providers para evitar que datos de un usuario
  /// permanezcan cuando otro usuario inicia sesión
  void _clearAllProviders() {
    try {
      print('🧹 AuthListenerWrapper: Limpiando todos los providers...');

      // Limpiar UserProvider
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.logout();

      // Limpiar MemorialProvider
      final memorialProvider = Provider.of<MemorialProvider>(
        context,
        listen: false,
      );
      memorialProvider.limpiarTodo();

      // Limpiar MemoryProvider
      final memoryProvider = Provider.of<MemoryProvider>(
        context,
        listen: false,
      );
      memoryProvider.limpiarTodo();

      // Limpiar DocumentaryProvider
      final documentaryProvider = Provider.of<DocumentaryProvider>(
        context,
        listen: false,
      );
      documentaryProvider.limpiarTodo();

      // Limpiar CapsuleProvider
      final capsuleProvider = Provider.of<CapsuleProvider>(
        context,
        listen: false,
      );
      capsuleProvider.limpiarTodo();

      // Limpiar ReflectionProvider
      final reflectionProvider = Provider.of<ReflectionProvider>(
        context,
        listen: false,
      );
      reflectionProvider.limpiarTodo();

      // Limpiar SubscriptionProvider
      final subscriptionProvider = Provider.of<SubscriptionProvider>(
        context,
        listen: false,
      );
      subscriptionProvider.limpiarTodo();

      // Limpiar MemoriesByMemorialProvider
      final memoriesByMemorialProvider =
          Provider.of<MemoriesByMemorialProvider>(context, listen: false);
      memoriesByMemorialProvider.clear();

      print('✅ AuthListenerWrapper: Todos los providers limpiados');
    } catch (e) {
      print('❌ AuthListenerWrapper: Error limpiando providers: $e');
    }
  }

  void _handleAccountSuspended() {
    print('💬 AuthListenerWrapper: Mostrando diálogo de cuenta suspendida');

    // Limpiar providers antes de mostrar el diálogo
    _clearAllProviders();

    // Mostrar diálogo
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Cuenta Suspendida'),
        content: const Text(
          'Tu cuenta ha sido suspendida por un administrador. '
          'Por favor, contacta al soporte para más información.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              print('✅ Usuario presionó Entendido');
              Navigator.of(context).pop();
              _navigateToLogin();
            },
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _handleTokenExpired() {
    // Limpiar todos los providers antes de mostrar el mensaje
    _clearAllProviders();

    // Mostrar snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Tu sesión ha expirado. Por favor, inicia sesión nuevamente.',
        ),
        duration: Duration(seconds: 3),
      ),
    );

    // Navegar al login después de un delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _navigateToLogin();
      }
    });
  }

  void _handleLoggedOut() {
    // Limpiar todos los providers antes de navegar
    _clearAllProviders();
    _navigateToLogin();
  }

  void _navigateToLogin() {
    print('🏠 AuthListenerWrapper: Navegando al login');
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
    print('✅ AuthListenerWrapper: Navegación completada');
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
