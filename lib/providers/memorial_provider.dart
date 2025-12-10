import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/services/memorial_service.dart';
import 'package:flutter_frontend/domain/entities/memorial.dart';

class MemorialProvider extends ChangeNotifier {
  final _service = MemorialService();

  List<Memorial> _misMemoriales = [];
  List<Memorial> _colaborativos = [];

  bool _cargandoMis = false;
  bool _cargandoColab = false;
  String? _errorMis;
  String? _errorColab;

  List<Memorial> get misMemoriales => _misMemoriales;
  List<Memorial> get colaborativos => _colaborativos;
  bool get cargandoMis => _cargandoMis;
  bool get cargandoColab => _cargandoColab;
  String? get errorMis => _errorMis;
  String? get errorColab => _errorColab;

  bool _loadedMis = false;
  bool _loadedColab = false;
  bool get loadedMis => _loadedMis;
  bool get loadedColab => _loadedColab;

  int _pageMis = 0;
  bool _hasMoreMis = true;

  Future<void> cargarMisMemoriales({bool force = false}) async {
    print(
      '📋 cargarMisMemoriales - force: $force, cargando: $_cargandoMis, loaded: $_loadedMis',
    );

    if (force) {
      _misMemoriales = [];
      _pageMis = 0;
      _hasMoreMis = true;
      _loadedMis = false;
    }

    // Si ya está cargado y no es forzado, no cargar de nuevo
    if (_loadedMis && !force) {
      print('⏭️ Skipped - ya cargado');
      return;
    }

    if (!_hasMoreMis && !force) {
      print('⏭️ Skipped - no hay más páginas');
      return;
    }

    _cargandoMis = true;
    _errorMis = null;
    notifyListeners();

    try {
      print('📡 Llamando getMemorials(page: $_pageMis, size: 6)...');
      final result = await _service.getMemorials(page: _pageMis, size: 6);

      _misMemoriales.addAll(result.items);
      _hasMoreMis = (result.page + 1) < result.totalPages;
      _pageMis++;

      // Marcar como cargado en la primera página exitosa
      if (_pageMis == 1) {
        _loadedMis = true;
      }

      print(
        '✅ Mis memoriales cargados: ${_misMemoriales.length} total, hasMore: $_hasMoreMis',
      );
    } catch (e) {
      print('❌ Error cargando mis memoriales: $e');
      _errorMis = e.toString();
      _misMemoriales = [];
    } finally {
      _cargandoMis = false;
      notifyListeners();
    }
  }

  Future<void> cargarColaborativos({bool force = false}) async {
    print(
      '📋 cargarColaborativos - force: $force, cargando: $_cargandoColab, loaded: $_loadedColab',
    );

    if (force) {
      _loadedColab = false;
    }

    if (_cargandoColab || (_loadedColab && !force)) {
      print('⏭️ Skipped - ya cargado o cargando');
      return;
    }

    _cargandoColab = true;
    _errorColab = null;
    notifyListeners();

    try {
      print('📡 Llamando getMyCollaborations()...');

      // ✅ Usar el nuevo endpoint específico
      _colaborativos = await _service.getMyCollaborations();
      _loadedColab = true;

      print('✅ Colaborativos cargados: ${_colaborativos.length}');
    } catch (e) {
      print('❌ Error cargando colaborativos: $e');
      _errorColab = e.toString();
      _colaborativos = [];
    } finally {
      _cargandoColab = false;
      notifyListeners();
    }
  }

  Future<void> recargarTodo() async {
    _loadedMis = false;
    _loadedColab = false;
    await Future.wait([
      cargarMisMemoriales(force: true),
      cargarColaborativos(force: true),
    ]);
  }

  /// Agrega un nuevo memorial al inicio de la lista de misMemoriales
  void agregarMemorial(Memorial memorial) {
    _misMemoriales.insert(0, memorial);
    notifyListeners();
  }

  void eliminarMemorial(String id) {
    _misMemoriales.removeWhere((m) => m.idMemorial == id);
    _colaborativos.removeWhere((m) => m.idMemorial == id);
    notifyListeners();
  }

  /// Obtiene todos los memoriales del usuario (propios + colaborativos)
  List<Memorial> get todosLosMemoriales {
    final todos = <Memorial>[];
    todos.addAll(_misMemoriales);
    todos.addAll(_colaborativos);

    // Eliminar duplicados por ID y ordenar por fecha de creación
    final Map<String, Memorial> uniqueMemorials = {};
    for (final memorial in todos) {
      uniqueMemorials[memorial.idMemorial] = memorial;
    }

    final result = uniqueMemorials.values.toList();
    result.sort((a, b) => b.createdDate.compareTo(a.createdDate));
    return result;
  }

  /// Busca memoriales por nombre
  List<Memorial> buscarMemoriales(String query) {
    if (query.isEmpty) return todosLosMemoriales;

    final queryLower = query.toLowerCase();
    return todosLosMemoriales.where((memorial) {
      return memorial.name.toLowerCase().contains(queryLower) ||
          memorial.nickname.toLowerCase().contains(queryLower) ||
          memorial.description.toLowerCase().contains(queryLower);
    }).toList();
  }

  /// Obtiene un memorial por ID
  Memorial? obtenerMemorialPorId(String id) {
    try {
      return todosLosMemoriales.firstWhere((m) => m.idMemorial == id);
    } catch (e) {
      return null;
    }
  }

  /// Verifica si hay memoriales cargados
  bool get tieneMemoriales =>
      _misMemoriales.isNotEmpty || _colaborativos.isNotEmpty;

  /// Cuenta total de memoriales
  int get totalMemoriales => _misMemoriales.length + _colaborativos.length;

  /// Carga inicial completa (mis memoriales + colaborativos)
  Future<void> cargarTodo({bool force = false}) async {
    print('🚀 Cargando todos los memoriales del usuario...');

    await Future.wait([
      cargarMisMemoriales(force: force),
      cargarColaborativos(force: force),
    ]);

    print(
      '✅ Carga completa: ${_misMemoriales.length} propios + ${_colaborativos.length} colaborativos = $totalMemoriales total',
    );
  }

  /// Actualiza un memorial existente
  void actualizarMemorial(Memorial memorial) {
    // Buscar en mis memoriales
    final indexMis = _misMemoriales.indexWhere(
      (m) => m.idMemorial == memorial.idMemorial,
    );
    if (indexMis != -1) {
      _misMemoriales[indexMis] = memorial;
      notifyListeners();
      return;
    }

    // Buscar en colaborativos
    final indexColab = _colaborativos.indexWhere(
      (m) => m.idMemorial == memorial.idMemorial,
    );
    if (indexColab != -1) {
      _colaborativos[indexColab] = memorial;
      notifyListeners();
    }
  }

  void limpiarTodo() {
    print('🧹 Limpiando MemorialProvider...');

    _misMemoriales = [];
    _colaborativos = [];

    _cargandoMis = false;
    _cargandoColab = false;

    _errorMis = null;
    _errorColab = null;

    _loadedMis = false;
    _loadedColab = false;

    // Resetear paginación
    _pageMis = 0;
    _hasMoreMis = true;

    notifyListeners();

    print('✅ MemorialProvider limpiado');
  }
}
