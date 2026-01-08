import 'package:autovitae/data/models/estado_cita.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Cita {
  final String? uidCita;
  final String uidCliente;
  final String uidVehiculo;
  final String uidTaller;
  final int fechaCita;
  final EstadoCita estado;
  final String? descripcion;
  final int fechaCreacion;

  Cita({
    this.uidCita,
    required this.uidCliente,
    required this.uidVehiculo,
    required this.uidTaller,
    int? fechaCita,
    this.estado = EstadoCita.pendiente,
    this.descripcion,
    int? fechaCreacion,
  }) : fechaCita = fechaCita ?? DateTime.now().millisecondsSinceEpoch,
       fechaCreacion = fechaCreacion ?? DateTime.now().millisecondsSinceEpoch;

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
      fechaCita: data['fechaCita'] ?? DateTime.now().millisecondsSinceEpoch,
      estado: EstadoCitaX.fromString(data['estado'] ?? 'pendiente'),
      descripcion: data['descripcion'] ?? '',
      fechaCreacion: (() {
        final v = data['fechaCreacion'];
        if (v is int) return v;
        if (v is num) return v.toInt();
        if (v is Timestamp) return v.millisecondsSinceEpoch;
        return DateTime.now().millisecondsSinceEpoch;
      })(),
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
