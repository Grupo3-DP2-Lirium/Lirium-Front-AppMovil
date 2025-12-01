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

  // Trackear qué memorial está cargado
  String? _currentMemorialId;

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

  // Getter para el memorial actual
  String? get currentMemorialId => _currentMemorialId;

  // -------------------------
  // Acciones / API
  // -------------------------
  /// Carga inicial o siguiente página de memorias para un memorial específico.
  /// Si [force] es true reinicia el listado.
  Future<void> loadMemories({ required String memorialId, bool force = false }) async {
    // 🔧 FIX: Si es un memorial diferente, auto-limpiar
    if (_currentMemorialId != null && _currentMemorialId != memorialId) {
      if (kDebugMode) {
        print('⚠️ Memorial cambió de $_currentMemorialId a $memorialId - limpiando...');
      }
      _clearState();
    }

    // 🔧 FIX: Si ya está cargado el mismo memorial y no es forzado, no cargar de nuevo
    if (_currentMemorialId == memorialId && _loaded && !force) {
      if (kDebugMode) {
        print('ℹ️ Memorial $memorialId ya está cargado - skipping');
      }
      return;
    }

    if (force) {
      if (kDebugMode) {
        print('🔄 Forzando recarga para memorial $memorialId');
      }
      _clearState();
    }

    if (!_hasMore && !force) {
      if (kDebugMode) {
        print('ℹ️ No hay más páginas para cargar');
      }
      return;
    }

    //  Guardar el memorial actual
    _currentMemorialId = memorialId;

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      if (kDebugMode) {
        print('📡 Cargando memorias: memorialId=$memorialId, page=$_page, size=$_pageSize');
      }

      final response = await _service.listMemories(
        memorialId: memorialId,
        page: _page,
        size: _pageSize,
      );

      // response.content es List<MemoryResponse>
      final List<MemoryResponse> raw = response.content;
      final nuevos = raw.map((r) => r.toEntity()).toList();

      if (kDebugMode) {
        print('✅ Recibidas ${nuevos.length} memorias - Total acumulado: ${_memories.length + nuevos.length}');
      }

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
        print('❌ MemoriesByMemorialProvider.loadMemories ERROR: $e\n$st');
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
    // Verificar que no exista ya (evitar duplicados)
    if (_memories.any((existing) => existing.id == m.id)) {
      if (kDebugMode) {
        print('⚠️ Memoria ${m.id} ya existe - no se agrega duplicada');
      }
      return;
    }

    _memories.insert(0, m);
    if (kDebugMode) {
      print('➕ Memoria ${m.id} agregada localmente');
    }
    notifyListeners();
  }

  /// Actualizar memoria localmente por id
  void updateMemory(String id, Memory updated) {
    final idx = _memories.indexWhere((m) => m.id == id);
    if (idx >= 0) {
      _memories[idx] = updated;
      if (kDebugMode) {
        print('✏️ Memoria $id actualizada localmente');
      }
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
    if (kDebugMode) {
      print('🧹 Limpiando provider completamente');
    }
    _clearState();
    _currentMemorialId = null; // También limpiar el memorial actual
    notifyListeners();
  }

  /// Helper privado para limpiar estado sin notificar
  void _clearState() {
    _memories.clear();
    _loading = false;
    _error = null;
    _loaded = false;
    _page = 0;
    _hasMore = true;
    _searchText = '';
  }
}