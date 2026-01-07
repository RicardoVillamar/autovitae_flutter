import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:autovitae/model/enums/estado_mantenimineto.dart';

class Mantenimiento {
  final String? uidMantenimiento;
  final String uidCita;
  final String uidTaller;
  final Timestamp? fechaInicio;
  final Timestamp? fechaFin;
  final EstadoMantenimiento estado;
  final String? observaciones;

  Mantenimiento({
    this.uidMantenimiento,
    required this.uidCita,
    required this.uidTaller,
    this.fechaInicio,
    this.fechaFin,
    this.estado = EstadoMantenimiento.enProceso,
    this.observaciones,
  });

  factory Mantenimiento.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    if (data == null) {
      throw Exception('Mantenimiento no encontrado');
    }
    return Mantenimiento(
      uidMantenimiento: doc.id,
      uidCita: data['uidCita'] ?? '',
      uidTaller: data['uidTaller'] ?? '',
      fechaInicio: data['fechaInicio'],
      fechaFin: data['fechaFin'],
      estado: EstadoMantenimientoX.fromString(data['estado'] ?? 'enProceso'),
      observaciones: data['observaciones'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uidMantenimiento': uidMantenimiento,
      'uidCita': uidCita,
      'uidTaller': uidTaller,
      'fechaInicio': fechaInicio,
      'fechaFin': fechaFin,
      'estado': estado.value,
      'observaciones': observaciones,
    };
  }
}
