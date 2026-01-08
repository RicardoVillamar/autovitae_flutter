import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:autovitae/data/models/servicio_taller.dart';
import 'package:autovitae/data/models/categoria_serivicio_taller.dart';

class ServicioTallerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'servicios';

  CollectionReference<Map<String, dynamic>> _getTallerServiciosRef(
    String uidTaller,
  ) {
    return _firestore
        .collection('talleres')
        .doc(uidTaller)
        .collection(_collection);
  }

  // Crear servicio
  Future<String> create(ServicioTaller servicio) async {
    try {
      final docRef = await _getTallerServiciosRef(
        servicio.uidTaller,
      ).add(servicio.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Error al crear servicio: $e');
    }
  }

  // Obtener servicio por ID (Busca en todos los talleres usando collectionGroup)
  Future<ServicioTaller?> getById(String uid) async {
    try {
      final querySnapshot = await _firestore
          .collectionGroup(_collection)
          .where(FieldPath.documentId, isEqualTo: uid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return ServicioTaller.fromFirestore(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener servicio: $e');
    }
  }

  // Obtener servicios por taller
  Future<List<ServicioTaller>> getByTallerId(String uidTaller) async {
    try {
      final querySnapshot = await _getTallerServiciosRef(uidTaller).get();
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
      final querySnapshot = await _getTallerServiciosRef(
        uidTaller,
      ).where('estado', isEqualTo: 1).get();
      return querySnapshot.docs
          .map((doc) => ServicioTaller.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener servicios activos por taller: $e');
    }
  }

  // Obtener servicios por categoria (Global)
  Future<List<ServicioTaller>> getByCategoria(
    CategoriaSerivicioTaller categoria,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collectionGroup(_collection)
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
      final querySnapshot = await _getTallerServiciosRef(
        uidTaller,
      ).where('categoria', isEqualTo: categoria.value).get();
      return querySnapshot.docs
          .map((doc) => ServicioTaller.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener servicios por taller y categoria: $e');
    }
  }

  // Obtener todos los servicios (Global)
  Future<List<ServicioTaller>> getAll() async {
    try {
      final querySnapshot = await _firestore.collectionGroup(_collection).get();
      return querySnapshot.docs
          .map((doc) => ServicioTaller.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener servicios: $e');
    }
  }

  // Buscar servicios por nombre (Global)
  Future<List<ServicioTaller>> searchByNombre(String nombre) async {
    try {
      final querySnapshot = await _firestore
          .collectionGroup(_collection)
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
      await _getTallerServiciosRef(
        servicio.uidTaller,
      ).doc(uid).update(servicio.toFirestore());
    } catch (e) {
      throw Exception('Error al actualizar servicio: $e');
    }
  }

  // Actualizar precio (Requiere búsqueda global si no se tiene uidTaller)
  Future<void> updatePrecio(String uid, double precio) async {
    try {
      final querySnapshot = await _firestore
          .collectionGroup(_collection)
          .where(FieldPath.documentId, isEqualTo: uid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await querySnapshot.docs.first.reference.update({'precio': precio});
      }
    } catch (e) {
      throw Exception('Error al actualizar precio: $e');
    }
  }

  // Eliminar servicio (cambiar estado)
  Future<void> delete(String uid) async {
    try {
      final querySnapshot = await _firestore
          .collectionGroup(_collection)
          .where(FieldPath.documentId, isEqualTo: uid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await querySnapshot.docs.first.reference.update({'estado': 0});
      }
    } catch (e) {
      throw Exception('Error al eliminar servicio: $e');
    }
  }

  // Activar servicio
  Future<void> activate(String uid) async {
    try {
      final querySnapshot = await _firestore
          .collectionGroup(_collection)
          .where(FieldPath.documentId, isEqualTo: uid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await querySnapshot.docs.first.reference.update({'estado': 1});
      }
    } catch (e) {
      throw Exception('Error al activar servicio: $e');
    }
  }
}
