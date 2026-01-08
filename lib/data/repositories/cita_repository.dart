import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:autovitae/data/models/cita.dart';
import 'package:autovitae/data/models/estado_cita.dart';

class CitaRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'citas';

  // Crear cita
  Future<String> create(Cita cita) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(cita.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Error al crear cita: $e');
    }
  }

  // Obtener cita por ID
  Future<Cita?> getById(String uid) async {
    try {
      final doc = await _firestore.collection(_collection).doc(uid).get();
      if (doc.exists) {
        return Cita.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener cita: $e');
    }
  }

  // Obtener citas por cliente
  Future<List<Cita>> getByClienteId(String uidCliente) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('uidCliente', isEqualTo: uidCliente)
          .get();
      final citas = querySnapshot.docs
          .map((doc) => Cita.fromFirestore(doc))
          .toList();
      citas.sort((a, b) => b.fechaCita.compareTo(a.fechaCita));
      return citas;
    } catch (e) {
      throw Exception('Error al obtener citas por cliente: $e');
    }
  }

  // Obtener citas por taller
  Future<List<Cita>> getByTallerId(String uidTaller) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('uidTaller', isEqualTo: uidTaller)
          .get();
      final citas = querySnapshot.docs
          .map((doc) => Cita.fromFirestore(doc))
          .toList();
      citas.sort((a, b) => b.fechaCita.compareTo(a.fechaCita));
      return citas;
    } catch (e) {
      throw Exception('Error al obtener citas por taller: $e');
    }
  }

  // Obtener citas por vehiculo
  Future<List<Cita>> getByVehiculoId(String uidVehiculo) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('uidVehiculo', isEqualTo: uidVehiculo)
          .get();
      final citas = querySnapshot.docs
          .map((doc) => Cita.fromFirestore(doc))
          .toList();
      citas.sort((a, b) => b.fechaCita.compareTo(a.fechaCita));
      return citas;
    } catch (e) {
      throw Exception('Error al obtener citas por vehiculo: $e');
    }
  }

  // Obtener citas por estado
  Future<List<Cita>> getByEstado(EstadoCita estado) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('estado', isEqualTo: estado.value)
          .get();
      final citas = querySnapshot.docs
          .map((doc) => Cita.fromFirestore(doc))
          .toList();
      citas.sort((a, b) => b.fechaCita.compareTo(a.fechaCita));
      return citas;
    } catch (e) {
      throw Exception('Error al obtener citas por estado: $e');
    }
  }

  // Obtener citas por taller y estado
  Future<List<Cita>> getByTallerAndEstado(
    String uidTaller,
    EstadoCita estado,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('uidTaller', isEqualTo: uidTaller)
          .where('estado', isEqualTo: estado.value)
          .get();
      final citas = querySnapshot.docs
          .map((doc) => Cita.fromFirestore(doc))
          .toList();
      citas.sort((a, b) => b.fechaCita.compareTo(a.fechaCita));
      return citas;
    } catch (e) {
      throw Exception('Error al obtener citas por taller y estado: $e');
    }
  }

  // Obtener todas las citas
  Future<List<Cita>> getAll() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .orderBy('fechaCita', descending: true)
          .get();
      return querySnapshot.docs.map((doc) => Cita.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Error al obtener citas: $e');
    }
  }

  // Actualizar cita
  Future<void> update(String uid, Cita cita) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(uid)
          .update(cita.toFirestore());
    } catch (e) {
      throw Exception('Error al actualizar cita: $e');
    }
  }

  // Actualizar estado de cita
  Future<void> updateEstado(String uid, EstadoCita estado) async {
    try {
      await _firestore.collection(_collection).doc(uid).update({
        'estado': estado.value,
      });
    } catch (e) {
      throw Exception('Error al actualizar estado de cita: $e');
    }
  }

  // Eliminar cita
  Future<void> delete(String uid) async {
    try {
      await _firestore.collection(_collection).doc(uid).delete();
    } catch (e) {
      throw Exception('Error al eliminar cita: $e');
    }
  }
}
