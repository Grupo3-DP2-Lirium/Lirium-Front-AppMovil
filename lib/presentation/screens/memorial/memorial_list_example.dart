import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/memorial_provider.dart';
import '../../../domain/entities/memorial.dart';
import '../../components/common/app_colors.dart';

/// Ejemplo de pantalla que muestra cómo usar el MemorialProvider mejorado
class MemorialListExample extends StatefulWidget {
  const MemorialListExample({super.key});

  @override
  State<MemorialListExample> createState() => _MemorialListExampleState();
}

class _MemorialListExampleState extends State<MemorialListExample> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    // Cargar todos los memoriales del usuario al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MemorialProvider>();

      // Usar el nuevo método cargarTodo() que carga propios + colaborativos
      if (!provider.loadedMis || !provider.loadedColab) {
        provider.cargarTodo();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Memoriales'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<MemorialProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Barra de búsqueda
              _buildSearchBar(provider),

              // Estadísticas
              _buildStats(provider),

              // Lista de memoriales
              Expanded(child: _buildMemorialList(provider)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navegar a crear nuevo memorial
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchBar(MemorialProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar memoriales...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildStats(MemorialProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildStatCard(
            'Total',
            provider.totalMemoriales.toString(),
            Icons.folder,
            AppColors.primary,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            'Propios',
            provider.misMemoriales.length.toString(),
            Icons.person,
            Colors.blue,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            'Colaborativos',
            provider.colaborativos.length.toString(),
            Icons.group,
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemorialList(MemorialProvider provider) {
    // Mostrar loading si está cargando y no hay datos
    if ((provider.cargandoMis || provider.cargandoColab) &&
        !provider.tieneMemoriales) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    // Mostrar error si hay algún error
    if (provider.errorMis != null || provider.errorColab != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error al cargar memoriales',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              provider.errorMis ?? provider.errorColab ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.cargarTodo(force: true),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    // Usar el nuevo método de búsqueda
    final memoriales = provider.buscarMemoriales(_searchQuery);

    // Mostrar mensaje si no hay memoriales
    if (memoriales.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isEmpty ? Icons.folder_open : Icons.search_off,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty
                  ? 'No tienes memoriales aún'
                  : 'No se encontraron memoriales',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isEmpty
                  ? 'Crea tu primer memorial para comenzar'
                  : 'Intenta con otros términos de búsqueda',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Mostrar lista de memoriales
    return RefreshIndicator(
      onRefresh: () => provider.cargarTodo(force: true),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: memoriales.length,
        itemBuilder: (context, index) {
          final memorial = memoriales[index];
          return _buildMemorialCard(memorial, provider);
        },
      ),
    );
  }

  Widget _buildMemorialCard(Memorial memorial, MemorialProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: memorial.profilePhotoUrl != null
              ? NetworkImage(memorial.profilePhotoUrl!)
              : null,
          child: memorial.profilePhotoUrl == null
              ? Text(
                  memorial.name.isNotEmpty
                      ? memorial.name[0].toUpperCase()
                      : 'M',
                )
              : null,
        ),
        title: Text(
          memorial.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(memorial.nickname),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  memorial.isOwner == true ? Icons.person : Icons.group,
                  size: 16,
                  color: memorial.isOwner == true ? Colors.blue : Colors.green,
                ),
                const SizedBox(width: 4),
                Text(
                  memorial.isOwner == true ? 'Propio' : 'Colaborativo',
                  style: TextStyle(
                    fontSize: 12,
                    color: memorial.isOwner == true
                        ? Colors.blue
                        : Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  memorial.isJournal ? Icons.book : Icons.photo_library,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  memorial.isJournal ? 'Diario' : 'Memorial',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'view':
                // Navegar a detalles del memorial
                break;
              case 'edit':
                // Navegar a editar memorial
                break;
              case 'delete':
                _showDeleteDialog(memorial, provider);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility),
                  SizedBox(width: 8),
                  Text('Ver detalles'),
                ],
              ),
            ),
            if (memorial.canEdit == true)
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Editar'),
                  ],
                ),
              ),
            if (memorial.isOwner == true)
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Eliminar', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
          ],
        ),
        onTap: () {
          // Navegar a detalles del memorial
        },
      ),
    );
  }

  void _showDeleteDialog(Memorial memorial, MemorialProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Memorial'),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${memorial.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.eliminarMemorial(memorial.idMemorial);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Memorial "${memorial.name}" eliminado'),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
