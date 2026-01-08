import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:autovitae/data/models/solicitud_remolque.dart';
import 'package:autovitae/data/models/estado_remolque.dart';

class SolicitudRemolqueRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'solicitudes_remolque';

  // Crear solicitud
  Future<String> create(SolicitudRemolque solicitud) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(solicitud.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Error al crear solicitud de remolque: $e');
    }
  }

  // Obtener solicitud por ID
  Future<SolicitudRemolque?> getById(String uid) async {
    try {
      final doc = await _firestore.collection(_collection).doc(uid).get();
      if (doc.exists) {
        return SolicitudRemolque.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener solicitud de remolque: $e');
    }
  }

  // Obtener solicitudes por cliente
  Future<List<SolicitudRemolque>> getByClienteId(String uidCliente) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('uidCliente', isEqualTo: uidCliente)
          .orderBy('fechaSolicitud', descending: true)
          .get();
      return querySnapshot.docs
          .map((doc) => SolicitudRemolque.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener solicitudes por cliente: $e');
    }
  }

  // Obtener solicitudes por taller
  Future<List<SolicitudRemolque>> getByTallerId(String uidTaller) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('uidTaller', isEqualTo: uidTaller)
          .orderBy('fechaSolicitud', descending: true)
          .get();
      return querySnapshot.docs
          .map((doc) => SolicitudRemolque.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener solicitudes por taller: $e');
    }
  }

  // Obtener solicitudes por vehiculo
  Future<List<SolicitudRemolque>> getByVehiculoId(String uidVehiculo) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('uidVehiculo', isEqualTo: uidVehiculo)
          .orderBy('fechaSolicitud', descending: true)
          .get();
      return querySnapshot.docs
          .map((doc) => SolicitudRemolque.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener solicitudes por vehiculo: $e');
    }
  }

  // Obtener solicitudes por estado
  Future<List<SolicitudRemolque>> getByEstado(EstadoRemolque estado) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('estado', isEqualTo: estado.value)
          .orderBy('fechaSolicitud', descending: true)
          .get();
      return querySnapshot.docs
          .map((doc) => SolicitudRemolque.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener solicitudes por estado: $e');
    }
  }

  // Obtener solicitudes por taller y estado
  Future<List<SolicitudRemolque>> getByTallerAndEstado(
    String uidTaller,
    EstadoRemolque estado,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('uidTaller', isEqualTo: uidTaller)
          .where('estado', isEqualTo: estado.value)
          .orderBy('fechaSolicitud', descending: true)
          .get();
      return querySnapshot.docs
          .map((doc) => SolicitudRemolque.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener solicitudes por taller y estado: $e');
    }
  }

  // Obtener todas las solicitudes
  Future<List<SolicitudRemolque>> getAll() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .orderBy('fechaSolicitud', descending: true)
          .get();
      return querySnapshot.docs
          .map((doc) => SolicitudRemolque.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener solicitudes: $e');
    }
  }

  // Actualizar solicitud
  Future<void> update(String uid, SolicitudRemolque solicitud) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(uid)
          .update(solicitud.toFirestore());
    } catch (e) {
      throw Exception('Error al actualizar solicitud: $e');
    }
  }

  // Actualizar estado
  Future<void> updateEstado(String uid, EstadoRemolque estado) async {
    try {
      await _firestore.collection(_collection).doc(uid).update({
        'estado': estado.value,
      });
    } catch (e) {
      throw Exception('Error al actualizar estado de solicitud: $e');
    }
  }

  // Eliminar solicitud
  Future<void> delete(String uid) async {
    try {
      await _firestore.collection(_collection).doc(uid).delete();
    } catch (e) {
      throw Exception('Error al eliminar solicitud: $e');
    }
  }
}
