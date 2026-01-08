import 'package:cloud_firestore/cloud_firestore.dart';

class Gerente {
  final String? uidGerente;
  final String? uidUsuario;
  final String? uidTaller;
  final int estado;
  final bool primerLogin;
  final int fechaAsignacion;

  Gerente({
    this.uidGerente,
    this.uidUsuario,
    this.uidTaller,
    this.estado = 1,
    this.primerLogin = true,
    int? fechaAsignacion,
  }) : fechaAsignacion =
           fechaAsignacion ?? DateTime.now().millisecondsSinceEpoch;

  factory Gerente.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw Exception('Gerente no encontrado');
    }
    return Gerente(
      uidGerente: doc.id,
      uidUsuario: data['uidUsuario'] as String?,
      uidTaller: data['uidTaller'] as String?,
      estado: (data['estado'] ?? 1) as int,
      primerLogin: data['primerLogin'] ?? true,
      fechaAsignacion:
          data['fechaAsignacion'] ?? DateTime.now().millisecondsSinceEpoch,
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
