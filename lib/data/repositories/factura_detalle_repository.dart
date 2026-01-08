import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:autovitae/data/models/factura_detalle.dart';

class FacturaDetalleRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'facturas_detalle';

  // Crear detalle
  Future<String> create(FacturaDetalle detalle) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(detalle.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Error al crear detalle de factura: $e');
    }
  }

  // Obtener detalle por ID
  Future<FacturaDetalle?> getById(String uid) async {
    try {
      final doc = await _firestore.collection(_collection).doc(uid).get();
      if (doc.exists) {
        return FacturaDetalle.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener detalle de factura: $e');
    }
  }

  // Obtener detalles por factura
  Future<List<FacturaDetalle>> getByFacturaId(String uidFactura) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('uidFactura', isEqualTo: uidFactura)
          .get();
      return querySnapshot.docs
          .map((doc) => FacturaDetalle.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener detalles por factura: $e');
    }
  }

  // Obtener detalles por servicio
  Future<List<FacturaDetalle>> getByServicioId(String uidServicio) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('uidServicio', isEqualTo: uidServicio)
          .get();
      return querySnapshot.docs
          .map((doc) => FacturaDetalle.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener detalles por servicio: $e');
    }
  }

  // Obtener todos los detalles
  Future<List<FacturaDetalle>> getAll() async {
    try {
      final querySnapshot = await _firestore.collection(_collection).get();
      return querySnapshot.docs
          .map((doc) => FacturaDetalle.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener detalles: $e');
    }
  }

  // Actualizar detalle
  Future<void> update(String uid, FacturaDetalle detalle) async {
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

  // Eliminar todos los detalles de una factura
  Future<void> deleteByFacturaId(String uidFactura) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('uidFactura', isEqualTo: uidFactura)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception('Error al eliminar detalles de la factura: $e');
    }
  }
}
