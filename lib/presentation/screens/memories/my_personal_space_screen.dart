import 'dart:io';
import 'package:flutter/material.dart';
import '../../components/buttons/primary_button.dart';
import '../../../data/models/reflection_model.dart';
import '../../../data/services/reflection_service.dart';
import 'reflection_detail_screen.dart';
import 'new_reflection_screen.dart';

class MyPersonalSpaceScreen extends StatefulWidget {
  const MyPersonalSpaceScreen({super.key});

  @override
  State<MyPersonalSpaceScreen> createState() => _MyPersonalSpaceScreenState();
}

class _MyPersonalSpaceScreenState extends State<MyPersonalSpaceScreen> {
  final ReflectionService _reflectionService = ReflectionService();
  late Future<Map<String, List<ReflectionModel>>> _groupedReflectionsFuture;

  @override
  void initState() {
    super.initState();
    _loadReflections();
  }

  void _loadReflections() {
    _groupedReflectionsFuture = _reflectionService.getReflectionsGroupedByMonth();
  }

  Future<void> _refreshReflections() async {
    setState(() {
      _loadReflections();
    });
  }

  void _navigateToNewReflection() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NewReflectionScreen(),
      ),
    );

    if (result == true && mounted) {
      _refreshReflections();
    }
  }

  void _navigateToReflectionDetail(ReflectionModel reflection) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReflectionDetailScreen(reflection: reflection),
      ),
    );

    if (result == true && mounted) {
      _refreshReflections();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Mi espacio personal',
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshReflections,
        child: FutureBuilder<Map<String, List<ReflectionModel>>>(
          future: _groupedReflectionsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return ListView(
                children: [
                  const SizedBox(height: 48),
                  Center(child: Text('Error: ${snapshot.error}')),
                ],
              );
            }

            final groupedReflections = snapshot.data!;
            final isEmpty = groupedReflections.isEmpty || 
                           groupedReflections.values.every((list) => list.isEmpty);

            if (isEmpty) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                children: [
                  _buildHeaderCTA(),
                  const SizedBox(height: 48),
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.book_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aún no has creado ninguna reflexión',
                          style: textTheme.bodyLarge?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Comienza escribiendo tu primera reflexión personal',
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        // Botón para refrescar reflexiones desde API
                        TextButton.icon(
                          onPressed: () async {
                            _refreshReflections();
                          },
                          icon: Icon(Icons.refresh, color: Colors.blue.shade600),
                          label: Text(
                            'Refrescar reflexiones',
                            style: TextStyle(color: Colors.blue.shade600),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Botón para cambiar tipo de usuario (solo para testing)
                        TextButton.icon(
                          onPressed: () {
                            final currentType = _reflectionService.userType;
                            final newType = currentType == UserType.free 
                                ? UserType.premium 
                                : UserType.free;
                            _reflectionService.setUserType(newType);
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Cambiado a usuario ${newType == UserType.premium ? 'Premium' : 'Gratuito'}',
                                ),
                                backgroundColor: newType == UserType.premium 
                                    ? Colors.green 
                                    : Colors.orange,
                              ),
                            );
                          },
                          icon: Icon(
                            _reflectionService.userType == UserType.premium 
                                ? Icons.star 
                                : Icons.star_border,
                            color: Colors.amber.shade600,
                          ),
                          label: Text(
                            'Usuario: ${_reflectionService.userType == UserType.premium ? 'Premium' : 'Gratuito'}',
                            style: TextStyle(color: Colors.amber.shade600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            // Ordenar las claves de mes de forma descendente (más reciente primero)
            final sortedMonthKeys = groupedReflections.keys.toList()
              ..sort((a, b) => b.compareTo(a));

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _buildHeaderCTA(),
                const SizedBox(height: 16),

                // Mostrar reflexiones agrupadas por mes
                for (final monthKey in sortedMonthKeys) ...[
                  const SizedBox(height: 16),
                  Text(
                    _reflectionService.getMonthLabel(DateTime.parse('$monthKey-01')),
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Lista de reflexiones del mes
                  for (final reflection in groupedReflections[monthKey]!) ...[
                    _buildReflectionCard(reflection),
                    const SizedBox(height: 12),
                  ],
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderCTA() {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    
    return Column(
      children: [
        const SizedBox(height: 8),
        Center(
          child: Column(
            children: [
              Text(
                '¿Cómo estás hoy?',
                style: textTheme.titleLarge?.copyWith(
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 240,
                child: PrimaryButton(
                  text: 'Empezar a escribir...',
                  onPressed: _navigateToNewReflection,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReflectionCard(ReflectionModel reflection) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final hasMedia = reflection.attachedFiles.isNotEmpty;
    final firstImageFile = reflection.attachedFiles
        .where((f) => f.isImage)
        .isNotEmpty 
        ? reflection.attachedFiles.firstWhere((f) => f.isImage) 
        : null;

    return Card(
      color: Colors.white,
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: InkWell(
        onTap: () => _navigateToReflectionDetail(reflection),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mostrar imagen si existe
              if (firstImageFile != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: firstImageFile.localPath != null 
                      ? Image.file(
                          File(firstImageFile.localPath!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: Icon(Icons.broken_image, size: 32),
                              ),
                            );
                          },
                        )
                      : firstImageFile.downloadUrl.isNotEmpty
                        ? Image.network(
                            firstImageFile.downloadUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade200,
                                child: const Center(
                                  child: Icon(Icons.broken_image, size: 32),
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Icon(Icons.image, size: 32),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Título
              Text(
                reflection.title.isEmpty ? 'Sin título' : reflection.title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              // Descripción
              if (reflection.content.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  reflection.content,
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 12),

              // Footer con fecha e indicadores de media
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(reflection.createdDate),
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (hasMedia) _buildMediaIndicator(reflection.attachedFiles),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaIndicator(List<ReflectionFile> files) {
    final imageCount = files.where((f) => f.isImage).length;
    final audioCount = files.where((f) => f.isAudio).length;
    final videoCount = files.where((f) => f.isVideo).length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (imageCount > 0) ...[
            Icon(Icons.image, size: 14, color: Colors.blue.shade600),
            const SizedBox(width: 2),
            Text(
              '$imageCount',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.blue.shade600,
              ),
            ),
            if (audioCount > 0 || videoCount > 0) const SizedBox(width: 4),
          ],
          if (audioCount > 0) ...[
            Icon(Icons.audiotrack, size: 14, color: Colors.blue.shade600),
            const SizedBox(width: 2),
            Text(
              '$audioCount',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.blue.shade600,
              ),
            ),
            if (videoCount > 0) const SizedBox(width: 4),
          ],
          if (videoCount > 0) ...[
            Icon(Icons.videocam, size: 14, color: Colors.blue.shade600),
            const SizedBox(width: 2),
            Text(
              '$videoCount',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.blue.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const weekdays = [
      '', 'lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'
    ];
    const months = [
      '', 'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    
    final weekday = weekdays[date.weekday];
    final day = date.day;
    final month = months[date.month];
    final year = date.year;
    
    return '$weekday, $day de $month de $year';
  }
}