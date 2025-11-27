import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/models/documentary_model.dart';
import 'package:flutter_frontend/data/models/documentary_request.dart';
import 'package:flutter_frontend/data/models/music_track_model.dart';
import 'package:flutter_frontend/data/services/documentary_service.dart';

class DocumentaryProvider extends ChangeNotifier {
  final _service = DocumentaryService();

  List<DocumentaryModel> _documentaries = [];
  List<MusicTrackModel> _musicCatalog = [];

  bool _loading = false;
  bool _loadingMusic = false;
  String? _error;
  DateTime? _lastLoadAttempt;
  
  DocumentaryProvider() {
    print('🎬 DocumentaryProvider constructor - loading: $_loading');
    // Asegurar que siempre inicia en false
    _loading = false;
    _loadingMusic = false;
  }

  Timer? _pollingTimer;
  final Set<String> _processingDocumentaries = {};

  List<DocumentaryModel> get documentaries => _documentaries;
  List<MusicTrackModel> get musicCatalog => _musicCatalog;
  bool get loading => _loading;
  bool get loadingMusic => _loadingMusic;
  String? get error => _error;
  bool get hasProcessingDocumentaries => _processingDocumentaries.isNotEmpty;

  // Filtrar por estado
  List<DocumentaryModel> get draftDocumentaries =>
      _documentaries.where((d) => d.isDraft ||
          d.isCompleted ||
          d.isProcessing ||
          d.isFailed ||
          d.isCancelled).toList();

  List<DocumentaryModel> get publishedDocumentaries =>
      _documentaries.where((d) => d.isPublished).toList();

  /// Validar memorial
  Future<Map<String, dynamic>?> validateMemorial(String memorialId) async {
    try {
      return await _service.validateMemorial(memorialId);
    } catch (e) {
      print('ERROR validating memorial: $e');
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Cargar todos los documentales del usuario
  Future<void> loadMyDocumentaries({bool force = false}) async {
    print('🎬 loadMyDocumentaries called - loading: $_loading, force: $force, documentaries count: ${_documentaries.length}');
    
    // Protección: Si han pasado más de 2 segundos desde el último intento, resetear loading
    if (_loading && _lastLoadAttempt != null) {
      final timeSinceLastAttempt = DateTime.now().difference(_lastLoadAttempt!);
      if (timeSinceLastAttempt.inSeconds > 2) {
        print('⚠️ Resetting stuck loading state (${timeSinceLastAttempt.inSeconds}s since last attempt)');
        _loading = false;
      }
    }
    
    // Si loading es true pero no hay timestamp, también resetear (estado corrupto)
    if (_loading && _lastLoadAttempt == null) {
      print('⚠️ Resetting corrupted loading state (no timestamp)');
      _loading = false;
    }
    
    if (_loading && !force) {
      print('⚠️ Already loading, skipping...');
      return;
    }

    _loading = true;
    _lastLoadAttempt = DateTime.now();
    _error = null;
    notifyListeners();
    
    print('📡 Fetching documentaries from backend...');

    try {
      _documentaries = await _service.getMyDocumentaries();
      print('✅ Loaded ${_documentaries.length} documentaries');
      _checkProcessingDocumentaries();
    } catch (e) {
      _error = e.toString();
      print('❌ ERROR loading documentaries: $e');
    } finally {
      _loading = false;
      notifyListeners();
      print('🏁 loadMyDocumentaries finished - loading: $_loading');
    }
  }

  /// Crear un nuevo documental (ahora crea en DRAFT)
  Future<DocumentaryModel?> createDocumentary(
      DocumentaryRequestModel request,
      ) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final documentary = await _service.createDocumentary(request);
      print('DEBUG: Documentary created in DRAFT: ${documentary.idDocumentary}');

      _documentaries.insert(0, documentary);
      notifyListeners();
      return documentary;
    } catch (e) {
      _error = e.toString();
      print('ERROR creating documentary: $e');
      notifyListeners();
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Iniciar generación del video
  Future<DocumentaryModel?> generateDocumentary(String documentaryId) async {
    try {
      final documentary = await _service.generateDocumentary(documentaryId);
      print('DEBUG: Generation started: ${documentary.idDocumentary}');

      final index = _documentaries.indexWhere((d) => d.idDocumentary == documentaryId);
      if (index != -1) {
        _documentaries[index] = documentary;

        if (documentary.isProcessing) {
          _processingDocumentaries.add(documentaryId);
          _startPolling();
        }

        notifyListeners();
      }

      return documentary;
    } catch (e) {
      _error = e.toString();
      print('ERROR generating documentary: $e');
      notifyListeners();
      return null;
    }
  }

  /// Publicar documental
  Future<DocumentaryModel?> publishDocumentary(String documentaryId) async {
    try {
      final documentary = await _service.publishDocumentary(documentaryId);
      print('DEBUG: Documentary published: ${documentary.idDocumentary}');

      final index = _documentaries.indexWhere((d) => d.idDocumentary == documentaryId);
      if (index != -1) {
        _documentaries[index] = documentary;
        notifyListeners();
      }

      return documentary;
    } catch (e) {
      _error = e.toString();
      print('ERROR publishing documentary: $e');
      notifyListeners();
      return null;
    }
  }

  /// Actualizar documental
  Future<DocumentaryModel?> updateDocumentary(
      String documentaryId,
      DocumentaryRequestModel request,
      ) async {
    try {
      final documentary = await _service.updateDocumentary(documentaryId, request);
      print('DEBUG: Documentary updated: ${documentary.idDocumentary}');

      final index = _documentaries.indexWhere((d) => d.idDocumentary == documentaryId);
      if (index != -1) {
        _documentaries[index] = documentary;
        notifyListeners();
      }

      return documentary;
    } catch (e) {
      _error = e.toString();
      print('ERROR updating documentary: $e');
      notifyListeners();
      return null;
    }
  }

  /// Actualizar estado de un documental específico
  Future<void> refreshDocumentaryStatus(String documentaryId) async {
    try {
      final updated = await _service.getDocumentaryStatus(documentaryId);

      final index = _documentaries.indexWhere(
            (d) => d.idDocumentary == documentaryId,
      );

      if (index != -1) {
        final old = _documentaries[index].progress;

        _documentaries[index] = updated;

        print('Progress ${updated.idDocumentary}: $old -> ${updated.progress} (status: ${updated.status})');

        if (!updated.isProcessing) {
          _processingDocumentaries.remove(documentaryId);
          if (_processingDocumentaries.isEmpty) {
            _stopPolling();
          }
        }

        notifyListeners();
      }
    } catch (e) {
      print('ERROR refreshing documentary status: $e');
    }
  }

  /// Cancelar un documental
  Future<bool> cancelDocumentary(String documentaryId) async {
    try {
      await _service.cancelDocumentary(documentaryId);
      _processingDocumentaries.remove(documentaryId);
      await refreshDocumentaryStatus(documentaryId);
      return true;
    } catch (e) {
      _error = e.toString();
      print('ERROR cancelling documentary: $e');
      notifyListeners();
      return false;
    }
  }

  /// Eliminar un documental
  Future<bool> deleteDocumentary(String documentaryId) async {
    try {
      await _service.deleteDocumentary(documentaryId);
      _documentaries.removeWhere((d) => d.idDocumentary == documentaryId);
      _processingDocumentaries.remove(documentaryId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      print('ERROR deleting documentary: $e');
      notifyListeners();
      return false;
    }
  }

  /// Cargar catálogo de música
  Future<void> loadMusicCatalog() async {
    if (_musicCatalog.isNotEmpty) return;

    _loadingMusic = true;
    notifyListeners();

    try {
      _musicCatalog = await _service.getMusicCatalog();
    } catch (e) {
      print('ERROR loading music catalog: $e');
    } finally {
      _loadingMusic = false;
      notifyListeners();
    }
  }

  void _checkProcessingDocumentaries() {
    _processingDocumentaries.clear();

    for (var doc in _documentaries) {
      if (doc.isProcessing) {
        _processingDocumentaries.add(doc.idDocumentary);
      }
    }

    if (_processingDocumentaries.isNotEmpty) {
      _startPolling();
    } else {
      _stopPolling();
    }
  }

  void _startPolling() {
    if (_pollingTimer != null && _pollingTimer!.isActive) return;

    _pollingTimer = Timer.periodic(const Duration(minutes: 3), (timer) async {
      for (var documentaryId in _processingDocumentaries.toList()) {
        await refreshDocumentaryStatus(documentaryId);
      }
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  @override
  void dispose() {
    _stopPolling();
    super.dispose();
  }
}