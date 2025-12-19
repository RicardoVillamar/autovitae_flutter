import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:autovitae/data/model/enums/estado_cita.dart';

class Cita {
  final String? uidCita;
  final String uidCliente;
  final String uidVehiculo;
  final String uidTaller;
  final Timestamp fechaCita;
  final EstadoCita estado;
  final String? descripcion;
  final Timestamp fechaCreacion;

  Cita({
    this.uidCita,
    required this.uidCliente,
    required this.uidVehiculo,
    required this.uidTaller,
    Timestamp? fechaCita,
    this.estado = EstadoCita.pendiente,
    this.descripcion,
    Timestamp? fechaCreacion,
  }) : fechaCita = fechaCita ?? Timestamp.now(),
       fechaCreacion = fechaCreacion ?? Timestamp.now();

  factory Cita.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw Exception('Cita no encontrada');
    }
    return Cita(
      uidCita: doc.id,
      uidCliente: data['uidCliente'] ?? '',
      uidVehiculo: data['uidVehiculo'] ?? '',
      uidTaller: data['uidTaller'] ?? '',
      fechaCita: data['fechaCita'] ?? Timestamp.now(),
      estado: EstadoCitaX.fromString(data['estado'] ?? 'pendiente'),
      descripcion: data['descripcion'] ?? '',
      fechaCreacion: data['fechaCreacion'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uidCita': uidCita,
      'uidCliente': uidCliente,
      'uidVehiculo': uidVehiculo,
      'uidTaller': uidTaller,
      'fechaCita': fechaCita,
      'estado': estado.value,
      'descripcion': descripcion,
      'fechaCreacion': fechaCreacion,
    };
  }
}
