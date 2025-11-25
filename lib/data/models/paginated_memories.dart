import '../../domain/entities/memory.dart';

class PaginatedMemories{
  final List<Memory> items;
  final int page;
  final int totalPages;
  final int totalItems;

  PaginatedMemories({
    required this.items,
    required this.page,
    required this.totalPages,
    required this.totalItems,
  });
}
