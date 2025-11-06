import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/models/documentary_model.dart';
import 'package:flutter_frontend/presentation/components/components.dart';
import 'package:flutter_frontend/presentation/screens/videos/video_player_screen.dart';
import 'package:flutter_frontend/providers/documentary_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';
import 'package:flutter_frontend/presentation/components/buttons/secondary_button.dart';

class DocumentaryDetailScreen extends StatefulWidget {
  final String documentaryId;

  const DocumentaryDetailScreen({
    super.key,
    required this.documentaryId,
  });

  @override
  State<DocumentaryDetailScreen> createState() =>
      _DocumentaryDetailScreenState();
}

class _DocumentaryDetailScreenState extends State<DocumentaryDetailScreen> {
  DocumentaryModel? _documentary;
  bool _loading = true;
  bool _publishing = false;

  @override
  void initState() {
    super.initState();
    _loadDocumentary();
  }

  Future<void> _loadDocumentary() async {
    setState(() {
      _loading = true;
    });

    try {
      final provider = context.read<DocumentaryProvider>();
      await provider.refreshDocumentaryStatus(widget.documentaryId);

      _documentary = provider.documentaries.firstWhere(
            (d) => d.idDocumentary == widget.documentaryId,
      );
    } catch (e) {
      print('ERROR loading documentary: $e');
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Documental'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_documentary == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Documental'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
        body: const Center(child: Text('Documental no encontrado')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Documental'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          if (_documentary!.isProcessing)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadDocumentary,
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteDialog();
              } else if (value == 'cancel') {
                _showCancelDialog();
              }
            },
            itemBuilder: (context) {
              final items = <PopupMenuEntry<String>>[];

              if (_documentary!.isProcessing) {
                items.add(
                  const PopupMenuItem(
                    value: 'cancel',
                    child: Row(
                      children: [
                        Icon(Icons.cancel, size: 18, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('Cancelar generación'),
                      ],
                    ),
                  ),
                );
              }

              items.add(
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Eliminar'),
                    ],
                  ),
                ),
              );

              return items;
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDocumentary,
        color: AppColors.primary,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Video player o placeholder
              _buildVideoSection(),
              const SizedBox(height: 24),

              // Título
              Text(
                _documentary!.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),

              // Memorial
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 18, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    _documentary!.memorialName,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Descripción
              if (_documentary!.description.isNotEmpty) ...[
                Text(
                  _documentary!.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Estado
              _buildStatusSection(),
              const SizedBox(height: 24),

              // Info
              _buildInfoSection(),
              const SizedBox(height: 24),

              // Acciones según estado
              _buildActionsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoSection() {
    if ((_documentary!.isCompleted || _documentary!.isPublished) &&
        _documentary!.videoUrl != null) {
      return Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [Colors.purple[300]!, Colors.blue[300]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.play_circle_filled,
                  size: 64, color: Colors.white),
              onPressed: () => _openVideo(_documentary!.videoUrl!),
            ),
            // Badge si está publicado
            if (_documentary!.isPublished)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.public, size: 14, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'PUBLICADO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    } else if (_documentary!.isProcessing) {
      return Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Generando video...',
              style: TextStyle(color: Colors.grey[700]),
            ),
          ],
        ),
      );
    } else {
      return Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.movie_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              _documentary!.isFailed
                  ? 'Error en la generación'
                  : _documentary!.isDraft
                  ? 'Borrador'
                  : 'En espera',
              style: TextStyle(color: Colors.grey[700]),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildStatusSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStatusColor().withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_getStatusIcon(), color: _getStatusColor()),
              const SizedBox(width: 8),
              Text(
                _documentary!.statusText,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _getStatusColor(),
                ),
              ),
            ],
          ),
          if (_documentary!.isProcessing) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _documentary!.progress / 100,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor()),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_documentary!.progress}% completado',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ],
          if (_documentary!.isPublished && _documentary!.publishedDate != null) ...[
            const SizedBox(height: 8),
            Text(
              'Publicado el ${_formatDate(_documentary!.publishedDate!)}',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ],
          if (_documentary!.isFailed && _documentary!.errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _documentary!.errorMessage!,
              style: const TextStyle(fontSize: 14, color: Colors.red),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            Icons.photo_library,
            'Recuerdos incluidos',
            '${_documentary!.totalMemories}',
          ),
          if (_documentary!.isCompleted || _documentary!.isPublished) ...[
            const Divider(height: 24),
            _buildInfoRow(
              Icons.access_time,
              'Duración',
              _documentary!.durationFormatted,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              Icons.file_present,
              'Tamaño del archivo',
              _documentary!.fileSizeFormatted,
            ),
          ],
          const Divider(height: 24),
          _buildInfoRow(
            Icons.calendar_today,
            'Fecha de creación',
            _formatDate(_documentary!.createdDate),
          ),
          if (_documentary!.processingCompleted != null) ...[
            const Divider(height: 24),
            _buildInfoRow(
              Icons.check_circle_outline,
              'Completado el',
              _formatDate(_documentary!.processingCompleted!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildActionsSection() {
    // Si está completado pero NO publicado → Botón publicar
    if (_documentary!.isCompleted && !_documentary!.isPublished) {
      return Column(
        children: [
          PrimaryButton(
            text: 'Publicar en Perfil',
            icon: Icons.public,
            isFullWidth: true,
            isLoading: _publishing,
            onPressed: _publishing ? null : _publishDocumentary,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: SecondaryButton(
              text: 'Vista Previa',
              isOutlined: true,
              textColor: AppColors.primary,
              onPressed: () => _openVideo(_documentary!.videoUrl!),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Al publicar, el documental será visible en el perfil de ${_documentary!.memorialName}',
                    style: TextStyle(fontSize: 12, color: Colors.blue[900]),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Si ya está publicado o tiene video → Botones reproducir y descargar
    if ((_documentary!.isPublished || _documentary!.isCompleted) &&
        _documentary!.videoUrl != null) {
      return Column(
        children: [
          if (_documentary!.isPublished)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Publicado en el perfil de ${_documentary!.memorialName}',
                      style: TextStyle(fontSize: 13, color: Colors.green[900]),
                    ),
                  ),
                ],
              ),
            ),
          PrimaryButton(
            text: 'Reproducir Video',
            icon: Icons.play_circle_filled,
            isFullWidth: true,
            onPressed: () => _openVideo(_documentary!.videoUrl!),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: SecondaryButton(
              text: 'Descargar',
              isOutlined: true,
              textColor: AppColors.primary,
              onPressed: () => _downloadVideo(_documentary!.videoUrl!),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Future<void> _publishDocumentary() async {
    setState(() {
      _publishing = true;
    });

    final provider = context.read<DocumentaryProvider>();
    final result = await provider.publishDocumentary(widget.documentaryId);

    setState(() {
      _publishing = false;
    });

    if (!mounted) return;

    if (result != null) {
      _documentary = result;
      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Documental publicado exitosamente!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${provider.error ?? "Desconocido"}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getStatusColor() {
    switch (_documentary!.status) {
      case 'DRAFT':
        return Colors.orange;
      case 'PROCESSING':
        return Colors.blue;
      case 'COMPLETED':
        return Colors.green;
      case 'PUBLISHED':
        return Colors.green;
      case 'FAILED':
        return Colors.red;
      case 'CANCELLED':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (_documentary!.status) {
      case 'DRAFT':
        return Icons.edit_note;
      case 'PROCESSING':
        return Icons.hourglass_empty;
      case 'COMPLETED':
        return Icons.check_circle;
      case 'PUBLISHED':
        return Icons.public;
      case 'FAILED':
        return Icons.error;
      case 'CANCELLED':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _openVideo(String url) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoPlayerScreen(
          videoUrl: url,
          title: _documentary!.title,
        ),
      ),
    );
  }

  Future<void> _downloadVideo(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Abriendo navegador para descargar...'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar documental'),
        content: Text(
          _documentary!.isPublished
              ? '¿Estás seguro de que deseas eliminar este documental? Se quitará del perfil y esta acción no se puede deshacer.'
              : '¿Estás seguro de que deseas eliminar este documental? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);

              final provider = context.read<DocumentaryProvider>();
              final success =
              await provider.deleteDocumentary(widget.documentaryId);

              if (mounted) {
                if (success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Documental eliminado'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error al eliminar documental'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar generación'),
        content: const Text(
          '¿Deseas cancelar la generación de este documental?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);

              final provider = context.read<DocumentaryProvider>();
              final success =
              await provider.cancelDocumentary(widget.documentaryId);

              if (mounted) {
                if (success) {
                  await _loadDocumentary();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Generación cancelada'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error al cancelar'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Sí, cancelar',
              style: TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }
}