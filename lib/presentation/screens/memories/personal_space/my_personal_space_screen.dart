import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';
import '../../../../providers/reflection_provider.dart';
import '../../../components/buttons/primary_button.dart';
import '../../../../data/models/reflection_model.dart';
import '../../../../data/services/reflection_service.dart';
import '../../../components/common/app_bar.dart';
import 'reflection_detail/reflection_detail_screen.dart';
import 'new_reflection/new_reflection_screen.dart';
import 'package:provider/provider.dart';

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
    Future.microtask(() {
      Provider.of<ReflectionProvider>(context, listen: false).loadReflections();
    });
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
    // Get screen dimensions for responsive layout
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    double appBarHeight = screenHeight * 0.09;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomMemoryAppBar(
        title: "Mi Espacio Personal",
        onBack: () => Navigator.pop(context),
        appBarHeight: appBarHeight,
        showBackButton: true,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshReflections,
        child: Consumer<ReflectionProvider>(
          builder: (context, provider, _) {
            final reflections = provider.reflections;

            // Loading inicial
            if (provider.isLoading && reflections.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            // Sin reflexiones
            if (reflections.isEmpty) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                children: [
                  _buildHeaderCTA(),
                  const SizedBox(height: 48),
                  Center(
                    child: Text("Aún no has creado ninguna reflexión"),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {
                      Provider.of<ReflectionProvider>(context, listen: false)
                          .refreshReflections();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text("Refrescar"),
                  )
                ],
              );
            }

            // Agrupar reflexiones por mes
            final Map<String, List<ReflectionModel>> grouped = {};
            for (final r in reflections) {
              final key = "${r.createdDate.year}-${r.createdDate.month.toString().padLeft(2, '0')}";
              grouped.putIfAbsent(key, () => []).add(r);
            }

            final sortedKeys = grouped.keys.toList()
              ..sort((a, b) => b.compareTo(a));

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _buildHeaderCTA(),
                for (final key in sortedKeys) ...[
                  const SizedBox(height: 16),
                  Text(
                    _formatMonthLabel(key),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  for (final reflection in grouped[key]!) ...[
                    _buildReflectionCard(reflection),
                    const SizedBox(height: 12),
                  ]
                ]
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderCTA() {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '¿Cómo estás hoy?',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.normal,
              color: AppColors.primary2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 200,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                backgroundColor: AppColors.primary,
              ),
              onPressed: _navigateToNewReflection,
              child: const Text('Empezar a escribir...'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReflectionCard(ReflectionModel reflection) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final hasMedia = reflection.attachedFiles.isNotEmpty;

    for (final file in reflection.attachedFiles) {
      print('File: ${file.fileName}, Type: ${file.fileType}, isVideo: ${file.isVideo}, downloadUrl: ${file.downloadUrl}, localPath: ${file.localPath}');
    }

    // Debug logging
    print('Reflection ${reflection.title} has ${reflection.attachedFiles.length} files:');
    for (final file in reflection.attachedFiles) {
      print('  File: ${file.fileName}, Type: ${file.fileType}, IsImage: ${file.isImage}, URL: ${file.downloadUrl}');
    }

    final firstImageFile = reflection.attachedFiles
        .where((f) => f.isImage)
        .isNotEmpty
        ? reflection.attachedFiles.firstWhere((f) => f.isImage)
        : null;

    print('FirstImageFile: ${firstImageFile?.fileName ?? 'null'}');

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

  String _formatMonthLabel(String key) {
    final parts = key.split("-");
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);

    const months = [
      '', 'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];

    return "${months[month]} $year";
  }
}