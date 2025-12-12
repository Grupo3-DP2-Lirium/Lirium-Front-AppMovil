import 'package:flutter/foundation.dart';
import 'package:flutter_frontend/data/models/documentary_model.dart';
import 'package:flutter_frontend/data/services/documentary_service.dart';

/// Provider para manejar documentales de un memorial (sin paginación)
/// Usa DocumentaryService.getDocumentariesByMemorial(memorialId)
class DocumentariesByMemorialProvider extends ChangeNotifier {
  final DocumentaryService _service;

  DocumentariesByMemorialProvider({ DocumentaryService? service })
      : _service = service ?? DocumentaryService();

  // Estado interno
  final List<DocumentaryModel> _documentaries = [];
  bool _loading = false;
  String? _error;
  bool _loaded = false;

  // Memorial actual
  String? _currentMemorialId;

  // Getters
  List<DocumentaryModel> get documentaries => List.unmodifiable(_documentaries);
  bool get loading => _loading;
  String? get error => _error;
  bool get loaded => _loaded;
  String? get currentMemorialId => _currentMemorialId;

  /// Cargar documentales de un memorial
  Future<void> loadDocumentaries({ required String memorialId, bool force = false }) async {
    // Si el memorial cambia, limpiar
    if (_currentMemorialId != null && _currentMemorialId != memorialId) {
      if (kDebugMode) print('Memorial cambió de $_currentMemorialId a $memorialId - limpiando...');
      _clearState();
    }

    // Evitar recarga innecesaria
    if (_currentMemorialId == memorialId && _loaded && !force) {
      if (kDebugMode) print('Documentaries del memorial $memorialId ya cargadas - skipping');
      return;
    }

    _currentMemorialId = memorialId;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      if (kDebugMode) print('Cargando documentales para memorial: $memorialId');

      final response = await _service.getDocumentariesByMemorial(memorialId);

      _documentaries.clear();
      _documentaries.addAll(response);

      if (kDebugMode) {
        print('Recibidos ${_documentaries.length} documentales');
        for (var d in _documentaries) {
          print('Documental: id=${d.idDocumentary}, title=${d.title}');
        }
      }

      _loaded = true;

    } catch (e, st) {
      _error = e.toString();
      if (kDebugMode) print('Error cargando documentales: $e\n$st');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Recargar documentales
  Future<void> reload({ required String memorialId }) async {
    await loadDocumentaries(memorialId: memorialId, force: true);
  }

  /// Agregar localmente
  void addDocumentary(DocumentaryModel doc) {
    if (_documentaries.any((d) => d.idDocumentary == doc.idDocumentary)) return;
    _documentaries.insert(0, doc);
    notifyListeners();
  }

  /// Actualizar localmente
  void updateDocumentary(String id, DocumentaryModel updated) {
    final idx = _documentaries.indexWhere((d) => d.idDocumentary == id);
    if (idx != -1) {
      _documentaries[idx] = updated;
      notifyListeners();
    }
  }

  /// Eliminar localmente
  void removeDocumentary(String id) {
    _documentaries.removeWhere((d) => d.idDocumentary == id);
    notifyListeners();
  }

  /// Limpiar estado
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
  }
}
