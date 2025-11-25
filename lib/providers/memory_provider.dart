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
  final Map<String, List<File>> _archivosLocales = {};

  List<Memory> get misMemorias => _misMemorias;
  List<Memory> get memoriasFiltradas => _memoriasFiltradas;
  bool get cargando => _cargando;
  String? get error => _error;
  bool get loaded => _loaded;
  String get textoBusqueda => _textoBusqueda;
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
      final result = await _service.listMemoriesByAuthor(page: _pageMis, size: 6);
      // forzar a lista vacía si es null
      _misMemorias.addAll(result.items);
      _memoriasFiltradas = List.from(_misMemorias);
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
  Future<File> _descargarArchivo(String url, String memoryId, String originalName, String type, String mimeType) async {
    final dir = await getApplicationDocumentsDirectory();
    final ext = originalName.contains('.') ? '' : '.${url.split('.').last.split('?').first}';
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

  void eliminarMemoria(String id) {
    _misMemorias.removeWhere((m) => m.id == id);
    _memoriasFiltradas.removeWhere((m) => m.id == id);
    notifyListeners();
  }
}
