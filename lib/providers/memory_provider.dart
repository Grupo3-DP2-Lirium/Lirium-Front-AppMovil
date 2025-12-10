import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/services/memory_service.dart';
import 'package:flutter_frontend/domain/entities/file.dart';
import 'package:flutter_frontend/domain/entities/memory.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class MemoryProvider extends ChangeNotifier {
  final _service = MemoryService();

  List<Memory> _misMemorias = [];
  List<Memory> _memoriasFiltradas = [];
  bool _cargando = false;
  String? _error;
  bool _loaded = false;
  String _textoBusqueda = '';
  String? _tipoArchivoFiltro; // 'image', 'video', 'audio', 'text', null
  final Map<String, List<File>> _archivosLocales = {};

  List<Memory> get misMemorias => _misMemorias;
  List<Memory> get memoriasFiltradas => _memoriasFiltradas;
  bool get cargando => _cargando;
  String? get error => _error;
  bool get loaded => _loaded;
  String get textoBusqueda => _textoBusqueda;
  String? get tipoArchivoFiltro => _tipoArchivoFiltro;
  Map<String, List<File>> get archivosLocales => _archivosLocales;

  int _pageMis = 0;
  bool _hasMoreMis = true;

  Future<void> cargarMisMemorias({bool force = false}) async {
    if (force) {
      _misMemorias = [];
      _memoriasFiltradas = [];
      _pageMis = 0;
      _hasMoreMis = true;
    }
    if (!_hasMoreMis) return;

    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.listMemoriesByAuthor(
        page: _pageMis,
        size: 6,
      );
      // forzar a lista vacía si es null
      _misMemorias.addAll(result.items);
      _aplicarFiltros(); // Aplicar filtros en lugar de copiar directamente
      _hasMoreMis = (result.page + 1) < result.totalPages;
      _pageMis++;
    } catch (e) {
      _error = e.toString();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  /// Descargar archivo desde URL y devolver un File personalizado con ruta local
  Future<File> _descargarArchivo(
    String url,
    String memoryId,
    String originalName,
    String type,
    String mimeType,
  ) async {
    final dir = await getApplicationDocumentsDirectory();
    final ext = originalName.contains('.')
        ? ''
        : '.${url.split('.').last.split('?').first}';
    final filePath = '${dir.path}/memory_${memoryId}_${originalName}$ext';

    final localFile = io.File(filePath);

    if (!await localFile.exists()) {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        await localFile.writeAsBytes(res.bodyBytes);
      } else {
        throw Exception('No se pudo descargar el archivo: ${res.statusCode}');
      }
    }

    return File(
      id: '', // si lo quieres puedes pasar el id real
      name: localFile.path, // ruta local
      originalName: originalName,
      type: type,
      mimeType: mimeType,
      url: url, // la URL original en Azure
      size: await localFile.length().then((v) => v.toDouble()),
      uploadedDate: DateTime.now(), // si quieres usar la fecha real
    );
  }

  /// Filtrar memorias según texto y tipo de archivo
  void filtrarMemorias(String texto) {
    _textoBusqueda = texto;
    _aplicarFiltros();
  }

  /// Filtrar memorias por tipo de archivo
  void filtrarPorTipoArchivo(String? tipo) {
    _tipoArchivoFiltro = tipo;
    _aplicarFiltros();
  }

  /// Limpiar filtro de tipo de archivo
  void limpiarFiltroTipoArchivo() {
    _tipoArchivoFiltro = null;
    _aplicarFiltros();
  }

  /// Limpiar todos los filtros
  void limpiarTodosFiltros() {
    _textoBusqueda = '';
    _tipoArchivoFiltro = null;
    _aplicarFiltros();
  }

  /// Aplicar todos los filtros activos
  void _aplicarFiltros() {
    List<Memory> memoriasFiltradas = List.from(_misMemorias);

    // Filtro por texto
    if (_textoBusqueda.isNotEmpty) {
      memoriasFiltradas = memoriasFiltradas
          .where(
            (m) =>
                (m.title.toLowerCase().contains(
                  _textoBusqueda.toLowerCase(),
                )) ||
                (m.description.toLowerCase().contains(
                  _textoBusqueda.toLowerCase(),
                )),
          )
          .toList();
    }

    // Filtro por tipo de archivo
    if (_tipoArchivoFiltro != null) {
      memoriasFiltradas = memoriasFiltradas.where((m) {
        switch (_tipoArchivoFiltro) {
          case 'image':
            return m.images.isNotEmpty;
          case 'video':
            return m.videos.isNotEmpty;
          case 'audio':
            return m.audios.isNotEmpty;
          case 'text':
            return m.files.isEmpty || m.files.every((f) => f.type == 'text');
          default:
            return true;
        }
      }).toList();
    }

    _memoriasFiltradas = memoriasFiltradas;
    notifyListeners();
  }

  /// Agregar memoria nueva
  void agregarMemoria(Memory memoria) {
    _misMemorias.insert(0, memoria);
    _aplicarFiltros(); // actualiza también los filtros
    notifyListeners();
  }

  /// Actualizar memoria existente por índice
  void actualizarMemoria(int index, Memory memoriaActualizada) {
    if (index >= 0 && index < _misMemorias.length) {
      _misMemorias[index] = memoriaActualizada;
      _aplicarFiltros();
      notifyListeners();
    }
  }

  /// Recargar desde backend
  Future<void> recargar() async {
    _loaded = false;
    await cargarMisMemorias(force: true);
  }

  void eliminarMemoria(String id) {
    _misMemorias.removeWhere((m) => m.id == id);
    _memoriasFiltradas.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  /// Limpia todo el estado del provider para logout
  void limpiarTodo() {
    _misMemorias = [];
    _memoriasFiltradas = [];
    _cargando = false;
    _error = null;
    _loaded = false;
    _textoBusqueda = '';
    _tipoArchivoFiltro = null;
    _archivosLocales.clear();
    _pageMis = 0;
    _hasMoreMis = true;
    notifyListeners();
  }
}
