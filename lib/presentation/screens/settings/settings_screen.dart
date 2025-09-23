import 'package:flutter/material.dart';
import '../../components/components.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
            onTap: () {},
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
            icon: Icons.storage,
            title: 'Almacenamiento',
            subtitle: 'Gestionar espacio usado',
            onTap: () {},
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
          SecondaryButton(
            text: 'Cerrar sesión',
            textColor: Colors.red,
            isOutlined: true,
            onPressed: () {},
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
