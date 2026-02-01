import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:autovitae/data/models/estado_mantenimiento.dart';

class Mantenimiento {
  final String? uidMantenimiento;
  final String uidTaller;
  final String uidCliente;
  final String uidVehiculo;
  final int fechaProgramada;
  final int? fechaInicio;
  final int? fechaFin;
  final EstadoMantenimiento estado;
  final String? observaciones;
  final double? latitud;
  final double? longitud;
  final String? direccion;

  Mantenimiento({
    this.uidMantenimiento,
    required this.uidTaller,
    required this.uidCliente,
    required this.uidVehiculo,
    int? fechaProgramada,
    this.fechaInicio,
    this.fechaFin,
    this.estado = EstadoMantenimiento.pendiente,
    this.observaciones,
    this.latitud,
    this.longitud,
    this.direccion,
  }) : fechaProgramada =
            fechaProgramada ?? DateTime.now().millisecondsSinceEpoch;

  factory Mantenimiento.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    if (data == null) {
      throw Exception('Mantenimiento no encontrado');
    }
    return Mantenimiento(
      uidMantenimiento: doc.id,
      uidTaller: data['uidTaller'] ?? '',
      uidCliente: data['uidCliente'] ?? '',
      uidVehiculo: data['uidVehiculo'] ?? '',
      fechaProgramada:
          data['fechaProgramada'] ?? DateTime.now().millisecondsSinceEpoch,
      fechaInicio: data['fechaInicio'],
      fechaFin: data['fechaFin'],
      estado: EstadoMantenimientoX.fromString(data['estado'] ?? 'pendiente'),
      observaciones: data['observaciones'] ?? '',
      latitud: (data['latitud'] as num?)?.toDouble(),
      longitud: (data['longitud'] as num?)?.toDouble(),
      direccion: data['direccion'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uidMantenimiento': uidMantenimiento,
      'uidTaller': uidTaller,
      'uidCliente': uidCliente,
      'uidVehiculo': uidVehiculo,
      'fechaProgramada': fechaProgramada,
      'fechaInicio': fechaInicio,
      'fechaFin': fechaFin,
      'estado': estado.value,
      'observaciones': observaciones,
      'latitud': latitud,
      'longitud': longitud,
      'direccion': direccion,
    };
  }
}
