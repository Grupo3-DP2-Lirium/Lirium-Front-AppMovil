import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';
import 'package:flutter_frontend/presentation/screens/support/report_help_screen.dart';

class ReportReasonsScreen extends StatefulWidget {
  final String reportedUserId;
  final String reportedUserName;
  final String memorialId;
  final String memorialName;

  const ReportReasonsScreen({
    super.key,
    required this.reportedUserId,
    required this.reportedUserName,
    required this.memorialId,
    required this.memorialName,
  });

  @override
  State<ReportReasonsScreen> createState() => _ReportReasonsScreenState();
}

class _ReportReasonsScreenState extends State<ReportReasonsScreen> {
  String? selectedReason;

  final List<Map<String, dynamic>> reasons = [
    {
      'id': 'INAPPROPRIATE_CONTENT',
      'title': 'Uso indebido de contenido personal y sensible',
      'icon': Icons.warning_outlined,
      'color': Colors.orange,
    },
    {
      'id': 'HARASSMENT',
      'title': 'Manipulación o alteración malintencionada de recuerdos',
      'icon': Icons.person_off_outlined,
      'color': Colors.red,
    },
    {
      'id': 'SPAM',
      'title': 'Conducta inapropiada o irrespetuosa de la colaboración',
      'icon': Icons.block_outlined,
      'color': Colors.purple,
    },
    {
      'id': 'PRIVACY_VIOLATION',
      'title': 'Incumplimiento de reglas de la plataforma',
      'icon': Icons.privacy_tip_outlined,
      'color': Colors.blue,
    },
    {
      'id': 'UNAUTHORIZED_ACCESS',
      'title': 'Acceso no autorizado o uso fraudulento',
      'icon': Icons.security_outlined,
      'color': Colors.indigo,
    },
    {
      'id': 'IDENTITY_THEFT',
      'title': 'Suplantación de identidad en recuerdos compartidos',
      'icon': Icons.person_search_outlined,
      'color': Colors.teal,
    },
    {
      'id': 'OTHER',
      'title': 'Suplantación de identidad en recuerdos compartidos',
      'icon': Icons.more_horiz_outlined,
      'color': Colors.grey,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Motivos',
          style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black87),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: reasons.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final reason = reasons[index];
                final isSelected = selectedReason == reason['id'];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedReason = reason['id'];
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.grey.withValues(alpha: 0.3),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: (reason['color'] as Color).withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            reason['icon'],
                            color: reason['color'],
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            reason['title'],
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: isSelected ? AppColors.primary : Colors.grey,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Botón continuar
          Container(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedReason != null
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReportHelpScreen(
                              reportedUserId: widget.reportedUserId,
                              reportedUserName: widget.reportedUserName,
                              memorialId: widget.memorialId,
                              memorialName: widget.memorialName,
                              selectedReason: selectedReason!,
                              reasonTitle: reasons.firstWhere(
                                (r) => r['id'] == selectedReason,
                              )['title'],
                            ),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedReason != null
                      ? AppColors.primary
                      : Colors.grey.withValues(alpha: 0.3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continuar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
