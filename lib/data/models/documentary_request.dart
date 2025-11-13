class DocumentaryRequestModel {
  final String memorialId;
  final String title;
  final String? description;

  //NUEVOS Campos de configuración creativa
  final String? narrativeFocus;
  final String? emotionalTone;

  final int durationPerMemory;
  final String? musicTrack;
  final String styleFilter;
  final String transitionType;
  final String resolution;
  final List<String>? excludedMemoryIds;

  DocumentaryRequestModel({
    required this.memorialId,
    required this.title,
    this.description,
    this.narrativeFocus,
    this.emotionalTone,
    this.durationPerMemory = 5,
    this.musicTrack,
    this.styleFilter = 'warm',
    this.transitionType = 'fade',
    this.resolution = '720p',
    this.excludedMemoryIds,
  });

  Map<String, dynamic> toJson() => {
    'memorialId': memorialId,
    'title': title,
    'description': description,
    'narrativeFocus': narrativeFocus,
    'emotionalTone': emotionalTone,
    'durationPerMemory': durationPerMemory,
    'musicTrack': musicTrack,
    'styleFilter': styleFilter,
    'transitionType': transitionType,
    'resolution': resolution,
    'excludedMemoryIds': excludedMemoryIds,
  };

  // ✨ NUEVO: Método copyWith para facilitar actualizaciones
  DocumentaryRequestModel copyWith({
    String? memorialId,
    String? title,
    String? description,
    String? narrativeFocus,
    String? emotionalTone,
    int? durationPerMemory,
    String? musicTrack,
    String? styleFilter,
    String? transitionType,
    String? resolution,
    List<String>? excludedMemoryIds,
  }) {
    return DocumentaryRequestModel(
      memorialId: memorialId ?? this.memorialId,
      title: title ?? this.title,
      description: description ?? this.description,
      narrativeFocus: narrativeFocus ?? this.narrativeFocus,
      emotionalTone: emotionalTone ?? this.emotionalTone,
      durationPerMemory: durationPerMemory ?? this.durationPerMemory,
      musicTrack: musicTrack ?? this.musicTrack,
      styleFilter: styleFilter ?? this.styleFilter,
      transitionType: transitionType ?? this.transitionType,
      resolution: resolution ?? this.resolution,
      excludedMemoryIds: excludedMemoryIds ?? this.excludedMemoryIds,
    );
  }
}