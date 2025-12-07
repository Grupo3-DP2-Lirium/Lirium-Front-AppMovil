import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../components/common/app_bar.dart';
import '../../../components/common/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  // Función para abrir correo
  void _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'soporte@miapp.com',
      query: 'subject=Soporte%20Mi%20App',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  // Función para abrir página web
  void _launchWebsite() async {
    final Uri url = Uri.parse('https://www.miapp.com');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double appBarHeight = MediaQuery.of(context).size.height * 0.1;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomMemoryAppBar(
        title: "Acerca de",
        onBack: () => Navigator.pop(context),
        showBackButton: true,
        appBarHeight: appBarHeight,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            // Logo + Nombre
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primary
              ,
              backgroundImage: const AssetImage('assets/images/img19.jpg'),
            ),
            const SizedBox(height: 16),
            const Text(
              "Lirium",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),

            // Tarjeta de Versión
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 3,
              child: ListTile(
                leading: const Icon(Icons.info_outline, color: AppColors.primary),
                title: const Text("Versión",
                  style: TextStyle(
                  fontWeight: FontWeight.bold, // Título en negrita
                  fontSize: 16,
                ),),
                subtitle: const Text("1.0.0"),
              ),
            ),
            const SizedBox(height: 16),

            // Tarjeta de Información
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Información de la App",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Esta app ayuda a los usuarios a gestionar sus recuerdos y momentos importantes de manera sencilla y segura. "
                          "Puedes agregar fotos, videos y notas personales para conservar tus memorias.",
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tarjeta de contacto
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 3,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.email, color: AppColors.primary),
                    title: const Text("Correo de soporte", style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),),
                    subtitle: const Text("soporte@lirium.com"),
                    onTap: _launchEmail,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.web, color: AppColors.primary),
                    title: const Text("Sitio web", style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),),
                    subtitle: const Text("www.lirium.com"),
                    onTap: _launchWebsite,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
