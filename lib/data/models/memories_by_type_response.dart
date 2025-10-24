import 'memory_response.dart';

class MemoriesByTypeResponse {
  final Map<String, List<MemoryResponse>> memoriesByType;
  final Map<String, int> countByType;
  final int totalMemories;

  MemoriesByTypeResponse({
    required this.memoriesByType,
    required this.countByType,
    required this.totalMemories,
  });

  factory MemoriesByTypeResponse.fromJson(Map<String, dynamic> json) {
    Map<String, List<MemoryResponse>> memoriesByType = {};
    Map<String, int> countByType = {};

    // Parse memoriesByType
    if (json['memoriesByType'] != null) {
      (json['memoriesByType'] as Map<String, dynamic>).forEach((key, value) {
        memoriesByType[key] = (value as List<dynamic>)
            .map((item) => MemoryResponse.fromJson(item as Map<String, dynamic>))
            .toList();
      });
    }

    // Parse countByType
    if (json['countByType'] != null) {
      (json['countByType'] as Map<String, dynamic>).forEach((key, value) {
        countByType[key] = value as int;
      });
    }

    return MemoriesByTypeResponse(
      memoriesByType: memoriesByType,
      countByType: countByType,
      totalMemories: json['totalMemories'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'memoriesByType': memoriesByType.map((key, value) => 
          MapEntry(key, value.map((memory) => memory.toJson()).toList())),
      'countByType': countByType,
      'totalMemories': totalMemories,
    };
  }
}