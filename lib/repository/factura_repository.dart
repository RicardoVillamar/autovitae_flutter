import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:autovitae/model/dtos/factura.dart';
import 'package:autovitae/model/enums/estado_factura.dart';
import 'package:autovitae/model/enums/metodo_pago.dart';

class FacturaRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'facturas';

  // Crear factura
  Future<String> create(Factura factura) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(factura.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Error al crear factura: $e');
    }
  }

  // Obtener factura por ID
  Future<Factura?> getById(String uid) async {
    try {
      final doc = await _firestore.collection(_collection).doc(uid).get();
      if (doc.exists) {
        return Factura.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener factura: $e');
    }
  }

  // Obtener factura por mantenimiento
  Future<Factura?> getByMantenimientoId(String uidMantenimiento) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('uidMantenimiento', isEqualTo: uidMantenimiento)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return Factura.fromFirestore(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener factura por mantenimiento: $e');
    }
  }

  // Obtener facturas por cliente
  Future<List<Factura>> getByClienteId(String uidCliente) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('uidCliente', isEqualTo: uidCliente)
          .orderBy('fechaEmision', descending: true)
          .get();
      return querySnapshot.docs
          .map((doc) => Factura.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener facturas por cliente: $e');
    }
  }

  // Obtener facturas por estado
  Future<List<Factura>> getByEstado(EstadoFactura estado) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('estado', isEqualTo: estado.value)
          .orderBy('fechaEmision', descending: true)
          .get();
      return querySnapshot.docs
          .map((doc) => Factura.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener facturas por estado: $e');
    }
  }

  // Obtener facturas por metodo de pago
  Future<List<Factura>> getByMetodoPago(MetodoPago metodoPago) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('metodoPago', isEqualTo: metodoPago.value)
          .orderBy('fechaEmision', descending: true)
          .get();
      return querySnapshot.docs
          .map((doc) => Factura.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener facturas por metodo de pago: $e');
    }
  }

  // Obtener todas las facturas
  Future<List<Factura>> getAll() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .orderBy('fechaEmision', descending: true)
          .get();
      return querySnapshot.docs
          .map((doc) => Factura.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener facturas: $e');
    }
  }

  // Actualizar factura
  Future<void> update(String uid, Factura factura) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(uid)
          .update(factura.toFirestore());
    } catch (e) {
      throw Exception('Error al actualizar factura: $e');
    }
  }

  // Actualizar estado
  Future<void> updateEstado(String uid, EstadoFactura estado) async {
    try {
      await _firestore.collection(_collection).doc(uid).update({
        'estado': estado.value,
      });
    } catch (e) {
      throw Exception('Error al actualizar estado de factura: $e');
    }
  }

  // Marcar como pagada
  Future<void> marcarPagada(String uid) async {
    try {
      await _firestore.collection(_collection).doc(uid).update({
        'estado': EstadoFactura.pagada.value,
      });
    } catch (e) {
      throw Exception('Error al marcar factura como pagada: $e');
    }
  }

  // Eliminar factura
  Future<void> delete(String uid) async {
    try {
      await _firestore.collection(_collection).doc(uid).delete();
    } catch (e) {
      throw Exception('Error al eliminar factura: $e');
    }
  }
}
