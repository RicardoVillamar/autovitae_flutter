import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:autovitae/data/models/taller.dart';

class TallerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'talleres';

  // Crear taller
  Future<String> create(Taller taller) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(taller.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Error al crear taller: $e');
    }
  }

  // Obtener taller por ID
  Future<Taller?> getById(String uid) async {
    try {
      final doc = await _firestore.collection(_collection).doc(uid).get();
      if (doc.exists) {
        return Taller.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener taller: $e');
    }
  }

  // Obtener taller por gerente
  Future<Taller?> getByGerenteId(String uidGerente) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('uidGerente', isEqualTo: uidGerente)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return Taller.fromFirestore(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener taller por gerente: $e');
    }
  }

  // Obtener todos los talleres
  Future<List<Taller>> getAll() async {
    try {
      final querySnapshot = await _firestore.collection(_collection).get();
      return querySnapshot.docs
          .map((doc) => Taller.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener talleres: $e');
    }
  }

  // Obtener talleres activos
  Future<List<Taller>> getActive() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('estado', isEqualTo: 1)
          .get();
      return querySnapshot.docs
          .map((doc) => Taller.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener talleres activos: $e');
    }
  }

  // Buscar talleres por nombre
  Future<List<Taller>> searchByNombre(String nombre) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('nombre', isGreaterThanOrEqualTo: nombre)
          .where('nombre', isLessThanOrEqualTo: '$nombre\uf8ff')
          .get();
      return querySnapshot.docs
          .map((doc) => Taller.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error al buscar talleres: $e');
    }
  }

  // Actualizar taller
  Future<void> update(String uid, Taller taller) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(uid)
          .update(taller.toFirestore());
    } catch (e) {
      throw Exception('Error al actualizar taller: $e');
    }
  }

  // Eliminar taller (cambiar estado)
  Future<void> delete(String uid) async {
    try {
      await _firestore.collection(_collection).doc(uid).update({'estado': 0});
    } catch (e) {
      throw Exception('Error al eliminar taller: $e');
    }
  }

  // Activar taller
  Future<void> activate(String uid) async {
    try {
      await _firestore.collection(_collection).doc(uid).update({'estado': 1});
    } catch (e) {
      throw Exception('Error al activar taller: $e');
    }
  }
}
