import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/services/memory_service.dart';
import 'package:flutter_frontend/domain/entities/memory.dart';

class MemoryProvider extends ChangeNotifier {
  final _service = MemoryService();

  List<Memory> _misMemorias = [];
  List<Memory> _memoriasFiltradas = [];
  bool _cargando = false;
  String? _error;
  bool _loaded = false;
  String _textoBusqueda = '';

  List<Memory> get misMemorias => _misMemorias;
  List<Memory> get memoriasFiltradas => _memoriasFiltradas;
  bool get cargando => _cargando;
  String? get error => _error;
  bool get loaded => _loaded;
  String get textoBusqueda => _textoBusqueda;

  /// Cargar memorias desde el backend
  Future<void> cargarMisMemorias({bool force = false}) async {
    if (_cargando || (_loaded && !force)) return;

    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      _misMemorias = await _service.listMemoriesByAuthor();
      _memoriasFiltradas = List.from(_misMemorias);
      _loaded = true;
      print("📦 Memorias cargadas desde backend: ${_misMemorias.length}");
      for (var m in _misMemorias) {
        print("📝 ${m.title} - ${m.id}");
      }

    } catch (e) {
      _error = e.toString();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  /// Filtrar memorias según texto
  void filtrarMemorias(String texto) {
    _textoBusqueda = texto;
    if (texto.isEmpty) {
      _memoriasFiltradas = List.from(_misMemorias);
    } else {
      _memoriasFiltradas = _misMemorias
          .where((m) =>
      (m.title?.toLowerCase().contains(texto.toLowerCase()) ?? false) ||
          (m.description
              ?.toLowerCase()
              .contains(texto.toLowerCase()) ??
              false))
          .toList();
    }
    notifyListeners();
  }

  /// Agregar memoria nueva
  void agregarMemoria(Memory memoria) {
    _misMemorias.insert(0, memoria);
    filtrarMemorias(_textoBusqueda); // actualiza también el filtro
    notifyListeners();
  }

  /// Actualizar memoria existente por índice
  void actualizarMemoria(int index, Memory memoriaActualizada) {
    if (index >= 0 && index < _misMemorias.length) {
      _misMemorias[index] = memoriaActualizada;
      filtrarMemorias(_textoBusqueda);
      notifyListeners();
    }
  }

  /// Recargar desde backend
  Future<void> recargar() async {
    _loaded = false;
    await cargarMisMemorias(force: true);
  }
}
