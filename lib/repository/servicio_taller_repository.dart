import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:autovitae/model/dtos/servicio_taller.dart';
import 'package:autovitae/model/enums/categoria_serivicio_taller.dart';

class ServicioTallerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'servicios_taller';

  // Crear servicio
  Future<String> create(ServicioTaller servicio) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(servicio.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Error al crear servicio: $e');
    }
  }

  // Obtener servicio por ID
  Future<ServicioTaller?> getById(String uid) async {
    try {
      final doc = await _firestore.collection(_collection).doc(uid).get();
      if (doc.exists) {
        return ServicioTaller.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener servicio: $e');
    }
  }

  // Obtener servicios por taller
  Future<List<ServicioTaller>> getByTallerId(String uidTaller) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('uidTaller', isEqualTo: uidTaller)
          .get();
      return querySnapshot.docs
          .map((doc) => ServicioTaller.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener servicios por taller: $e');
    }
  }

  // Obtener servicios activos por taller
  Future<List<ServicioTaller>> getActiveByTallerId(String uidTaller) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('uidTaller', isEqualTo: uidTaller)
          .where('estado', isEqualTo: 1)
          .get();
      return querySnapshot.docs
          .map((doc) => ServicioTaller.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener servicios activos por taller: $e');
    }
  }

  // Obtener servicios por categoria
  Future<List<ServicioTaller>> getByCategoria(
    CategoriaSerivicioTaller categoria,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('categoria', isEqualTo: categoria.value)
          .get();
      return querySnapshot.docs
          .map((doc) => ServicioTaller.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener servicios por categoria: $e');
    }
  }

  // Obtener servicios por taller y categoria
  Future<List<ServicioTaller>> getByTallerAndCategoria(
    String uidTaller,
    CategoriaSerivicioTaller categoria,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('uidTaller', isEqualTo: uidTaller)
          .where('categoria', isEqualTo: categoria.value)
          .get();
      return querySnapshot.docs
          .map((doc) => ServicioTaller.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener servicios por taller y categoria: $e');
    }
  }

  // Obtener todos los servicios
  Future<List<ServicioTaller>> getAll() async {
    try {
      final querySnapshot = await _firestore.collection(_collection).get();
      return querySnapshot.docs
          .map((doc) => ServicioTaller.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener servicios: $e');
    }
  }

  // Buscar servicios por nombre
  Future<List<ServicioTaller>> searchByNombre(String nombre) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('nombre', isGreaterThanOrEqualTo: nombre)
          .where('nombre', isLessThanOrEqualTo: '$nombre\uf8ff')
          .get();
      return querySnapshot.docs
          .map((doc) => ServicioTaller.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error al buscar servicios: $e');
    }
  }

  // Actualizar servicio
  Future<void> update(String uid, ServicioTaller servicio) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(uid)
          .update(servicio.toFirestore());
    } catch (e) {
      throw Exception('Error al actualizar servicio: $e');
    }
  }

  // Actualizar precio
  Future<void> updatePrecio(String uid, double precio) async {
    try {
      await _firestore.collection(_collection).doc(uid).update({
        'precio': precio,
      });
    } catch (e) {
      throw Exception('Error al actualizar precio: $e');
    }
  }

  // Eliminar servicio (cambiar estado)
  Future<void> delete(String uid) async {
    try {
      await _firestore.collection(_collection).doc(uid).update({'estado': 0});
    } catch (e) {
      throw Exception('Error al eliminar servicio: $e');
    }
  }

  // Activar servicio
  Future<void> activate(String uid) async {
    try {
      await _firestore.collection(_collection).doc(uid).update({'estado': 1});
    } catch (e) {
      throw Exception('Error al activar servicio: $e');
    }
  }
}
