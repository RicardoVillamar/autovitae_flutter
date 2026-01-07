import 'package:cloud_firestore/cloud_firestore.dart';

class Gerente {
  final String? uidGerente;
  final String? uidUsuario;
  final String? uidTaller;
  final int estado;
  final bool primerLogin;
  final Timestamp fechaAsignacion;

  Gerente({
    this.uidGerente,
    this.uidUsuario,
    this.uidTaller,
    this.estado = 1,
    this.primerLogin = true,
    Timestamp? fechaAsignacion,
  }) : fechaAsignacion = fechaAsignacion ?? Timestamp.now();

  factory Gerente.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw Exception('Gerente no encontrado');
    }
    return Gerente(
      uidGerente: doc.id,
      uidUsuario: data['uidUsuario'] ?? '',
      uidTaller: data['uidTaller'] ?? '',
      estado: (data['estado'] ?? 1) as int,
      primerLogin: data['primerLogin'] ?? true,
      fechaAsignacion: data['fechaAsignacion'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uidGerente': uidGerente,
      'uidUsuario': uidUsuario,
      'uidTaller': uidTaller,
      'estado': estado,
      'primerLogin': primerLogin,
      'fechaAsignacion': fechaAsignacion,
    };
  }
}
