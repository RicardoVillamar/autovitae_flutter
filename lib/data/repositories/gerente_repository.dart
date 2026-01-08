import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:autovitae/data/models/gerente.dart';

class GerenteRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'gerente';

  // Crear gerente
  Future<String> create(Gerente gerente) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(gerente.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Error al crear gerente: $e');
    }
  }

  // Obtener gerente por ID
  Future<Gerente?> getById(String uid) async {
    try {
      final doc = await _firestore.collection(_collection).doc(uid).get();
      if (doc.exists) {
        return Gerente.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener gerente: $e');
    }
  }

  // Obtener gerente por UID de usuario
  Future<Gerente?> getByUsuarioId(String uidUsuario) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('uidUsuario', isEqualTo: uidUsuario)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return Gerente.fromFirestore(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener gerente por usuario: $e');
    }
  }

  // Obtener gerente por UID de taller
  Future<Gerente?> getByTallerId(String uidTaller) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('uidTaller', isEqualTo: uidTaller)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return Gerente.fromFirestore(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener gerente por taller: $e');
    }
  }

  // Obtener todos los gerentes
  Future<List<Gerente>> getAll() async {
    try {
      final querySnapshot = await _firestore.collection(_collection).get();
      return querySnapshot.docs
          .map((doc) => Gerente.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener gerentes: $e');
    }
  }

  // Actualizar gerente
  Future<void> update(String uid, Gerente gerente) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(uid)
          .update(gerente.toFirestore());
    } catch (e) {
      throw Exception('Error al actualizar gerente: $e');
    }
  }

  // Actualizar primer login
  Future<void> updatePrimerLogin(String uid, bool primerLogin) async {
    try {
      await _firestore.collection(_collection).doc(uid).update({
        'primerLogin': primerLogin,
      });
    } catch (e) {
      throw Exception('Error al actualizar primer login: $e');
    }
  }

  // Eliminar gerente (cambiar estado)
  Future<void> delete(String uid) async {
    try {
      await _firestore.collection(_collection).doc(uid).update({'estado': 0});
    } catch (e) {
      throw Exception('Error al eliminar gerente: $e');
    }
  }

  // Activar gerente
  Future<void> activate(String uid) async {
    try {
      await _firestore.collection(_collection).doc(uid).update({'estado': 1});
    } catch (e) {
      throw Exception('Error al activar gerente: $e');
    }
  }
}
