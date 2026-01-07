import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:autovitae/model/dtos/usuario.dart';

class UsuarioRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'usuarios';

  // Crear usuario
  Future<String> create(Usuario usuario) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(usuario.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Error al crear usuario: $e');
    }
  }

  // Obtener usuario por ID
  Future<Usuario?> getById(String uid) async {
    try {
      final doc = await _firestore.collection(_collection).doc(uid).get();
      if (doc.exists) {
        return Usuario.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener usuario: $e');
    }
  }

  // Obtener usuario por correo
  Future<Usuario?> getByEmail(String correo) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('correo', isEqualTo: correo)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return Usuario.fromFirestore(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener usuario por correo: $e');
    }
  }

  // Obtener usuario por cedula
  Future<Usuario?> getByCedula(String cedula) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('cedula', isEqualTo: cedula)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return Usuario.fromFirestore(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener usuario por cedula: $e');
    }
  }

  // Obtener todos los usuarios
  Future<List<Usuario>> getAll() async {
    try {
      final querySnapshot = await _firestore.collection(_collection).get();
      return querySnapshot.docs
          .map((doc) => Usuario.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener usuarios: $e');
    }
  }

  // Obtener usuarios por rol
  Future<List<Usuario>> getByRol(String rol) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('rol', isEqualTo: rol)
          .get();
      return querySnapshot.docs
          .map((doc) => Usuario.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener usuarios por rol: $e');
    }
  }

  // Actualizar usuario
  Future<void> update(String uid, Usuario usuario) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(uid)
          .update(usuario.toFirestore());
    } catch (e) {
      throw Exception('Error al actualizar usuario: $e');
    }
  }

  // Eliminar usuario (cambiar estado)
  Future<void> delete(String uid) async {
    try {
      await _firestore.collection(_collection).doc(uid).update({'estado': 0});
    } catch (e) {
      throw Exception('Error al eliminar usuario: $e');
    }
  }

  // Activar usuario
  Future<void> activate(String uid) async {
    try {
      await _firestore.collection(_collection).doc(uid).update({'estado': 1});
    } catch (e) {
      throw Exception('Error al activar usuario: $e');
    }
  }

  // Eliminar permanentemente
  Future<void> deletePermanently(String uid) async {
    try {
      await _firestore.collection(_collection).doc(uid).delete();
    } catch (e) {
      throw Exception('Error al eliminar usuario permanentemente: $e');
    }
  }
}
