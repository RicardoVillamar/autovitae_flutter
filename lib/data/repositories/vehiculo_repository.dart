import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:autovitae/data/models/vehiculo.dart';

class VehiculoRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'vehiculos';

  // Crear vehiculo
  Future<String> create(Vehiculo vehiculo) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(vehiculo.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Error al crear vehiculo: $e');
    }
  }

  // Obtener vehiculo por ID
  Future<Vehiculo?> getById(String uid) async {
    try {
      final doc = await _firestore.collection(_collection).doc(uid).get();
      if (doc.exists) {
        return Vehiculo.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener vehiculo: $e');
    }
  }

  // Obtener vehiculos por cliente
  Future<List<Vehiculo>> getByClienteId(String uidCliente) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('uidCliente', isEqualTo: uidCliente)
          .get();
      return querySnapshot.docs
          .map((doc) => Vehiculo.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener vehiculos por cliente: $e');
    }
  }

  // Obtener vehiculo por placa
  Future<Vehiculo?> getByPlaca(String placa) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('placa', isEqualTo: placa)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return Vehiculo.fromFirestore(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener vehiculo por placa: $e');
    }
  }

  // Obtener todos los vehiculos
  Future<List<Vehiculo>> getAll() async {
    try {
      final querySnapshot = await _firestore.collection(_collection).get();
      return querySnapshot.docs
          .map((doc) => Vehiculo.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener vehiculos: $e');
    }
  }

  // Actualizar vehiculo
  Future<void> update(String uid, Vehiculo vehiculo) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(uid)
          .update(vehiculo.toFirestore());
    } catch (e) {
      throw Exception('Error al actualizar vehiculo: $e');
    }
  }

  // Actualizar kilometraje
  Future<void> updateKilometraje(String uid, int kilometraje) async {
    try {
      await _firestore.collection(_collection).doc(uid).update({
        'kilometraje': kilometraje,
      });
    } catch (e) {
      throw Exception('Error al actualizar kilometraje: $e');
    }
  }

  // Actualizar imagen del vehículo
  Future<void> updateImageUrl(String uid, String? imageUrl) async {
    try {
      await _firestore.collection(_collection).doc(uid).update({
        'imageUrl': imageUrl,
      });
    } catch (e) {
      throw Exception('Error al actualizar imagen: $e');
    }
  }

  // Eliminar vehiculo (cambiar estado)
  Future<void> delete(String uid) async {
    try {
      await _firestore.collection(_collection).doc(uid).update({'estado': 0});
    } catch (e) {
      throw Exception('Error al eliminar vehiculo: $e');
    }
  }

  // Activar vehiculo
  Future<void> activate(String uid) async {
    try {
      await _firestore.collection(_collection).doc(uid).update({'estado': 1});
    } catch (e) {
      throw Exception('Error al activar vehiculo: $e');
    }
  }
}
