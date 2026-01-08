import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:autovitae/data/models/cliente.dart';

class ClienteRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'clientes';

  // Crear cliente
  Future<String> create(Cliente cliente) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(cliente.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Error al crear cliente: $e');
    }
  }

  // Obtener cliente por ID
  Future<Cliente?> getById(String uid) async {
    try {
      final doc = await _firestore.collection(_collection).doc(uid).get();
      if (doc.exists) {
        return Cliente.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener cliente: $e');
    }
  }

  // Obtener cliente por UID de usuario
  Future<Cliente?> getByUsuarioId(String uidUsuario) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('uidUsuario', isEqualTo: uidUsuario)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return Cliente.fromFirestore(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener cliente por usuario: $e');
    }
  }

  // Obtener todos los clientes
  Future<List<Cliente>> getAll() async {
    try {
      final querySnapshot = await _firestore.collection(_collection).get();
      return querySnapshot.docs
          .map((doc) => Cliente.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener clientes: $e');
    }
  }

  // Obtener clientes por ciudad
  Future<List<Cliente>> getByCiudad(String ciudad) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('ciudad', isEqualTo: ciudad)
          .get();
      return querySnapshot.docs
          .map((doc) => Cliente.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener clientes por ciudad: $e');
    }
  }

  // Actualizar cliente
  Future<void> update(String uid, Cliente cliente) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(uid)
          .update(cliente.toFirestore());
    } catch (e) {
      throw Exception('Error al actualizar cliente: $e');
    }
  }

  // Eliminar cliente (cambiar estado)
  Future<void> delete(String uid) async {
    try {
      await _firestore.collection(_collection).doc(uid).update({'estado': 0});
    } catch (e) {
      throw Exception('Error al eliminar cliente: $e');
    }
  }

  // Activar cliente
  Future<void> activate(String uid) async {
    try {
      await _firestore.collection(_collection).doc(uid).update({'estado': 1});
    } catch (e) {
      throw Exception('Error al activar cliente: $e');
    }
  }
}
