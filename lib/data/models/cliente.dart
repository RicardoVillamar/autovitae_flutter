import 'package:cloud_firestore/cloud_firestore.dart';

class Cliente {
  String? uidCliente;
  String? uidUsuario;
  String direccion;
  String ciudad;
  int estado;

  Cliente({
    this.uidCliente,
    this.uidUsuario,
    required this.direccion,
    required this.ciudad,
    this.estado = 1,
  });

  factory Cliente.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw Exception('Cliente no encontrado');
    }
    return Cliente(
      uidCliente: doc.id,
      uidUsuario: data['uidUsuario'] as String?,
      direccion: data['direccion'] ?? '',
      ciudad: data['ciudad'] ?? '',
      estado: (data['estado'] ?? 1) as int,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uidCliente': uidCliente,
      'uidUsuario': uidUsuario,
      'direccion': direccion,
      'ciudad': ciudad,
      'estado': estado,
    };
  }
}
