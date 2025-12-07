import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';
import 'package:flutter_frontend/presentation/screens/memorial/widgets/memorial_details_state.dart';
import 'package:intl/intl.dart';

class InfoTab extends StatelessWidget {
  final MemorialDetailsState detailsState;

  const InfoTab({
    super.key,
    required this.detailsState,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título de sección
          Text('Información Personal', style: AppColors.h5),
          const SizedBox(height: 20),

          // Cards de información
          if (detailsState.birthDate != null) _buildInfoCard(
            icon: Icons.cake_rounded,
            label: 'Fecha de nacimiento',
            value: _formatDate(detailsState.birthDate!),
            color: Colors.pink,
          ),

          if (detailsState.gender != null) _buildInfoCard(
            icon: Icons.person_rounded,
            label: 'Género',
            value: _getGenderText(detailsState.gender!),
            color: Colors.purple,
          ),

          if (detailsState.nickname != null && detailsState.nickname!.isNotEmpty)
            _buildInfoCard(
              icon: Icons.star_rounded,
              label: 'Apodo',
              value: detailsState.nickname!,
              color: Colors.orange,
            ),

          if (detailsState.relation.isNotEmpty) _buildInfoCard(
            icon: Icons.favorite_rounded,
            label: 'Relación',
            value: detailsState.relation,
            color: AppColors.primary,
          ),

          // Descripción expandida (si existe)
          if (detailsState.description != null && detailsState.description!.isNotEmpty) ...[
            const SizedBox(height: 32),
            Text('Sobre ${detailsState.name}', style: AppColors.h5),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                detailsState.description!,
                style: AppColors.bodyLarge.copyWith(height: 1.6),
              ),
            ),
          ],

          const SizedBox(height: 32),

          // Estadísticas (placeholder - se puede agregar más tarde)
          /*Text('Estadísticas', style: AppColors.h5),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.photo_library_rounded,
                  value: '0',
                  label: 'Recuerdos',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.people_rounded,
                  value: detailsState.isCollaborative ? '1+' : '1',
                  label: 'Colaboradores',
                  color: Colors.green,
                ),
              ),
            ],
          ),*/
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppColors.labelSmall.copyWith(fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppColors.labelLarge.copyWith(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppColors.h4.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppColors.labelMedium.copyWith(
              color: color,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('d MMMM yyyy', 'es').format(date);
    } catch (e) {
      // Si falla el parsing, devolver el string original o formatearlo de otra manera
      return dateStr;
    }
  }

  String _getGenderText(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return 'Masculino';
      case 'female':
        return 'Femenino';
      case 'other':
        return 'Otro';
      default:
        return gender;
    }
  }
}