import 'memory_response.dart';

class MemoriesOrganizedResponse {
  final List<MemoryResponse> memories;
  final Map<String, dynamic> metadata;
  final int totalElements;
  final int totalPages;
  final int currentPage;
  final String filterType;
  final String sortBy;

  MemoriesOrganizedResponse({
    required this.memories,
    required this.metadata,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
    required this.filterType,
    required this.sortBy,
  });

  factory MemoriesOrganizedResponse.fromJson(Map<String, dynamic> json) {
    return MemoriesOrganizedResponse(
      memories: (json['memories'] as List<dynamic>?)
          ?.map((item) => MemoryResponse.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      totalElements: json['totalElements'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      currentPage: json['currentPage'] as int? ?? 0,
      filterType: json['filterType'] as String? ?? 'all',
      sortBy: json['sortBy'] as String? ?? 'date',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'memories': memories.map((memory) => memory.toJson()).toList(),
      'metadata': metadata,
      'totalElements': totalElements,
      'totalPages': totalPages,
      'currentPage': currentPage,
      'filterType': filterType,
      'sortBy': sortBy,
    };
  }
}