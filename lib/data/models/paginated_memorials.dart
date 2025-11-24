import '../../domain/entities/memorial.dart';

class PaginatedMemorials {
  final List<Memorial> items;
  final int page;
  final int totalPages;
  final int totalItems;

  PaginatedMemorials({
    required this.items,
    required this.page,
    required this.totalPages,
    required this.totalItems,
  });
}
