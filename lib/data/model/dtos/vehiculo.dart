import 'package:cloud_firestore/cloud_firestore.dart';

class Vehiculo {
  final String? uidVehiculo;
  final String uidCliente;
  final String? marca;
  final String? modelo;
  final int? anio;
  final String? placa;
  final int kilometraje;
  final int estado;

  Vehiculo({
    this.uidVehiculo,
    required this.uidCliente,
    this.marca,
    this.modelo,
    this.anio,
    this.placa,
    this.kilometraje = 0,
    this.estado = 1,
  });

  factory Vehiculo.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw Exception('Vehiculo no encontrado');
    }
    return Vehiculo(
      uidVehiculo: doc.id,
      uidCliente: data['uidCliente'] ?? '',
      marca: data['marca'] ?? '',
      modelo: data['modelo'] ?? '',
      anio: (data['anio'] is int)
          ? data['anio'] as int
          : (data['anio'] != null
                ? int.tryParse(data['anio'].toString())
                : null),
      placa: data['placa'] ?? '',
      kilometraje: (data['kilometraje'] ?? 0) as int,
      estado: (data['estado'] ?? 1) as int,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uidVehiculo': uidVehiculo,
      'uidCliente': uidCliente,
      'marca': marca,
      'modelo': modelo,
      'anio': anio,
      'placa': placa,
      'kilometraje': kilometraje,
      'estado': estado,
    };
  }
}
