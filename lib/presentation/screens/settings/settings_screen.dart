import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/screens/settings/plans_lirium/get_premium_screen.dart';
import 'package:flutter_frontend/presentation/screens/settings/plans_lirium/subscription_plan_detail_screen.dart';
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
    // Mostrar dialogo de confirmación
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

    if (confirmed == true) {
      setState(() {
        _isLoggingOut = true;
      });

      try {
        // 1) Obtener el correo del usuario autenticado desde el token
        final user = await _authService.getCurrentUser();
        String? currentEmail;
        if (user != null) {
          // Intentar con claves comunes del payload
          currentEmail = (user['email'] ?? user['correo'] ?? user['username'] ?? user['sub'])?.toString();
        }

        // Si no se pudo leer del token, usar el último guardado como fallback
        currentEmail ??= await _authStorage.getLastEmail();

        // 2) Cerrar sesión en backend/servicios
        await _authService.logout();

        // 3) Limpiar tokens/refresh (NO se borrará last_email)
        await _authStorage.clear();

        // 4) Guardar el correo como último email DESPUÉS de limpiar
        if (currentEmail != null && currentEmail.isNotEmpty) {
          await _authStorage.saveLastEmail(currentEmail);
        }

        // 5) Navegar al login y pasar el correo guardado
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => LoginScreen(initialEmail: currentEmail),
          ),
          (route) => false,
        );
      } catch (e) {
        // Manejo de error
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cerrar sesión: $e')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoggingOut = false;
          });
        }
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
                    usedStorageGB: 300,
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