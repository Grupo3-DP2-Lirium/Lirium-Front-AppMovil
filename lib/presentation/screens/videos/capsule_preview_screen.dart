import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/models/capsule_request.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_frontend/data/models/capsule_model.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';
import 'package:flutter_frontend/presentation/components/buttons/primary_button.dart';
import 'package:flutter_frontend/providers/capsule_provider.dart';

class CapsulePreviewScreen extends StatefulWidget {
  final CapsuleModel capsule;

  const CapsulePreviewScreen({super.key, required this.capsule});

  @override
  State<CapsulePreviewScreen> createState() => _CapsulePreviewScreenState();
}

class _CapsulePreviewScreenState extends State<CapsulePreviewScreen> {
  late CapsuleModel _capsule;
  bool _updating = false;

  final _editTitleCtrl = TextEditingController();
  final _editDescCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _capsule = widget.capsule;
    _refresh(); // Traer estado reciente apenas entramos
  }

  @override
  void dispose() {
    _editTitleCtrl.dispose();
    _editDescCtrl.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final provider = context.read<CapsuleProvider>();

    // Actualiza el estado en el provider (internamente ya llama al servicio)
    await provider.refreshCapsuleStatus(_capsule.idCapsule);

    // Busca la cápsula actualizada en la lista del provider
    final refreshed = provider.capsules.firstWhere(
          (c) => c.idCapsule == _capsule.idCapsule,
      orElse: () => _capsule,
    );

    if (mounted) setState(() => _capsule = refreshed);
  }


  @override
  Widget build(BuildContext context) {
    final isReady = _capsule.isCompleted || _capsule.isPublished;
    final provider = context.watch<CapsuleProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Vista previa de Cápsula'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
            tooltip: 'Actualizar',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') _openEdit();
              if (value == 'delete') _confirmDelete();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Editar título/desc.')],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('Eliminar')],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _PreviewBox(capsule: _capsule),
              const SizedBox(height: 16),

              // Info básica
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _capsule.title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _capsule.memorialName,
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ),
              if ((_capsule.description ?? '').isNotEmpty) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(_capsule.description!, style: const TextStyle(fontSize: 14)),
                ),
              ],
              const SizedBox(height: 12),

              // Chips info
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _chip(Icons.filter_vintage, _capsule.filterText),
                  if (_capsule.videoDuration != null) _chip(Icons.access_time, _capsule.durationFormatted),
                  if (_capsule.totalMemories != null) _chip(Icons.photo_library, '${_capsule.totalMemories} recuerdos'),
                  _statusChip(),
                ],
              ),
              const SizedBox(height: 24),

              // Botones de acción
              if (_capsule.isProcessing) ...[
                PrimaryButton(
                  text: 'Cancelar generación',
                  icon: Icons.cancel,
                  isFullWidth: true,
                  onPressed: () async {
                    final ok = await provider.cancelCapsule(_capsule.idCapsule);
                    if (ok) await _refresh();
                  },
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        text: 'Reproducir',
                        icon: Icons.play_arrow,
                        onPressed: _onPlay,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PrimaryButton(
                        text: 'Descargar',
                        icon: Icons.download,
                        onPressed: _onDownload,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _openEdit,
                        icon: const Icon(Icons.edit),
                        label: const Text('Editar título/desc.'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _capsule.isPublished ? Colors.grey[600] : AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _capsule.isPublished ? null : _onPublish,
                        icon: const Icon(Icons.public),
                        label: Text(_capsule.isPublished ? 'Publicado' : 'Publicar'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: _confirmDelete,
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text('Descartar', style: TextStyle(color: Colors.red)),
                ),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 16, color: Colors.grey[700]),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(color: Colors.grey[800])),
      ]),
    );
  }

  Widget _statusChip() {
    Color color;
    IconData icon;
    String text = _capsule.statusText;

    if (_capsule.isProcessing) {
      color = Colors.purple[50]!;
      icon = Icons.autorenew;
    } else if (_capsule.isPublished) {
      color = Colors.green[50]!;
      icon = Icons.public;
    } else if (_capsule.isCompleted) {
      color = Colors.green[50]!;
      icon = Icons.check_circle;
    } else if (_capsule.isFailed) {
      color = Colors.red[50]!;
      icon = Icons.error_outline;
    } else if (_capsule.isDraft) {
      color = Colors.orange[50]!;
      icon = Icons.edit_note;
    } else {
      color = Colors.grey[100]!;
      icon = Icons.schedule;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 16),
        const SizedBox(width: 6),
        Text(text),
      ]),
    );
  }

  Future<void> _onPlay() async {
    if (_capsule.videoUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aún no hay video disponible'), backgroundColor: Colors.orange),
      );
      return;
    }
    final url = Uri.parse(_capsule.videoUrl!);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el video'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _onDownload() async {
    // Por ahora abrimos el mismo enlace del video (el usuario puede guardar desde el navegador).
    await _onPlay();
  }

  Future<void> _onPublish() async {
    final provider = context.read<CapsuleProvider>();
    final updated = await provider.publishCapsule(_capsule.idCapsule);
    if (updated != null) {
      setState(() => _capsule = updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cápsula publicada'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${provider.error ?? "Desconocido"}'), backgroundColor: Colors.red),
      );
    }
  }

  void _openEdit() {
    _editTitleCtrl.text = _capsule.title;
    _editDescCtrl.text = _capsule.description ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16, right: 16, top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(height: 4, width: 40, margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const Text('Editar detalles', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              TextField(
                controller: _editTitleCtrl,
                decoration: InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _editDescCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Descripción (opcional)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _updating ? null : _saveEdit,
                  icon: _updating
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.save),
                  label: const Text('Guardar'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveEdit() async {
    final title = _editTitleCtrl.text.trim();
    final desc = _editDescCtrl.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El título no puede estar vacío'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _updating = true);
    final provider = context.read<CapsuleProvider>();

    final req = CapsuleRequestModel(
      memorialId: _capsule.memorialId,
      userPrompt: _capsule.userPrompt,
      title: title,
      description: desc.isEmpty ? null : desc,
      musicTrack: _capsule.musicTrack,
      filter: _capsule.filter,
    );

    final updated = await provider.updateCapsule(_capsule.idCapsule, req);
    setState(() => _updating = false);

    if (!mounted) return;
    if (updated != null) {
      setState(() => _capsule = updated);
      Navigator.pop(context); // cerrar bottom sheet
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cápsula actualizada'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${provider.error ?? "Desconocido"}'), backgroundColor: Colors.red),
      );
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar cápsula'),
        content: const Text('¿Estás seguro de eliminar esta cápsula?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await context.read<CapsuleProvider>().deleteCapsule(_capsule.idCapsule);
              if (ok && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cápsula eliminada'), backgroundColor: Colors.green),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _PreviewBox extends StatelessWidget {
  final CapsuleModel capsule;
  const _PreviewBox({required this.capsule});

  @override
  Widget build(BuildContext context) {
    final ratio = 9 / 16;
    final width = MediaQuery.of(context).size.width * 0.45;
    final height = width / ratio;

    Widget centerChild;
    if ((capsule.isCompleted || capsule.isPublished) && capsule.videoUrl != null) {
      centerChild = const Icon(Icons.play_circle_filled, color: Colors.white, size: 56);
    } else if (capsule.isProcessing) {
      centerChild = const SizedBox(
        width: 36, height: 36, child: CircularProgressIndicator(strokeWidth: 3),
      );
    } else if (capsule.isFailed) {
      centerChild = const Icon(Icons.error_outline, color: Colors.white, size: 56);
    } else {
      centerChild = const Icon(Icons.video_call_outlined, color: Colors.white, size: 56);
    }

    return Center(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.purple[300]!, Colors.pink[300]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Center(child: centerChild),
            if (capsule.isPublished)
              Positioned(
                top: 8, right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.green, borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('PÚBLICO', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
