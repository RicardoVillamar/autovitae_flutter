import 'package:autovitae/data/models/rol_usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Usuario {
  final String? uidUsuario;
  final String nombre;
  final String apellido;
  final String cedula;
  final String correo;
  final String telefono;
  final String? fotoUrl;
  final RolUsuario rol;
  final int estado;
  final int fechaRegistro;

  Usuario({
    this.uidUsuario,
    required this.nombre,
    required this.apellido,
    required this.cedula,
    required this.correo,
    required this.telefono,
    this.fotoUrl,
    this.rol = RolUsuario.cliente,
    this.estado = 1,
    int? fechaRegistro,
  }) : fechaRegistro = fechaRegistro ?? DateTime.now().millisecondsSinceEpoch;

  factory Usuario.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw Exception('Usuario no encontrado');
    }
    return Usuario(
      uidUsuario: doc.id,
      nombre: data['nombre'] ?? '',
      apellido: data['apellido'] ?? '',
      correo: data['correo'] ?? '',
      cedula: data['cedula'] ?? '',
      telefono: data['telefono'] ?? '',
      fotoUrl: data['fotoUrl'] ?? '',
      rol: RolUsuarioX.fromString(data['rol'] ?? 'cliente'),
      estado: (data['estado'] ?? 1) as int,
      fechaRegistro:
          data['fechaRegistro'] ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uidUsuario': uidUsuario,
      'nombre': nombre,
      'apellido': apellido,
      'cedula': cedula,
      'correo': correo,
      'telefono': telefono,
      'fotoUrl': fotoUrl,
      'rol': rol.value,
      'estado': estado,
      'fechaRegistro': fechaRegistro,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      uidUsuario: map['uidUsuario'],
      nombre: map['nombre'] ?? '',
      apellido: map['apellido'] ?? '',
      correo: map['correo'] ?? '',
      cedula: map['cedula'] ?? '',
      telefono: map['telefono'] ?? '',
      fotoUrl: map['fotoUrl'],
      rol: RolUsuarioX.fromString(map['rol'] ?? 'cliente'),
      estado: (map['estado'] ?? 1) as int,
      fechaRegistro: (() {
        final v = map['fechaRegistro'];
        if (v is int) return v;
        if (v is num) return v.toInt();
        if (v is Timestamp) return v.millisecondsSinceEpoch;
        if (v != null) {
          return int.tryParse(v.toString()) ??
              DateTime.now().millisecondsSinceEpoch;
        }
        return DateTime.now().millisecondsSinceEpoch;
      })(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uidUsuario': uidUsuario,
      'nombre': nombre,
      'apellido': apellido,
      'cedula': cedula,
      'correo': correo,
      'telefono': telefono,
      'fotoUrl': fotoUrl,
      'rol': rol.value,
      'estado': estado,
      'fechaRegistro': fechaRegistro,
    };
  }
}
