import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/buttons/icon_button_custom.dart';
import 'package:flutter_frontend/presentation/components/buttons/primary_button.dart';
import 'package:flutter_frontend/presentation/screens/memorial/collaborators_screen.dart';


class MemorialDetailScreen extends StatefulWidget {
  final String memorialId;
  final String name;
  final String? description;
  final String? coverUrl;
  final String? avatarUrl;

  const MemorialDetailScreen({
    super.key,
    required this.memorialId,
    required this.name,
    this.description,
    this.coverUrl,
    this.avatarUrl,
  });

  @override
  State<MemorialDetailScreen> createState() => _MemorialDetailScreenState();
}

class _MemorialDetailScreenState extends State<MemorialDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  ImageProvider? _getAvatarImage(String? avatar) {
    if (avatar == null || avatar.isEmpty) return null;

    if (avatar.startsWith('data:image')) {
      final base64Str = avatar.split(',').last;
      final bytes = base64Decode(base64Str);
      return MemoryImage(bytes);
    }

    return NetworkImage(avatar);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final safeTop = MediaQuery.of(context).padding.top;
    const avatarRadius = 44.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxScrolled) => [
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            expandedHeight: 240,
            surfaceTintColor: Colors.transparent,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            clipBehavior: Clip.antiAlias,

            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              color: Colors.black87,
              onPressed: () => Navigator.pop(context),
            ),

            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Stack(
                children: [
                  // Portada
                  Positioned.fill(
                    child: (widget.coverUrl != null && widget.coverUrl!.isNotEmpty)
                        ? Image.network(widget.coverUrl!, fit: BoxFit.cover)
                        : Container(color: const Color(0xFFEFEFF6)),
                  ),
                  // Degradado
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.10),
                              Colors.black.withOpacity(0.40),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Botón de settings
                  Positioned(
                    right: 16,
                    top: safeTop + 12,
                    child: IconButtonCustom(
                      icon: Icons.settings_outlined,
                      onPressed: () {},
                    ),
                  ),
                  // SOLO AVATAR (sin nombre aquí)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: avatarRadius,
                          backgroundColor: const Color(0xFFE9E8F6),
                          backgroundImage: _getAvatarImage(widget.avatarUrl),
                          child: (widget.avatarUrl == null || widget.avatarUrl!.isEmpty)
                              ? const Icon(Icons.person, size: 44, color: Colors.white)
                              : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ⬇️ Nombre fuera de la portada
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(44), // espacio de seguridad
              child: const SizedBox(height: 44),
            ),
          )
        ],

        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            //nombre del memorial
            Text(
              widget.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                letterSpacing: .5,
              ),
            ),
            const SizedBox(height: 12),

            // ====== BOTONES PRINCIPALES (estilo mock: borde morado, texto negro) ======
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: navegar a versión completa
                    },
                    icon: const Icon(Icons.visibility_outlined),
                    label: const Text('Ver memorial completo'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87, // texto/ícono negros
                      side: BorderSide(color: cs.primary, width: 1.6),
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => CollaboratorsScreen(memorialId: widget.memorialId),
                      ));
                    },
                    icon: const Icon(Icons.group_outlined),
                    label: const Text('Colaboradores'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      side: BorderSide(color: cs.primary, width: 1.6),
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if ((widget.description ?? '').isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xEDD99293),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.description!,
                  textAlign: TextAlign.center,
                  style: tt.bodyMedium?.copyWith(color: Colors.white),
                ),
              ),
            const SizedBox(height: 12),

            _PillTabs(controller: _tab),
            const SizedBox(height: 12),

            SizedBox(
              height: 1200,
              child: TabBarView(
                controller: _tab,
                children: [
                  _RecentActivityFeed(memorialId: widget.memorialId),
                  _AddPanel(onCreate: () {}),
                  _OrganizePanel(onOrganize: () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Botoneras “Actividad reciente / Añadir / Organizar”
class _PillTabs extends StatelessWidget {
  final TabController controller;
  const _PillTabs({required this.controller});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F6),
        borderRadius: BorderRadius.circular(24),
      ),
      child: TabBar(
        controller: controller,
        //isScrollable: true,
        tabAlignment: TabAlignment.fill,
        //labelPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),

        indicator: BoxDecoration(
          color: Color(0xFF6366F1),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(blurRadius: 6, color: Color(0x22000000))],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.black54,
        tabs: const [
          Tab(text: 'Actividad reciente'),
          Tab(text: 'Añadir'),
          Tab(text: 'Organizar'),
        ],
      ),
    );
  }
}


class _RecentActivityFeed extends StatelessWidget {
  final String memorialId;
  const _RecentActivityFeed({required this.memorialId});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    // MOCK de actividades
    final items = <_Activity>[
      _Activity.photos(
        author: 'Fer (Tú)',
        dateLabel: 'Viernes, 06 de junio',
        photos: List.generate(7, (i) => null), // pon URLs reales luego
      ),
      _Activity.text(
        author: 'BRUCE',
        dateLabel: 'Martes, 03 de junio',
        text:
        '“Tejer, ver novelas y bailar vals eran sus hobbies favoritos”.',
      ),
      _Activity.coverChange(
        dateLabel: 'Jueves, 29 de mayo',
        coverUrl: null,
      ),
    ];

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 8),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, i) {
        final it = items[i];
        return switch (it.type) {
          _ActivityType.photos => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeaderLine(author: it.author!, subtitle: 'Compartió ${it.photos!.length} fotos'),
              const SizedBox(height: 8),
              _PhotoGrid(urls: it.photos!),
              const SizedBox(height: 8),
              Text(it.dateLabel!, style: tt.bodySmall?.copyWith(color: Colors.black54)),
            ],
          ),
          _ActivityType.text => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeaderLine(author: it.author!, subtitle: 'Escribió'),
              const SizedBox(height: 8),
              Text(
                it.text!,
                style: tt.titleMedium?.copyWith(color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Text(it.dateLabel!, style: tt.bodySmall?.copyWith(color: Colors.black54)),
            ],
          ),
          _ActivityType.coverChange => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _HeaderLine(author: 'Tú', subtitle: 'Cambiaste la foto de portada'),
              const SizedBox(height: 8),
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFEFF6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  // child: Image.network(it.coverUrl!), // cuando tengas URL
                ),
              ),
              const SizedBox(height: 8),
              Text(it.dateLabel!, style: tt.bodySmall?.copyWith(color: Colors.black54)),
            ],
          ),
        };
      },
    );
  }
}

class _HeaderLine extends StatelessWidget {
  final String author;
  final String subtitle;
  const _HeaderLine({required this.author, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Row(
      children: [
        const CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(
            'https://i.pravatar.cc/150?img=5',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: tt.bodyMedium?.copyWith(color: Colors.black87),
              children: [
                TextSpan(text: author, style: const TextStyle(fontWeight: FontWeight.w600)),
                const TextSpan(text: '  '),
                TextSpan(text: subtitle),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Grid responsivo tipo collage (3 columnas)
class _PhotoGrid extends StatelessWidget {
  final List<String?> urls;
  const _PhotoGrid({required this.urls});

  @override
  Widget build(BuildContext context) {
    final n = urls.length;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: n,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        ),
        itemBuilder: (_, i) {
          final url = urls[i];
          return Container(
            color: const Color(0xFFF3F2F8),
            child: url == null
                ? const Icon(Icons.image, size: 28, color: Colors.black26)
                : Image.network(url, fit: BoxFit.cover),
          );
        },
      ),
    );
  }
}

class _AddPanel extends StatelessWidget {
  final VoidCallback onCreate;
  const _AddPanel({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: PrimaryButton(
        text: 'Añadir recuerdos',
        icon: Icons.add,
        onPressed: onCreate,
      ),
    );
  }
}

class _OrganizePanel extends StatelessWidget {
  final VoidCallback onOrganize;
  const _OrganizePanel({required this.onOrganize});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: OutlinedButton.icon(
        icon: const Icon(Icons.grid_view_outlined),
        label: const Text('Organizar álbumes y etiquetas'),
        onPressed: onOrganize,
      ),
    );
  }
}

enum _ActivityType { photos, text, coverChange }

class _Activity {
  final _ActivityType type;
  final String? author;
  final String? dateLabel;
  final List<String?>? photos;
  final String? text;
  final String? coverUrl;

  _Activity.photos({required this.author, required this.dateLabel, required this.photos})
      : type = _ActivityType.photos, text = null, coverUrl = null;

  _Activity.text({required this.author, required this.dateLabel, required this.text})
      : type = _ActivityType.text, photos = null, coverUrl = null;

  _Activity.coverChange({required this.dateLabel, required this.coverUrl})
      : type = _ActivityType.coverChange, photos = null, author = null, text = null;
}
