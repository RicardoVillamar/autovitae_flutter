import 'package:cloud_firestore/cloud_firestore.dart';

class Taller {
  final String? uidTaller;
  final String uidGerente;
  final String nombre;
  final String direccion;
  final String telefono;
  final String correo;
  final String descripcion;
  final int estado;
  final Timestamp fechaRegistro;

  Taller({
    this.uidTaller,
    required this.uidGerente,
    required this.nombre,
    required this.direccion,
    required this.telefono,
    required this.correo,
    required this.descripcion,
    this.estado = 1,
    Timestamp? fechaRegistro,
  }) : fechaRegistro = fechaRegistro ?? Timestamp.now();

  factory Taller.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw Exception('Taller no encontrado');
    }
    return Taller(
      uidTaller: doc.id,
      uidGerente: data['uidGerente'] ?? '',
      nombre: data['nombre'] ?? '',
      direccion: data['direccion'] ?? '',
      telefono: data['telefono'] ?? '',
      correo: data['correo'] ?? '',
      descripcion: data['descripcion'] ?? '',
      estado: (data['estado'] ?? 1) as int,
      fechaRegistro: data['fechaRegistro'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uidTaller': uidTaller,
      'uidGerente': uidGerente,
      'nombre': nombre,
      'direccion': direccion,
      'telefono': telefono,
      'correo': correo,
      'descripcion': descripcion,
      'estado': estado,
      'fechaRegistro': fechaRegistro,
    };
  }
}
