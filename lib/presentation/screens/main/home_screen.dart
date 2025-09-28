import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/services/memorial_service.dart';
import 'package:flutter_frontend/domain/entities/memorial.dart';
import 'package:flutter_frontend/presentation/screens/main/widgets/card_container.dart';
import 'package:flutter_frontend/presentation/screens/main/widgets/date_label_card.dart';
import 'package:flutter_frontend/presentation/screens/main/widgets/mini_timeline_card.dart';
import 'package:flutter_frontend/presentation/screens/main/widgets/personal_space_card.dart';
import 'package:flutter_frontend/presentation/screens/main/widgets/start_card.dart';
import 'package:flutter_frontend/presentation/screens/memorial/new_memorial_screen/relation_memorial_screen.dart';
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
    _future = _service.getMemorials();
  }

  // Navegación (conecta a tus rutas)
  void _goToCreateMemorial() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NewMemorialRelationScreen()),
    );
  }
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
                child: StartCard(onCreate: _goToCreateMemorial),
              ),
              const SizedBox(height: 16),
              const DateLabel(text: '3 de junio'),
            ]);
          } else {
            // TODO: estado con memoriales (carrusel + resto)
            widgets.add(
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  "Mis memoriales",
                  style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            );

          for (final m in memorials) {
            widgets.add(
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: InkWell(
              onTap: () => _openMemorial(m),
              child: CardContainer(
                child: Row(
                children: [
                  //Esto es temporal solo para local
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: m.profilePhotoBase64 != null && m.profilePhotoBase64!.isNotEmpty
                        ? MemoryImage(base64Decode(m.profilePhotoBase64!))
                        : (m.profilePhotoUrl != null && m.profilePhotoUrl!.isNotEmpty
                        ? NetworkImage(m.profilePhotoUrl!)
                        : const AssetImage("assets/images/default_avatar.png")) as ImageProvider,
                  ),
                  const SizedBox(width: 16),
                Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(m.name,
                    style: tt.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                    if (m.nickname != null && m.nickname!.isNotEmpty)
                    Text("“${m.nickname}”",
                    style: tt.bodySmall
                        ?.copyWith(color: Colors.black54)),
                  ],
                ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black54),
            ],
            ),
            ),
            ),
            ),
            );
            }
          }

          // Recordatorios
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: MiniTimelineCard(
              title: 'Un día como hoy',
              subtitle: 'Empezaste a formar parte de Lirium',
              onTap: () {},
            ),
          );
          const SizedBox(height: 16);
          // Espacio Personal
          Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: PersonalSpaceCard(onTap: _goToPersonalSpace),
          );
          const SizedBox(height: 24);

          return ListView(children: widgets);
        },
      ),
    );
  }
}
