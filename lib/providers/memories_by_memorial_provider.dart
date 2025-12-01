import 'package:flutter/foundation.dart';
import 'package:flutter_frontend/data/models/memory_response.dart';
import 'package:flutter_frontend/data/services/memory_service.dart';
import 'package:flutter_frontend/domain/entities/memory.dart';

/// Provider para manejar las memorias asociadas a UN memorial (por memorialId).
/// - Usa MemoryService.listMemories(memorialId, page, size)
/// - Convierte MemoryResponse -> Memory usando MemoryResponse.toEntity()
/// - Soporta paginación, recarga, búsqueda local, agregar/actualizar/eliminar en memoria local
class MemoriesByMemorialProvider extends ChangeNotifier {
  final MemoryService _service;

  MemoriesByMemorialProvider({ MemoryService? service }) : _service = service ?? MemoryService();

  // Estado interno
  final List<Memory> _memories = [];
  bool _loading = false;
  String? _error;
  bool _loaded = false;

  // Paginación
  int _page = 0;
  final int _pageSize = 10;
  bool _hasMore = true;

  // Filtro local (search)
  String _searchText = '';

  // -------------------------
  // Getters públicos
  // -------------------------
  /// Todas las memorias cargadas
  List<Memory> get memories => List.unmodifiable(_memories);

  /// Memorias aplicando filtro local (search)
  List<Memory> get filteredMemories {
    if (_searchText.isEmpty) return memories;
    final q = _searchText.toLowerCase();
    return _memories.where((m) =>
    (m.title.toLowerCase().contains(q)) ||
        (m.description.toLowerCase().contains(q))
    ).toList();
  }

  bool get loading => _loading;
  String? get error => _error;
  bool get loaded => _loaded;
  bool get hasMore => _hasMore;
  String get searchText => _searchText;
  int get currentPage => _page;
  int get pageSize => _pageSize;

  // -------------------------
  // Acciones / API
  // -------------------------
  /// Carga inicial o siguiente página de memorias para un memorial específico.
  /// Si [force] es true reinicia el listado.
  Future<void> loadMemories({ required String memorialId, bool force = false }) async {
    if (force) {
      _memories.clear();
      _page = 0;
      _hasMore = true;
      _loaded = false;
      _error = null;
    }

    if (!_hasMore) return;

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.listMemories(
        memorialId: memorialId,
        page: _page,
        size: _pageSize,
      );

      // response.content es List<MemoryResponse>
      final List<MemoryResponse> raw = response.content;
      final nuevos = raw.map((r) => r.toEntity()).toList();

      _memories.addAll(nuevos);

      // Actualizar paginación según respuesta
      final current = response.number; // página que devolvió el backend
      final totalPages = response.totalPages;
      _hasMore = (current + 1) < totalPages;

      // Avanzar contador local solo si backend devolvió items OK
      _page = current + 1;

      _loaded = true;
    } catch (e, st) {
      _error = e.toString();
      if (kDebugMode) {
        // útil para debugging en dev
        print('MemoriesByMemorialProvider.loadMemories ERROR: $e\n$st');
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Forzar recarga desde página 0
  Future<void> reload({ required String memorialId }) async {
    await loadMemories(memorialId: memorialId, force: true);
  }

  /// Filtrado local simple
  void setSearchText(String txt) {
    _searchText = txt;
    notifyListeners();
  }

  /// Agregar memoria localmente (ej: tras crear una nueva memoria)
  void addMemory(Memory m) {
    _memories.insert(0, m);
    notifyListeners();
  }

  /// Actualizar memoria localmente por id
  void updateMemory(String id, Memory updated) {
    final idx = _memories.indexWhere((m) => m.id == id);
    if (idx >= 0) {
      _memories[idx] = updated;
      notifyListeners();
    }
  }

  /// Eliminar memoria localmente por id
  void removeMemory(String id) {
    _memories.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  /// Limpiar todo el estado del provider
  void clear() {
    _memories.clear();
    _loading = false;
    _error = null;
    _loaded = false;
    _page = 0;
    _hasMore = true;
    _searchText = '';
    notifyListeners();
  }
}
