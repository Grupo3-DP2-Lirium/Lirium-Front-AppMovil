import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_frontend/presentation/screens/memories/personal_space/video_player.dart';
import '../../../data/models/reflection_model.dart';
import '../../../data/services/reflection_service.dart';
import 'new_reflection_screen.dart';


class ReflectionDetailScreen extends StatefulWidget {
  final ReflectionModel reflection;

  const ReflectionDetailScreen({
    super.key,
    required this.reflection,
  });

  @override
  State<ReflectionDetailScreen> createState() => _ReflectionDetailScreenState();
}

class _ReflectionDetailScreenState extends State<ReflectionDetailScreen> {
  final ReflectionService _reflectionService = ReflectionService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  late ReflectionModel _reflection;
  bool _isPlayingAudio = false;
  String? _currentlyPlayingAudioId;

  @override
  void initState() {
    super.initState();
    _reflection = widget.reflection;
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _navigateToEdit() async {
    // Verificar si la reflexión tiene un UUID válido del backend
    if (!_isValidUUID(_reflection.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Esta reflexión debe ser guardada en el servidor primero'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewReflectionScreen(editingReflection: _reflection),
      ),
    );

    if (result == true && mounted) {
      // Recargar la reflexión actualizada
      final updatedReflection = await _reflectionService.getReflectionById(_reflection.id);
      if (updatedReflection != null) {
        setState(() {
          _reflection = updatedReflection;
        });
      }
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar reflexión'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar esta reflexión? '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context); // Cerrar diálogo
              await _deleteReflection();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _playAudio(ReflectionFile audio) async {
    try {
      // Si ya se está reproduciendo este mismo audio → Pausar
      if (_isPlayingAudio && _currentlyPlayingAudioId == audio.id) {
        await _audioPlayer.pause();
        setState(() {
          _isPlayingAudio = false;
          _currentlyPlayingAudioId = null;
        });
        return;
      }

      await _audioPlayer.stop();

      // Establecer la fuente correctamente según el tipo
      if (audio.localPath != null) {
        await _audioPlayer.setSource(DeviceFileSource(audio.localPath!));
      } else if (audio.downloadUrl.isNotEmpty) {
        await _audioPlayer.setSource(UrlSource(audio.downloadUrl));
      } else {
        throw "No hay fuente de audio disponible";
      }

      // Iniciar reproducción (esto sí funciona en todas las versiones)
      await _audioPlayer.resume();

      setState(() {
        _isPlayingAudio = true;
        _currentlyPlayingAudioId = audio.id;
      });

      _audioPlayer.onPlayerComplete.listen((_) {
        setState(() {
          _isPlayingAudio = false;
          _currentlyPlayingAudioId = null;
        });
      });
    } catch (e) {
      print("ERROR AUDIO: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al reproducir audio: $e')),
      );
    }
  }

  Future<void> _deleteReflection() async {
    try {
      await _reflectionService.deleteReflection(_reflection.id);
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reflexión eliminada con éxito'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  _navigateToEdit();
                  break;
                case 'delete':
                  _confirmDelete();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20),
                    SizedBox(width: 12),
                    Text('Editar'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Eliminar', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Icon(Icons.more_vert, color: Colors.black87),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fecha
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _formatDate(_reflection.createdDate),
                style: textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Título
            if (_reflection.title.isNotEmpty) ...[
              Text(
                _reflection.title,
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Contenido
            if (_reflection.content.isNotEmpty) ...[
              Text(
                _reflection.content,
                style: textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Archivos multimedia
            if (_reflection.attachedFiles.isNotEmpty) ...[
              _buildMediaSection(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMediaSection() {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    
    final images = _reflection.attachedFiles.where((f) => f.isImage).toList();
    final audios = _reflection.attachedFiles.where((f) => f.isAudio).toList();
    final videos = _reflection.attachedFiles.where((f) => f.isVideo).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Divider
        Divider(color: Colors.grey.shade300, thickness: 1),
        const SizedBox(height: 16),

        // Título de la sección
        Text(
          'Archivos adjuntos',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),

        // Imágenes
        if (images.isNotEmpty) ...[
          _buildImagesGrid(images),
          const SizedBox(height: 16),
        ],

        // Audios
        if (audios.isNotEmpty) ...[
          _buildAudiosList(audios),
          const SizedBox(height: 16),
        ],

        // Videos
        if (videos.isNotEmpty) ...[
          _buildVideosList(videos),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildImagesGrid(List<ReflectionFile> images) {
    if (images.length == 1) {
      return _buildSingleImage(images.first);
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: images.length >= 4 ? 2 : images.length,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: images.length > 4 ? 4 : images.length,
      itemBuilder: (context, index) {
        if (index == 3 && images.length > 4) {
          return _buildMoreImagesOverlay(images, index);
        }
        return _buildImageTile(images[index]);
      },
    );
  }

  Widget _buildSingleImage(ReflectionFile imageFile) {
    return GestureDetector(
      onTap: () => _showImageFullscreen(imageFile),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: imageFile.localPath != null
          ? Image.file(
              File(imageFile.localPath!),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Icon(Icons.broken_image, size: 48),
                  ),
                );
              },
            )
          : imageFile.downloadUrl.isNotEmpty
            ? Image.network(
                imageFile.downloadUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 48),
                    ),
                  );
                },
              )
            : Container(
                height: 200,
                color: Colors.grey.shade200,
                child: const Center(
                  child: Icon(Icons.image, size: 48),
                ),
              ),
      ),
    );
  }

  Widget _buildImageTile(ReflectionFile imageFile) {
    return GestureDetector(
      onTap: () => _showImageFullscreen(imageFile),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: imageFile.localPath != null
          ? Image.file(
              File(imageFile.localPath!),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.broken_image),
                );
              },
            )
          : imageFile.downloadUrl.isNotEmpty
            ? Image.network(
                imageFile.downloadUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.broken_image),
                  );
                },
              )
            : Container(
                color: Colors.grey.shade200,
                child: const Icon(Icons.image),
              ),
      ),
    );
  }

  Widget _buildMoreImagesOverlay(List<ReflectionFile> images, int index) {
    final remainingCount = images.length - 3;
    
    return GestureDetector(
      onTap: () => _showAllImages(images),
      child: Stack(
        children: [
          _buildImageTile(images[index]),
          Container(
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '+$remainingCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudiosList(List<ReflectionFile> audios) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Audios (${audios.length})',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        ...audios.map((audio) => _buildAudioTile(audio)),
      ],
    );
  }

  Widget _buildVideosList(List<ReflectionFile> videos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Videos (${videos.length})',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        ...videos.map((video) => _buildVideoTile(video)),
      ],
    );
  }

  Widget _buildAudioTile(ReflectionFile audio) {
    final service = ReflectionService();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.audiotrack, color: Colors.blue.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  audio.originalName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  service.formatStorageSize(audio.fileSize.toInt()),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _playAudio(audio),
            icon: Icon(
              _isPlayingAudio && _currentlyPlayingAudioId == audio.id 
                  ? Icons.pause 
                  : Icons.play_arrow,
              color: Colors.blue.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoTile(ReflectionFile video) {
    final service = ReflectionService();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.videocam, color: Colors.purple.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.originalName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  service.formatStorageSize(video.fileSize.toInt()),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showVideoPlayer(video),
            icon: Icon(Icons.play_arrow, color: Colors.purple.shade600),
          ),
        ],
      ),
    );
  }

  void _showImageFullscreen(ReflectionFile imageFile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              child: imageFile.localPath != null
                ? Image.file(File(imageFile.localPath!))
                : imageFile.downloadUrl.isNotEmpty
                  ? Image.network(imageFile.downloadUrl)
                  : const Icon(Icons.image, size: 100),
            ),
          ),
        ),
      ),
    );
  }

  void _showVideoPlayer(ReflectionFile videoFile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenVideoPlayer(file: videoFile),
      ),
    );
  }

  void _showAllImages(List<ReflectionFile> images) {
    // TODO: Implementar galería completa de imágenes
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Galería completa en desarrollo')),
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

  // Método helper para verificar si un ID es un UUID válido
  bool _isValidUUID(String id) {
    if (id.isEmpty) return false;
    
    // Un UUID tiene el formato: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$'
    );
    
    return uuidRegex.hasMatch(id);
  }
}