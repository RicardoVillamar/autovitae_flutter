import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:autovitae/data/models/mantenimiento.dart';
import 'package:autovitae/data/models/estado_mantenimiento.dart';

class MantenimientoRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'mantenimientos';

  // Crear mantenimiento
  Future<String> create(Mantenimiento mantenimiento) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(mantenimiento.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Error al crear mantenimiento: $e');
    }
  }

  // Obtener mantenimiento por ID
  Future<Mantenimiento?> getById(String uid) async {
    try {
      final doc = await _firestore.collection(_collection).doc(uid).get();
      if (doc.exists) {
        return Mantenimiento.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener mantenimiento: $e');
    }
  }

  // Obtener mantenimiento por cita
  Future<Mantenimiento?> getByCitaId(String uidCita) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('uidCita', isEqualTo: uidCita)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return Mantenimiento.fromFirestore(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener mantenimiento por cita: $e');
    }
  }

  // Obtener mantenimientos por cliente
  Future<List<Mantenimiento>> getByClienteId(String uidCliente) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('uidCliente', isEqualTo: uidCliente)
          .get();
      final mantenimientos = querySnapshot.docs
          .map((doc) => Mantenimiento.fromFirestore(doc))
          .toList();
      mantenimientos.sort((a, b) => b.fechaProgramada.compareTo(a.fechaProgramada));
      return mantenimientos;
    } catch (e) {
      throw Exception('Error al obtener mantenimientos por cliente: $e');
    }
  }

  // Obtener mantenimientos por taller
  Future<List<Mantenimiento>> getByTallerId(String uidTaller) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('uidTaller', isEqualTo: uidTaller)
          .get();
      final mantenimientos = querySnapshot.docs
          .map((doc) => Mantenimiento.fromFirestore(doc))
          .toList();
      mantenimientos.sort((a, b) => b.fechaProgramada.compareTo(a.fechaProgramada));
      return mantenimientos;
    } catch (e) {
      throw Exception('Error al obtener mantenimientos por taller: $e');
    }
  }

  // Obtener mantenimientos por estado
  Future<List<Mantenimiento>> getByEstado(EstadoMantenimiento estado) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('estado', isEqualTo: estado.value)
          .get();
      final mantenimientos = querySnapshot.docs
          .map((doc) => Mantenimiento.fromFirestore(doc))
          .toList();
      mantenimientos.sort((a, b) => b.fechaProgramada.compareTo(a.fechaProgramada));
      return mantenimientos;
    } catch (e) {
      throw Exception('Error al obtener mantenimientos por estado: $e');
    }
  }

  // Obtener mantenimientos por taller y estado
  Future<List<Mantenimiento>> getByTallerAndEstado(
    String uidTaller,
    EstadoMantenimiento estado,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('uidTaller', isEqualTo: uidTaller)
          .where('estado', isEqualTo: estado.value)
          .get();
      final mantenimientos = querySnapshot.docs
          .map((doc) => Mantenimiento.fromFirestore(doc))
          .toList();
      mantenimientos.sort((a, b) => b.fechaProgramada.compareTo(a.fechaProgramada));
      return mantenimientos;
    } catch (e) {
      throw Exception(
        'Error al obtener mantenimientos por taller y estado: $e',
      );
    }
  }

  // Obtener todos los mantenimientos
  Future<List<Mantenimiento>> getAll() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .orderBy('fechaProgramada', descending: true)
          .get();
      return querySnapshot.docs
          .map((doc) => Mantenimiento.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener mantenimientos: $e');
    }
  }

  // Actualizar mantenimiento
  Future<void> update(String uid, Mantenimiento mantenimiento) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(uid)
          .update(mantenimiento.toFirestore());
    } catch (e) {
      throw Exception('Error al actualizar mantenimiento: $e');
    }
  }

  // Actualizar estado
  Future<void> updateEstado(String uid, EstadoMantenimiento estado) async {
    try {
      final Map<String, dynamic> updateData = {'estado': estado.value};
      
      // Si cambia a enProceso, establecer fechaInicio
      if (estado == EstadoMantenimiento.enProceso) {
        updateData['fechaInicio'] = Timestamp.now().millisecondsSinceEpoch;
      }
      
      // Si cambia a finalizado, establecer fechaFin
      if (estado == EstadoMantenimiento.finalizado) {
        updateData['fechaFin'] = Timestamp.now().millisecondsSinceEpoch;
      }

      await _firestore.collection(_collection).doc(uid).update(updateData);
    } catch (e) {
      throw Exception('Error al actualizar estado: $e');
    }
  }

  // Finalizar mantenimiento
  Future<void> finalizar(String uid) async {
    try {
      await _firestore.collection(_collection).doc(uid).update({
        'estado': EstadoMantenimiento.finalizado.value,
        'fechaFin': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Error al finalizar mantenimiento: $e');
    }
  }

  // Eliminar mantenimiento
  Future<void> delete(String uid) async {
    try {
      await _firestore.collection(_collection).doc(uid).delete();
    } catch (e) {
      throw Exception('Error al eliminar mantenimiento: $e');
    }
  }
}
