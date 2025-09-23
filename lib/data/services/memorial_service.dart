import 'dart:async';
import '../models/memorial.dart';

class MemorialService {
  /// Mock: deja vacío para ver el estado “sin memoriales”.
  /// Agrega elementos para ver el estado “con memoriales”.
  Future<List<Memorial>> fetchMyMemorials() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return <Memorial>[
     //  Memorial(id: '1', name: 'LUPI'),
     //  Memorial(id: '2', name: 'CARMEN'),
     //  Memorial(id: '3', name: 'BRACO'),
    ];
  }
}
