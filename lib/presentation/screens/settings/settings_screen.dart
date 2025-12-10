import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/services/storage_service.dart';
import 'package:flutter_frontend/data/services/http_service.dart';
import 'package:flutter_frontend/data/services/http_client.dart';
import 'package:flutter_frontend/data/services/firebase_messaging_service.dart';
import 'package:flutter_frontend/presentation/screens/settings/plans_lirium/extra_documentales_screen.dart';
import 'package:flutter_frontend/presentation/screens/settings/plans_lirium/get_premium_screen.dart';
import 'package:flutter_frontend/presentation/screens/settings/plans_lirium/subscription_plan_detail_screen.dart';
import 'package:flutter_frontend/presentation/screens/settings/reminders_list_screen.dart';
import 'package:flutter_frontend/providers/memorial_provider.dart';
import 'package:flutter_frontend/providers/memory_provider.dart';
import 'package:flutter_frontend/providers/documentary_provider.dart';
import 'package:flutter_frontend/providers/capsule_provider.dart';
import 'package:flutter_frontend/providers/reflection_provider.dart';
import 'package:flutter_frontend/providers/plan_provider.dart';
import 'package:flutter_frontend/providers/memories_by_memorial_provider.dart';
import 'package:provider/provider.dart';
import '../../../providers/user_provider.dart';
import '../../components/common/app_bar.dart';
import '../../components/components.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/auth_storage.dart';
import '../auth/login_screen.dart';
import '../reminders/notifications_settings_screen.dart';
import 'about_app/about_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  final AuthStorage _authStorage = AuthStorage();

  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadUser();
    });
  }

  Future<void> _logout() async {
  // Mostrar diálogo de confirmación
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Cerrar sesión'),
      content: const Text('¿Estás seguro que deseas cerrar sesión?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Cerrar sesión', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );

  if (confirmed != true) return;

  setState(() {
    _isLoggingOut = true;
  });

  try {
    // 1. Obtener email actual ANTES de limpiar
    final user = await _authService.getCurrentUser();
    String? currentEmail;
    if (user != null) {
      currentEmail = (user['email'] ?? user['correo'] ?? user['username'] ?? user['sub'])?.toString();
    }
    currentEmail ??= await _authStorage.getLastEmail();

    // 2. Cerrar sesión en backend
    try {
      await _authService.logout();
    } catch (e) {
      print('⚠️ Error en logout del backend: $e');
      // Continuar de todas formas
    }

    // 3️. Limpiar TODOS los tokens y storage
    await _authStorage.clear();
    await StorageService.clearAll(); // ✅ LIMPIA TODO el storage seguro
    
    // 4️. Guardar solo el email para prellenar
    if (currentEmail != null && currentEmail.isNotEmpty) {
      await _authStorage.saveLastEmail(currentEmail);
    }

    // 5️. LIMPIAR HTTP SERVICES (tokens)
    HttpService().clearToken();
    HttpClient.resetInstance();
    print('✅ HTTP Services limpiados');

    // 6️. DESREGISTRAR FCM TOKEN
    try {
      final fcmService = FirebaseMessagingService();
      await fcmService.unregisterToken();
      print('✅ FCM Token desregistrado');
    } catch (e) {
      print('⚠️ Error desregistrando FCM token: $e');
    }

    // 7️. LIMPIAR TODOS LOS PROVIDERS
    if (!mounted) return;
    
    // Limpiar MemorialProvider
    final memorialProvider = Provider.of<MemorialProvider>(context, listen: false);
    memorialProvider.limpiarTodo();
    
    // Limpiar MemoryProvider
    final memoryProvider = Provider.of<MemoryProvider>(context, listen: false);
    memoryProvider.limpiarTodo();
    
    // Limpiar DocumentaryProvider
    final documentaryProvider = Provider.of<DocumentaryProvider>(context, listen: false);
    documentaryProvider.limpiarTodo();
    
    // Limpiar CapsuleProvider
    final capsuleProvider = Provider.of<CapsuleProvider>(context, listen: false);
    capsuleProvider.limpiarTodo();
    
    // Limpiar ReflectionProvider
    final reflectionProvider = Provider.of<ReflectionProvider>(context, listen: false);
    reflectionProvider.limpiarTodo();
    
    // Limpiar SubscriptionProvider
    final subscriptionProvider = Provider.of<SubscriptionProvider>(context, listen: false);
    subscriptionProvider.limpiarTodo();
    
    // Limpiar MemoriesByMemorialProvider
    final memoriesByMemorialProvider = Provider.of<MemoriesByMemorialProvider>(context, listen: false);
    memoriesByMemorialProvider.clear();
    
    print('✅ Todos los providers limpiados');

    // 6️⃣ Navegar al login
    if (!mounted) return;
    
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => LoginScreen(initialEmail: currentEmail),
      ),
      (route) => false, // Eliminar TODO el stack
    );

    print('✅ Logout completado exitosamente');
    
  } catch (e) {
    print('❌ Error en logout: $e');
    
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error al cerrar sesión: $e'),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    if (mounted) {
      setState(() {
        _isLoggingOut = false;
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    final userProv = context.watch<UserProvider>();
    final name = userProv.name ?? '';
    final photoUrl = userProv.photoUrl;
    final email = userProv.email ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomMemoryAppBar(
        title: 'Configuración',
        onBack: () => Navigator.pop(context),
        showBackButton: false,
        appBarHeight: 70,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                ProfileAvatar(
                  radius: 30,
                  photoUrl: photoUrl,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        email,
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Settings sections
          const Text(
            'General',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          SettingItem(
            icon: Icons.notifications,
            title: 'Notificaciones',
            subtitle: 'Configura las notificaciones que recibes',
            onTap: () {},
          ),
          SettingItem(
            icon: Icons.notifications,
            title: 'Recordatorios',
            subtitle: 'Gestiona tus recordatorios',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RemindersListScreen(),
                ),
              );
            },
          ),
          SettingItem(
            icon: Icons.security,
            title: 'Seguridad',
            subtitle: 'Contraseña y autenticación',
            onTap: () {},
          ),
          const SizedBox(height: 24),

          const Text(
            'Contenido',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          SettingItem(
            icon: Icons.backup,
            title: 'Copia de seguridad',
            subtitle: 'Respaldar tus recuerdos',
            onTap: () {},
          ),
          SettingItem(
            icon: Icons.monetization_on,
            title: 'Plan Lirium',
            subtitle: 'Gestiona tu plan',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SubscriptionPlanDetailsScreen(),
                ),
              );
            },
          ),
          SettingItem(
            icon: Icons.monetization_on,
            title: 'Extra Documentales',
            subtitle: 'Gestiona tus documentales extra',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExtraDocumentalesScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          const Text(
            'Soporte',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          SettingItem(
            icon: Icons.help,
            title: 'Ayuda',
            subtitle: 'Preguntas frecuentes y soporte',
            onTap: () {},
          ),
          SettingItem(
            icon: Icons.info,
            title: 'Acerca de',
            subtitle: 'Versión e información de la app',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AboutScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Logout button
          _isLoggingOut
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(color: Colors.red),
                  ),
                )
              : SecondaryButton(
                  text: 'Cerrar sesión',
                  textColor: Colors.red,
                  isOutlined: true,
                  onPressed: _logout,
                ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}