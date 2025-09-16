import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Configuración',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
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
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFF6366F1),
                  child: const Icon(
                    Icons.person,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
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
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Settings sections
          _buildSectionTitle('General'),
          _buildSettingItem(
            icon: Icons.notifications,
            title: 'Notificaciones',
            subtitle: 'Configurar alertas y recordatorios',
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.privacy_tip,
            title: 'Privacidad',
            subtitle: 'Controlar quién ve tus recuerdos',
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.security,
            title: 'Seguridad',
            subtitle: 'Contraseña y autenticación',
            onTap: () {},
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Contenido'),
          _buildSettingItem(
            icon: Icons.backup,
            title: 'Copia de seguridad',
            subtitle: 'Respaldar tus recuerdos',
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.storage,
            title: 'Almacenamiento',
            subtitle: 'Gestionar espacio usado',
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.download,
            title: 'Descargas',
            subtitle: 'Configurar descargas automáticas',
            onTap: () {},
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Soporte'),
          _buildSettingItem(
            icon: Icons.help,
            title: 'Ayuda',
            subtitle: 'Preguntas frecuentes y soporte',
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.info,
            title: 'Acerca de',
            subtitle: 'Versión e información de la app',
            onTap: () {},
          ),
          const SizedBox(height: 24),
          // Logout button
          Container(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Cerrar sesión',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF6366F1), size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
