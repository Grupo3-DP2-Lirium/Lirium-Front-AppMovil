import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/models/memorial.dart';
import 'package:flutter_frontend/data/services/memorial_service.dart';
import 'package:flutter_frontend/presentation/screens/memorial/new_memorial/relation_memorial_screen.dart';
import '../../components/buttons/primary_button.dart';
import '../../components/buttons/secondary_button.dart';
import '../memories/personal_space_screen.dart';
import '../memories/new_personal_memory_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _service = MemorialService();
  late Future<List<Memorial>> _future;

  static const _p = EdgeInsets; // alias para padding

  @override
  void initState() {
    super.initState();
    _future = _service.fetchMyMemorials();
  }

  // Navegación (conecta a tus rutas)
  void _goToCreateMemorial() {}
  void _goToPersonalSpace() => Navigator.push(context, MaterialPageRoute(builder: (_) => const PersonalSpaceScreen()),);
  void _goToAddMemory() {
    //Botón de arriba
  }
  void _goToNewReflection() { // botón de Mi Espacio Personal
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NewPersonalMemoryScreen()),
    );
  }
  void _openMemorial(Memorial m) {}

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(
                'https://i.pravatar.cc/150?img=5',
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                  text: TextSpan(
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.black87),
                    children: const [
                      TextSpan(text: 'Hola, '),
                      TextSpan(
                        text: 'Fer!',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                Text(
                  '¿Qué momento especial quieres guardar hoy?',
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: Colors.black54),
                ),
              ],
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.notifications_none),
          ),
        ],
      ),

      body: FutureBuilder<List<Memorial>>(
        future: _future,
        builder: (context, snap) {
          final widgets = <Widget>[];

          final memorials = snap.data ?? <Memorial>[];

          if (memorials.isNotEmpty) {
            widgets.add(
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _goToAddMemory,
                    child: const Text('Añadir un recuerdo'),
                  ),
                ),
              ),
            );
          }


          if (snap.connectionState == ConnectionState.waiting) {
            widgets.add(const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(child: CircularProgressIndicator()),
            ));
            return ListView(children: widgets);
          }

          //final memorials = snap.data ?? <Memorial>[];

          if (memorials.isEmpty) {
            widgets.addAll([
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _StartCard(onCreate: _goToCreateMemorial),
              ),
              const SizedBox(height: 16),
              const _DateLabel(text: '3 de junio'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _MiniTimelineCard(
                  title: 'Un día como hoy',
                  subtitle: 'Empezaste a formar parte de Lirium',
                  onTap: () {},
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _PersonalSpaceCard(onTap: _goToPersonalSpace),
              ),
              const SizedBox(height: 24),
            ]);
          } else {
            // TODO: estado con memoriales (carrusel + resto)
          }

          return ListView(children: widgets);
        },
      ),
    );
  }
}

/// ---------- COMPONENTES PRIVADOS ----------

class _CardContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const _CardContainer({required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outlineVariant.withOpacity(.5);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: outline),
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }
}

class _StartCard extends StatelessWidget {
  final VoidCallback onCreate;
  const _StartCard({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return _CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Ícono morado con sombra suave
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: cs.primary,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: cs.primary.withOpacity(.25), blurRadius: 16, offset: const Offset(0, 6))],
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text('¡Empezar es fácil!', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 8),
          Text(
            'Crea tu primer memorial y construye un legado que perdure para siempre',
            style: tt.bodyMedium?.copyWith(color: Colors.black54, height: 1.3),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 44,
            child: PrimaryButton(
              text: 'Crear mi primer memorial',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NewMemorialRelationScreen()),
                );
              },
              height: 52,
              isFullWidth: true,
            )

          ),
        ],
      ),
    );
  }
}

class _DateLabel extends StatelessWidget {
  final String text;
  const _DateLabel({required this.text});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
      child: Text(text, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.black54)),
    );
  }
}

class _MiniTimelineCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _MiniTimelineCard({required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _CardContainer(
      padding: const EdgeInsets.all(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Row(
          children: [
            const CircleAvatar(radius: 18, backgroundColor: Color(0xFFEDEDED)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.black87)),
                const SizedBox(height: 2),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54)),
              ]),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.remove_red_eye_outlined, size: 18, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}

class _PersonalSpaceCard extends StatelessWidget {
  final VoidCallback onTap;
  const _PersonalSpaceCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(18), // para que el splash respete las esquinas
      onTap: onTap, // 👈 tocar la card lleva a PersonalSpaceScreen
      child: _CardContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Mi Espacio Personal', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              '“Un lugar seguro para procesar y guardar tus memorias más profundas”',
              style: tt.bodyMedium?.copyWith(color: Colors.black54, height: 1.3),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 42,
              child: SecondaryButton(
                text: 'Añadir una reflexión',
                textColor: const Color(0xFF6366F1),
                onPressed: () {
                  // 👇 botón abre el editor de nueva reflexión
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NewPersonalMemoryScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

