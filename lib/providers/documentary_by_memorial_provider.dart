import 'package:flutter/foundation.dart';
import 'package:flutter_frontend/data/models/documentary_model.dart';
import 'package:flutter_frontend/data/services/documentary_service.dart';

/// Provider para manejar los documentales de un memorial específico
/// - Usa DocumentaryService.listDocumentaries(memorialId, page, size)
/// - Convierte JSON -> DocumentaryModel
/// - Soporta paginación, recarga, búsqueda local, agregar/actualizar/eliminar en memoria local
class DocumentariesByMemorialProvider extends ChangeNotifier {
  final DocumentaryService _service;

  DocumentariesByMemorialProvider({ DocumentaryService? service })
      : _service = service ?? DocumentaryService();

  // Estado interno
  final List<DocumentaryModel> _documentaries = [];
  bool _loading = false;
  String? _error;
  bool _loaded = false;

  // Trackear memorial actual
  String? _currentMemorialId;

  // Paginación
  int _page = 0;
  final int _pageSize = 10;
  bool _hasMore = true;

  // Filtro local
  String _searchText = '';

  // -------------------------
  // Getters públicos
  // -------------------------
  List<DocumentaryModel> get documentaries => List.unmodifiable(_documentaries);

  List<DocumentaryModel> get filteredDocumentaries {
    if (_searchText.isEmpty) return documentaries;
    final q = _searchText.toLowerCase();
    return _documentaries.where((d) =>
    d.title.toLowerCase().contains(q) ||
        d.description.toLowerCase().contains(q)
    ).toList();
  }

  bool get loading => _loading;
  String? get error => _error;
  bool get loaded => _loaded;
  bool get hasMore => _hasMore;
  String get searchText => _searchText;
  int get currentPage => _page;
  int get pageSize => _pageSize;
  String? get currentMemorialId => _currentMemorialId;

  Future<void> loadDocumentaries({ required String memorialId, bool force = false }) async {
    // Si cambia el memorial, limpiar estado
    if (_currentMemorialId != null && _currentMemorialId != memorialId) {
      _clearState();
    }

    // Evitar recargar si ya cargado y no forzado
    if (_currentMemorialId == memorialId && _loaded && !force) return;

    if (force) _clearState();
    if (!_hasMore && !force) return;

    _currentMemorialId = memorialId;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.listDocumentaries(
        memorialId: memorialId,
        page: _page,
        size: _pageSize,
      );

      if (response == null || response.content == null) {
        // No hay datos, terminar sin crash
        _hasMore = false;
        _loaded = true;
        return;
      }

      final nuevos = response.content.map((json) => DocumentaryModel.fromJson(json)).toList();
      _documentaries.addAll(nuevos);

      final current = response.number ?? 0;
      final totalPages = response.totalPages ?? 1;
      _hasMore = (current + 1) < totalPages;
      _page = current + 1;
      _loaded = true;

    } catch (e, st) {
      _error = e.toString();
      if (kDebugMode) print('DocumentariesByMemorialProvider.loadDocumentaries ERROR: $e\n$st');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> reload({ required String memorialId }) async {
    await loadDocumentaries(memorialId: memorialId, force: true);
  }

  void setSearchText(String txt) {
    _searchText = txt;
    notifyListeners();
  }

  void addDocumentary(DocumentaryModel doc) {
    if (_documentaries.any((d) => d.idDocumentary == doc.idDocumentary)) return;
    _documentaries.insert(0, doc);
    notifyListeners();
  }

  void updateDocumentary(String id, DocumentaryModel updated) {
    final idx = _documentaries.indexWhere((d) => d.idDocumentary == id);
    if (idx >= 0) {
      _documentaries[idx] = updated;
      notifyListeners();
    }
  }

  void removeDocumentary(String id) {
    _documentaries.removeWhere((d) => d.idDocumentary == id);
    notifyListeners();
  }

  void clear() {
    _clearState();
    _currentMemorialId = null;
    notifyListeners();
  }

  void _clearState() {
    _documentaries.clear();
    _loading = false;
    _error = null;
    _loaded = false;
    _page = 0;
    _hasMore = true;
    _searchText = '';
  }
}
