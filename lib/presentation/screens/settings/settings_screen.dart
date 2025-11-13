import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/services/storage_service.dart';
import 'package:flutter_frontend/presentation/screens/settings/plans_lirium/get_premium_screen.dart';
import 'package:flutter_frontend/presentation/screens/settings/plans_lirium/subscription_plan_detail_screen.dart';
import 'package:flutter_frontend/providers/memorial_provider.dart';
import 'package:provider/provider.dart';
import '../../components/components.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/auth_storage.dart';
import '../auth/login_screen.dart';
import '../reminders/notifications_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  final AuthStorage _authStorage = AuthStorage();
  bool _isLoggingOut = false;

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
    // 1️⃣ Obtener email actual ANTES de limpiar
    final user = await _authService.getCurrentUser();
    String? currentEmail;
    if (user != null) {
      currentEmail = (user['email'] ?? user['correo'] ?? user['username'] ?? user['sub'])?.toString();
    }
    currentEmail ??= await _authStorage.getLastEmail();

    // 2️⃣ Cerrar sesión en backend
    try {
      await _authService.logout();
    } catch (e) {
      print('⚠️ Error en logout del backend: $e');
      // Continuar de todas formas
    }

    // 3️⃣ Limpiar TODOS los tokens y storage
    await _authStorage.clear();
    await StorageService.clearAll(); // ✅ LIMPIA TODO el storage seguro
    
    // 4️⃣ Guardar solo el email para prellenar
    if (currentEmail != null && currentEmail.isNotEmpty) {
      await _authStorage.saveLastEmail(currentEmail);
    }

    // 5️⃣ ✅ LIMPIAR TODOS LOS PROVIDERS
    if (!mounted) return;
    
    // Limpiar MemorialProvider
    final memorialProvider = Provider.of<MemorialProvider>(context, listen: false);
    memorialProvider.limpiarTodo();
    
    // Limpiar otros providers si existen
    // final memoryProvider = Provider.of<MemoryProvider>(context, listen: false);
    // memoryProvider.limpiarTodo();
    
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Configuración',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
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
            child: const Row(
              children: [
                ProfileAvatar(radius: 30),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Juan Pérez',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'juan.perez@email.com',
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
            subtitle: 'Configurar alertas y recordatorios',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationsSettingsScreen(),
                ),
              );
            },
          ),
          SettingItem(
            icon: Icons.privacy_tip,
            title: 'Privacidad',
            subtitle: 'Controlar quién ve tus recuerdos',
            onTap: () {},
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
                  builder: (context) => SubscriptionPlanDetailsScreen(
                    usedStorageGB: 2,
                    totalStorageGB: 500,
                  ),
                ),
              );
            },
          ),
          SettingItem(
            icon: Icons.monetization_on,
            title: 'Se Premium',
            subtitle: 'Adquiere tu plan',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GetPremiumScreen(),
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
            onTap: () {},
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