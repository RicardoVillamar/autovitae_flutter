import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:autovitae/data/models/mantenimiento_detalle.dart';

class MantenimientoDetalleRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'mantenimientos_detalle';

  // Crear detalle
  Future<String> create(MantenimientoDetalle detalle) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(detalle.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Error al crear detalle de mantenimiento: $e');
    }
  }

  // Obtener detalle por ID
  Future<MantenimientoDetalle?> getById(String uid) async {
    try {
      final doc = await _firestore.collection(_collection).doc(uid).get();
      if (doc.exists) {
        return MantenimientoDetalle.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener detalle de mantenimiento: $e');
    }
  }

  // Obtener detalles por mantenimiento
  Future<List<MantenimientoDetalle>> getByMantenimientoId(
    String uidMantenimiento,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('uidMantenimiento', isEqualTo: uidMantenimiento)
          .get();
      return querySnapshot.docs
          .map((doc) => MantenimientoDetalle.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener detalles por mantenimiento: $e');
    }
  }

  // Obtener detalles por servicio
  Future<List<MantenimientoDetalle>> getByServicioId(String uidServicio) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('uidServicio', isEqualTo: uidServicio)
          .get();
      return querySnapshot.docs
          .map((doc) => MantenimientoDetalle.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener detalles por servicio: $e');
    }
  }

  // Obtener todos los detalles
  Future<List<MantenimientoDetalle>> getAll() async {
    try {
      final querySnapshot = await _firestore.collection(_collection).get();
      return querySnapshot.docs
          .map((doc) => MantenimientoDetalle.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener detalles: $e');
    }
  }

  // Actualizar detalle
  Future<void> update(String uid, MantenimientoDetalle detalle) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(uid)
          .update(detalle.toFirestore());
    } catch (e) {
      throw Exception('Error al actualizar detalle: $e');
    }
  }

  // Actualizar cantidad
  Future<void> updateCantidad(String uid, int cantidad) async {
    try {
      await _firestore.collection(_collection).doc(uid).update({
        'cantidad': cantidad,
      });
    } catch (e) {
      throw Exception('Error al actualizar cantidad: $e');
    }
  }

  // Eliminar detalle
  Future<void> delete(String uid) async {
    try {
      await _firestore.collection(_collection).doc(uid).delete();
    } catch (e) {
      throw Exception('Error al eliminar detalle: $e');
    }
  }

  // Eliminar todos los detalles de un mantenimiento
  Future<void> deleteByMantenimientoId(String uidMantenimiento) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('uidMantenimiento', isEqualTo: uidMantenimiento)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception('Error al eliminar detalles del mantenimiento: $e');
    }
  }
}
