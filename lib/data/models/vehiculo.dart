import 'package:cloud_firestore/cloud_firestore.dart';

class Vehiculo {
  final String? uidVehiculo;
  final String uidCliente;
  final String? marca;
  final String? modelo;
  final int? anio;
  final String? placa;
  final int kilometraje;
  final String? imageUrl;
  final int estado;

  Vehiculo({
    this.uidVehiculo,
    required this.uidCliente,
    this.marca,
    this.modelo,
    this.anio,
    this.placa,
    this.kilometraje = 0,
    this.imageUrl,
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
      imageUrl: data['imageUrl'] as String?,
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
      'imageUrl': imageUrl,
      'estado': estado,
    };
  }

  Vehiculo copyWith({
    String? uidVehiculo,
    String? uidCliente,
    String? marca,
    String? modelo,
    int? anio,
    String? placa,
    int? kilometraje,
    String? imageUrl,
    int? estado,
  }) {
    return Vehiculo(
      uidVehiculo: uidVehiculo ?? this.uidVehiculo,
      uidCliente: uidCliente ?? this.uidCliente,
      marca: marca ?? this.marca,
      modelo: modelo ?? this.modelo,
      anio: anio ?? this.anio,
      placa: placa ?? this.placa,
      kilometraje: kilometraje ?? this.kilometraje,
      imageUrl: imageUrl ?? this.imageUrl,
      estado: estado ?? this.estado,
    );
  }
}
