class DocumentaryRequestModel {
  final String memorialId;
  final String title;
  final String? description;
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
    'durationPerMemory': durationPerMemory,
    'musicTrack': musicTrack,
    'styleFilter': styleFilter,
    'transitionType': transitionType,
    'resolution': resolution,
    'excludedMemoryIds': excludedMemoryIds,
  };
}