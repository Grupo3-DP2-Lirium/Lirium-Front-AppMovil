import 'package:flutter_frontend/data/models/memorial_request.dart';
import 'package:flutter_frontend/domain/entities/memorial.dart';

abstract class MemorialRepository {
  Future<Memorial> createMemorial(MemorialRequestModel request, String? imagePath, String token);
}
