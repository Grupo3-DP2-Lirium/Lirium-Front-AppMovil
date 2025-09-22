import 'package:flutter/material.dart';
import 'package:flutter_frontend/components/buttons/primary_button.dart';
import 'package:flutter_frontend/screens/memories/new_personal_memory_screen.dart';
import '../../components/cards/memory_card.dart';
import '../../services/memory_service.dart';
import '../../models/memory_response.dart';

// TODO: trae el JWT real desde donde se guarde (secure storage, provider, etc.), por ahora aquí
String get currentJwt => 'eyJhbGciOiJIUzM4NCJ9.eyJzdWIiOiJ0ZXN0QGV4YW1wbGUuY29tIiwiaWF0IjoxNzU4NTAzMzM5LCJleHAiOjE3NTg1ODk3Mzl9.BA7jDWvCHZObHbTcTjtfNwcIgqa-EbFXagjUYLZfvQT3PG61pZESamkUzTzgDtFr';
const memorialIdFixed = '0EAE29A7-C601-4BB2-931D-3ADBB3E04E55';

class PersonalSpaceScreen extends StatefulWidget {
  const PersonalSpaceScreen({super.key});

  @override
  State<PersonalSpaceScreen> createState() => _PersonalSpaceScreenState();
}

class _PersonalSpaceScreenState extends State<PersonalSpaceScreen> {
  final _service = MemoryService();
  late Future<PageMemoryResponse> _future;
  int _page = 0;
  final int _size = 20;

  @override
  void initState() {
    super.initState();
    _future = _fetch();
  }

  Future<PageMemoryResponse> _fetch() {
    return _service.listMemories(
      token: currentJwt,
      memorialId: memorialIdFixed,
      page: _page,
      size: _size,
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _page = 0;
      _future = _fetch();
    });
    await _future;
  }

  // Formatea “YYYY-MM”
  String _monthKey(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}';

  // Devuelve “Septiembre 2025”
  String _monthLabel(DateTime d) {
    const meses = [
      '', 'Enero','Febrero','Marzo','Abril','Mayo','Junio',
      'Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'
    ];
    return '${meses[d.month]} ${d.year}';
  }

  // “YYYY-MM-DD”
  String _yMd(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Mi espacio personal', style: Theme.of(context).textTheme.headlineMedium),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),

      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<PageMemoryResponse>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return ListView(
                children: [
                  const SizedBox(height: 48),
                  Center(child: Text('Error: ${snap.error}')),
                ],
              );
            }

            final page = snap.data!;
            final items = page.content;

            if (items.isEmpty) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                children: [
                  _HeaderCTA(onNew: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NewPersonalMemoryScreen()),
                    );
                    if (mounted) _refresh();
                  }),
                  const SizedBox(height: 24),
                  const Center(child: Text('Aún no hay memorias')),
                ],
              );
            }

            // Agrupar por mes usando createdDate (o photoDate si prefieres)
            final Map<String, List<MemoryResponse>> grouped = {};
            for (final m in items) {
              final d = m.createdDate; // o (m.photoDate ?? m.createdDate)
              final key = _monthKey(d);
              (grouped[key] ??= []).add(m);
            }

            // Ordenar meses (desc)
            final keys = grouped.keys.toList()
              ..sort((a, b) => b.compareTo(a));

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _HeaderCTA(onNew: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NewPersonalMemoryScreen()),
                  );
                  if (mounted) _refresh();
                }),
                const SizedBox(height: 16),

                for (final key in keys) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 12),
                    child: Text(
                      _monthLabel(DateTime.parse('$key-01')),
                      style: tt.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  for (final m in grouped[key]!) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: MemoryCard(
                        title: m.title,
                        subtitle: m.description,
                        time: _yMd(m.photoDate ?? m.createdDate),
                        imageCount: m.files.isNotEmpty ? m.files.length : 0,
                        onTap: () {
                          // TODO: navegar a detalle de memoria personal
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 8),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HeaderCTA extends StatelessWidget {
  final VoidCallback onNew;
  const _HeaderCTA({required this.onNew});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      children: [
        const SizedBox(height: 8),
        Center(
          child: Column(
            children: [
              Text(
                '¿Cómo estás hoy?',
                style: tt.displaySmall?.copyWith(color: Colors.black45),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 240,
                child: PrimaryButton(
                  text: 'Empezar a escribir...',
                  onPressed: onNew,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

