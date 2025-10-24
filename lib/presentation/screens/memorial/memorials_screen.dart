import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/memorial_provider.dart';
import 'memorial_detail_screen.dart';

class MemorialsScreen extends StatefulWidget {
  const MemorialsScreen({super.key});

  @override
  State<MemorialsScreen> createState() => _MemorialsScreenState();
}

class _MemorialsScreenState extends State<MemorialsScreen> {
  int _tabIndex = 0; // 0: Mis memoriales, 1: Colaboraciones
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final prov = context.read<MemorialProvider>();
      prov.cargarMisMemoriales();
      prov.cargarColaborativos();
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<MemorialProvider>();
    final cs = Theme.of(context).colorScheme;
    final isMis = _tabIndex == 0;

    final items = isMis ? prov.misMemoriales : prov.colaborativos;
    final cargando = isMis ? prov.cargandoMis : prov.cargandoColab;
    final error = isMis ? prov.errorMis : prov.errorColab;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Memoriales', style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => prov.recargarTodo(),
            tooltip: 'Recargar',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navegar a creación de memorial
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Crear memorial (pendiente)')));
        },
        backgroundColor: cs.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          _SegmentedTabs(
            index: _tabIndex,
            onChanged: (i) => setState(() => _tabIndex = i),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                if (isMis) {
                  await prov.cargarMisMemoriales(force: true);
                } else {
                  await prov.cargarColaborativos(force: true);
                }
              },
              child: Builder(
                builder: (_) {
                  if (cargando && items.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (error != null && items.isEmpty) {
                    return ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Text('Error al cargar', style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 8),
                              Text(error, textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent)),
                              const SizedBox(height: 16),
                              FilledButton(
                                onPressed: () => isMis ? prov.cargarMisMemoriales(force: true) : prov.cargarColaborativos(force: true),
                                child: const Text('Reintentar'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                  if (items.isEmpty) {
                    return ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(32, 64, 32, 16),
                          child: Column(
                            children: [
                              Icon(isMis ? Icons.auto_awesome : Icons.group_outlined, size: 64, color: Colors.black26),
                              const SizedBox(height: 16),
                              Text(
                                isMis ? 'Aún no tienes memoriales creados.' : 'No colaboras todavía en ningún memorial.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.black87),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isMis
                                    ? 'Crea tu primer memorial para empezar a construir un legado.'
                                    : 'Cuando aceptes invitaciones aparecerán aquí.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54, height: 1.3),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final m = items[i];
                      return _MemorialListCard(
                        name: m.name,
                        description: m.description,
                        isCollaborative: m.isCollaborative,
                        created: m.createdDate,
                        profilePhotoUrl: m.profilePhotoUrl,
                        profilePhotoBase64: m.profilePhotoBase64,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MemorialDetailScreen(
                              memorialId: m.idMemorial,
                              name: m.name,
                              description: m.description,
                              avatarUrl: m.profilePhotoUrl ?? m.profilePhotoBase64,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentedTabs extends StatelessWidget {
  final int index; final ValueChanged<int> onChanged;
  const _SegmentedTabs({required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _TabPill(
              text: 'Mis memoriales',
              selected: index == 0,
              onTap: () => onChanged(0),
              color: const Color(0xFFF15B5D),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _TabPill(
              text: 'Colaboraciones',
              selected: index == 1,
              onTap: () => onChanged(1),
              color: const Color(0xFFDADBE1),
              selectedTextColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  final String text; final bool selected; final VoidCallback onTap; final Color color; final Color? selectedTextColor;
  const _TabPill({required this.text, required this.selected, required this.onTap, required this.color, this.selectedTextColor});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? color : const Color(0xFFF1F2F6),
          borderRadius: BorderRadius.circular(40),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: selected ? (selectedTextColor ?? Colors.white) : Colors.black87,
          ),
        ),
      ),
    );
  }
}

class _MemorialListCard extends StatelessWidget {
  final String name; final String description; final bool isCollaborative; final DateTime created; final VoidCallback onTap;
  final String? profilePhotoUrl; final String? profilePhotoBase64;
  const _MemorialListCard({required this.name, required this.description, required this.isCollaborative, required this.created, required this.onTap, this.profilePhotoUrl, this.profilePhotoBase64});

  String _timeAgo() {
    final diff = DateTime.now().difference(created);
    if (diff.inDays >= 1) return 'Hace ${diff.inDays} días';
    if (diff.inHours >= 1) return 'Hace ${diff.inHours} h';
    if (diff.inMinutes >= 1) return 'Hace ${diff.inMinutes} min';
    return 'Justo ahora';
  }

  DecorationImage? _getProfileImage() {
    ImageProvider? imageProvider;
    
    if (profilePhotoBase64 != null && profilePhotoBase64!.isNotEmpty) {
      try {
        final base64String = profilePhotoBase64!.contains(',') 
            ? profilePhotoBase64!.split(',').last 
            : profilePhotoBase64!;
        imageProvider = MemoryImage(base64Decode(base64String));
      } catch (e) {
        print('Error decoding base64 in list: $e');
        return null;
      }
    } else if (profilePhotoUrl != null && profilePhotoUrl!.isNotEmpty) {
      imageProvider = NetworkImage(profilePhotoUrl!);
    }
    
    return imageProvider != null 
        ? DecorationImage(image: imageProvider, fit: BoxFit.cover)
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE3E4EA)),
          boxShadow: const [
            BoxShadow(color: Color(0x0F000000), blurRadius: 6, offset: Offset(0,2)),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 56, width: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFE9E8F6),
                borderRadius: BorderRadius.circular(12),
                image: _getProfileImage(),
              ),
              child: _getProfileImage() == null 
                  ? const Icon(Icons.person, color: Colors.white, size: 32)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(name, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 6),
                      Icon(isCollaborative ? Icons.groups_2_outlined : Icons.lock_outline, size: 18, color: Colors.black45),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description.isEmpty ? 'Sin descripción' : description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: tt.bodySmall?.copyWith(color: Colors.black54, height: 1.25),
                  ),
                  const SizedBox(height: 6),
                  Text(_timeAgo(), style: tt.bodySmall?.copyWith(color: Colors.black38)),
                ],
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: Colors.black38),
          ],
        ),
      ),
    );
  }
}

