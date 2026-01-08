import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:autovitae/data/models/estado_remolque.dart';

class SolicitudRemolque {
  final String? uidSolicitud;
  final String uidCliente;
  final String uidVehiculo;
  final String uidTaller;
  final String? ubicacionActual;
  final int fechaSolicitud;
  final EstadoRemolque estado;
  final String? observaciones;

  SolicitudRemolque({
    this.uidSolicitud,
    required this.uidCliente,
    required this.uidVehiculo,
    required this.uidTaller,
    this.ubicacionActual,
    int? fechaSolicitud,
    this.estado = EstadoRemolque.pendiente,
    this.observaciones,
  }) : fechaSolicitud = fechaSolicitud ?? DateTime.now().millisecondsSinceEpoch;

  factory SolicitudRemolque.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    if (data == null) {
      throw Exception('SolicitudRemolque no encontrada');
    }
    return SolicitudRemolque(
      uidSolicitud: doc.id,
      uidCliente: data['uidCliente'] ?? '',
      uidVehiculo: data['uidVehiculo'] ?? '',
      uidTaller: data['uidTaller'] ?? '',
      ubicacionActual: data['ubicacionActual'] ?? '',
      fechaSolicitud: (() {
        final v = data['fechaSolicitud'];
        if (v is int) return v;
        if (v is num) return v.toInt();
        if (v is Timestamp) return v.millisecondsSinceEpoch;
        return DateTime.now().millisecondsSinceEpoch;
      })(),
      estado: EstadoRemolqueX.fromString(data['estado'] ?? 'pendiente'),
      observaciones: data['observaciones'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uidSolicitud': uidSolicitud,
      'uidCliente': uidCliente,
      'uidVehiculo': uidVehiculo,
      'uidTaller': uidTaller,
      'ubicacionActual': ubicacionActual,
      'fechaSolicitud': fechaSolicitud,
      'estado': estado.value,
      'observaciones': observaciones,
    };
  }
}
