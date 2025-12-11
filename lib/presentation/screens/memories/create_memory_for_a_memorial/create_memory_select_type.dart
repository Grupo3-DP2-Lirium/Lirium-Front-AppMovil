import 'package:flutter/material.dart';
import 'package:flutter_frontend/domain/entities/memory.dart';
import 'package:flutter_frontend/presentation/components/common/app_bar.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';
import 'package:flutter_frontend/presentation/screens/memories/create_memory_for_a_memorial/select_category.dart';
import 'package:flutter_frontend/presentation/screens/memories/create_memory_for_a_memorial/upload_pictures_and_videos.dart';
import '../memory_details/memory_detail_screen.dart';
import 'write_letter_screen.dart';

class CreateMemorySelectType extends StatefulWidget {
  final String memorialId;
  final String memorialName;
  final bool isFromMemorial;

  const CreateMemorySelectType({
    super.key,
    required this.memorialId,
    required this.memorialName,
    this.isFromMemorial = false,
  });

  @override
  State<CreateMemorySelectType> createState() => _CreateMemorySelectTypeState();
}

class _CreateMemorySelectTypeState extends State<CreateMemorySelectType> {
  int? _selectedIndex;

  Widget _buildOptionCard({
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isSelected = _selectedIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = index);
        Future.delayed(const Duration(milliseconds: 150), onTap);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.inactive,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                size: 28,
                color: isSelected ? Colors.white : AppColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: isSelected
                          ? Colors.white.withOpacity(0.8)
                          : AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow indicator
            Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomMemoryAppBar(
        title: 'Crear Recuerdo',
        onBack: () => Navigator.pop(context),
        showBackButton: true,
        appBarHeight: MediaQuery.of(context).size.height * 0.09,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withOpacity(0.08),
                        AppColors.primary.withOpacity(0.03),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withOpacity(0.15)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.add_photo_alternate_outlined,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '¿Qué vas a hacer hoy?',
                        style: AppColors.h4.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Elige una opción para crear un nuevo recuerdo',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Section title
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Opciones disponibles',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Options
                _buildOptionCard(
                  index: 0,
                  icon: Icons.photo_camera_outlined,
                  title: 'Subir fotos y videos',
                  subtitle: 'Agrega imágenes o videos desde tu galería',
                  onTap: () async {
                    final result = await Navigator.push<Memory>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MemoryDetailScreen(
                          memory: null,
                          mode: MemoryMode.create,
                          memorialId: widget.memorialId,
                        ),
                      ),
                    );

                    if (result != null && mounted && widget.isFromMemorial) {
                      Navigator.pop(context, result);
                    }
                    setState(() => _selectedIndex = null);
                  },
                ),
                
                const SizedBox(height: 12),
                
                _buildOptionCard(
                  index: 1,
                  icon: Icons.edit_outlined,
                  title: 'Escribir carta',
                  subtitle: 'Escribe un mensaje o carta personal',
                  onTap: () async {
                    final result = await Navigator.push<Memory>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WriteLetterScreen(
                          memorialId: widget.memorialId,
                          memorialName: widget.memorialName,
                        ),
                      ),
                    );

                    if (result != null) {
                      if (widget.isFromMemorial) {
                        Navigator.pop(context, result);
                      } else {
                        Navigator.pop(context);
                        Navigator.pop(context, result);
                      }
                    }
                    setState(() => _selectedIndex = null);
                  },
                ),
                
                const SizedBox(height: 12),
                
                _buildOptionCard(
                  index: 2,
                  icon: Icons.help_outline,
                  title: 'Responder pregunta',
                  subtitle: 'Responde preguntas guiadas sobre el memorial',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SelectCategory(memorialId: widget.memorialId),
                      ),
                    );
                    setState(() => _selectedIndex = null);
                  },
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
